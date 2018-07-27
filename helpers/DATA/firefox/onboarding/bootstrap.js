/* -*- indent-tabs-mode: nil; js-indent-level: 2 -*- */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// Based on the original onboarding code with deep changes from Ruben Rodriguez
// Copyright (C) 2018 Ruben Rodriguez <ruben@gnu.org>

/* globals  APP_STARTUP, ADDON_INSTALL */
"use strict";

const {utils: Cu, interfaces: Ci} = Components;
Cu.import("resource://gre/modules/XPCOMUtils.jsm");
XPCOMUtils.defineLazyModuleGetters(this, {
  Services: "resource://gre/modules/Services.jsm",
  AddonManager: "resource://gre/modules/AddonManager.jsm",
});

XPCOMUtils.defineLazyServiceGetter(this, "resProto",
                                   "@mozilla.org/network/protocol;1?name=resource",
                                   "nsISubstitutingProtocolHandler");

const RESOURCE_HOST = "onboarding";

const {PREF_STRING, PREF_BOOL, PREF_INT} = Ci.nsIPrefBranch;

const BROWSER_READY_NOTIFICATION = "browser-delayed-startup-finished";
const BROWSER_SESSION_STORE_NOTIFICATION = "sessionstore-windows-restored";

let waitingForBrowserReady = true;
let startupData;

/**
 * Set pref. Why no `getPrefs` function is due to the privilege level.
 * We cannot set prefs inside a framescript but can read.
 * For simplicity and efficiency, we still read prefs inside the framescript.
 *
 * @param {Array} prefs the array of prefs to set.
 *   The array element carries info to set pref, should contain
 *   - {String} name the pref name, such as `browser.onboarding.state`
 *   - {*} value the value to set
 **/
function setPrefs(type, name, value) {
  switch (type) {
    case "boolean":
      Services.prefs.setBoolPref(name, value);
      break;
    case "integer":
      Services.prefs.setIntPref(name, value);
      break;
    case "string":
      Services.prefs.setStringPref(name, value);
      break;
    default:
      throw new TypeError(`Unexpected type (${type}) for preference ${name}.`);
  }
}

async function flip(id){
  var addonObj = await AddonManager.getAddonByID(id);

  addonObj.userDisabled = addonObj.isActive;
  if ( addonObj.operationsRequiringRestart != 0)
      Services.mm.broadcastAsyncMessage("Onboarding:needsrestart");
  Services.mm.broadcastAsyncMessage("Onboarding:message-from-chrome", {
    id : id,
    active : addonObj.isActive,
    installed : true
  });
}

async function checkaddon(id){
  var addonObj = await AddonManager.getAddonByID(id);

  if (addonObj != null)
    Services.mm.broadcastAsyncMessage("Onboarding:message-from-chrome", {
      id : id,
      active : addonObj.isActive,
      installed : true
    });
  else
    Services.mm.broadcastAsyncMessage("Onboarding:message-from-chrome", {
      id : id,
      active : false,
      installed : false
    });
}

function initContentMessageListener() {
  Services.mm.addMessageListener("Onboarding:OnContentMessage", msg => {
    switch (msg.data.action) {
      case "set-prefs":
        setPrefs(msg.data.params[0].type, msg.data.params[0].name, msg.data.params[0].value);
        if (msg.data.params[0].name == "browser.search.geoip.url")
          setPrefs("boolean", "geo.enabled", msg.data.params[0].value != "" );
        if (msg.data.params[0].name == "captivedetect.canonicalURL")
          setPrefs("boolean", "network.captive-portal-service.enabled", msg.data.params[0].value != "" )
        if (msg.data.params[0].name == "browser.safebrowsing.provider.mozilla.updateURL")
          setPrefs("boolean", "privacy.trackingprotection.enabled", msg.data.params[0].value != "" )
          setPrefs("boolean", "privacy.trackingprotection.pbmode.enabled", msg.data.params[0].value != "" )
        break;
      case "flip-addon":
        flip(msg.data.params[0].name);
        break;
      case "check-addon":
        checkaddon(msg.data.params[0].name);
        break;

    }
  });
}


/**
 * onBrowserReady - Continues startup of the add-on after browser is ready.
 */
function onBrowserReady() {

  waitingForBrowserReady = false;

  Services.mm.loadFrameScript("resource://onboarding/onboarding.js", true);
  initContentMessageListener();
}

/**
 * observe - nsIObserver callback to handle various browser notifications.
 */
function observe(subject, topic, data) {
  switch (topic) {
    case BROWSER_READY_NOTIFICATION:
      Services.obs.removeObserver(observe, BROWSER_READY_NOTIFICATION);
      onBrowserReady();
      break;
    case BROWSER_SESSION_STORE_NOTIFICATION:
      Services.obs.removeObserver(observe, BROWSER_SESSION_STORE_NOTIFICATION);
      break;
  }
}

function install(aData, aReason) {}

function uninstall(aData, aReason) {}

function startup(aData, aReason) {
  resProto.setSubstitutionWithFlags(RESOURCE_HOST,
                                    Services.io.newURI("chrome/content/", null, aData.resourceURI),
                                    resProto.ALLOW_CONTENT_ACCESS);

  // Cache startup data which contains stuff like the version number, etc.
  // so we can use it when we init the telemetry
  startupData = aData;
  // Only start Onboarding when the browser UI is ready
  if (Services.startup.startingUp) {
    Services.obs.addObserver(observe, BROWSER_READY_NOTIFICATION);
    Services.obs.addObserver(observe, BROWSER_SESSION_STORE_NOTIFICATION);
  } else {
    onBrowserReady();
  }
}

function shutdown(aData, aReason) {
  startupData = null;
  // Stop waiting for browser to be ready
  if (waitingForBrowserReady) {
    Services.obs.removeObserver(observe, BROWSER_READY_NOTIFICATION);
  }
}
