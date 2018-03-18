/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

// Based on the original onboarding code with deep changes from Ruben Rodriguez
// Copyright (C) 2018 Ruben Rodriguez <ruben@gnu.org>

/* eslint-env mozilla/frame-script */

"use strict";

const {classes: Cc, interfaces: Ci, utils: Cu} = Components;
Cu.import("resource://gre/modules/Services.jsm");


const ABOUT_HOME_URL = "about:home";
const ABOUT_NEWTAB_URL = "about:newtab";

/**
 * @param {String} action the action to ask the chrome to do
 * @param {Array | Object} params the parameters for the action
 */
function sendMessageToChrome(action, params) {
  sendAsyncMessage("Onboarding:OnContentMessage", {
    action, params
  });
}


/**
 * The script won't be initialized if we turned off onboarding by
 * setting "browser.onboarding.enabled" to false.
 */
class Onboarding {
  constructor(contentWindow) {
    this.init(contentWindow);


 this.keylist = {
  "javascript.enabled": {
    type: "boolean",
    name: "javascript.enabled",
    label: "Disable JavaScript",
    description: "Disabling Javascript greatly improves privacy, security and <a href=\"https://www.gnu.org/philosophy/javascript-trap.html\">freedom</a>, but it will break many sites.",
    defaultvalue: true,
    onvalue: false,
    offvalue: true,
    },
  "browser.display.use_document_fonts": {
    type: "integer",
    name: "browser.display.use_document_fonts",
    label: "Do not load custom fonts",
    description: "Custom fonts can be used for <a href=\"https://en.wikipedia.org/wiki/Device_fingerprint\">fingerprinting</a>. Disabling them improves privacy but may make some sites look wrong.",
    defaultvalue: 1,
    onvalue: 0,
    offvalue: 1,
    },
  "browser.safebrowsing.provider.mozilla.updateURL": {
    type: "string",
    name: "browser.safebrowsing.provider.mozilla.updateURL",
    label: "Tracking protection",
    description: "Tracking is the collection of your browsing data across multiple websites. Enabling this feature improves privacy, but will regullarly connect to the Internet to fetch updates to the filters.",
    defaultvalue: "",
    onvalue: "https://shavar.services.mozilla.com/downloads?client=SAFEBROWSING_ID&appver=%MAJOR_VERSION%&pver=2.2",
    offvalue: "",
    },
  "privacy.firstparty.isolate": {
    type: "boolean",
    name: "privacy.firstparty.isolate",
    label: "Isolate requests to First Party domains",
    description: "This <a href=\"https://www.torproject.org/projects/torbrowser/design/#identifier-linkability\">improves privacy</a>, but it may interfere with login into some sites.",
    defaultvalue: false,
    onvalue: true,
    offvalue: false,
    },
  "extensions.update.enabled": {
    type: "boolean",
    name: "extensions.update.enabled",
    label: "Automatically update extensions",
    description: "Enabling automated updates is good for security, but would start Internet connections in the background.",
    defaultvalue: false,
    onvalue: true,
    offvalue: false,
    },
  "network.http.referer.spoofSource": {
    type: "boolean",
    name: "network.http.referer.spoofSource",
    label: "Spoof Referers",
    description: "<a href=\"https://en.wikipedia.org/wiki/HTTP_referer\">Referers</a> tell sites what link brought you there. This feature greatly improves your privacy, but it may break functionality on some sites.",
    defaultvalue: true,
    onvalue: true,
    offvalue: false,
    },
  "captivedetect.canonicalURL": {
    type: "string",
    name: "captivedetect.canonicalURL",
    label: "Detect captive portal",
    description: "<a href=\"https://en.wikipedia.org/wiki/Captive_portal\">Captive portals</a> are the sites that control access to public wireless networks in hotels, airports, cafes, etc. The detection service is useful if you connect to such netwoks, but it will start connections automatically.",
    defaultvalue: "",
    onvalue: "http://detectportal.firefox.com/success.txt",
    offvalue: "",
    },
  "browser.search.geoip.url": {
    type: "string",
    name: "browser.search.geoip.url",
    label: "Enable Geolocation",
    description: "This is commonly used for maps, weather sites, and some stores. It is better to keep it off unless you really need it.",
    defaultvalue: "",
    onvalue: "https://location.services.mozilla.com/v1/country?key=%MOZILLA_API_KEY%",
    offvalue: ""
    },

  "webgl.disabled": {  
    type: "boolean",  
    name: "webgl.disabled",  
    label: "Enable WebGL",  
    description: "Needed to visualize 3D graphics, but it may expose you to security threats. Enable it only if you really use it.",  
    defaultvalue: true,
    onvalue: false,  
    offvalue: true  
    }
   }
  }

  async init(contentWindow) {
    this._window = contentWindow;

    // Destroy on unloading. This is to ensure we remove all the stuff we left.
    // No any leak out there.
    this._window.addEventListener("unload", () => this.destroy());

    this.uiInitialized = false;
    this._window.requestIdleCallback(() => this._initUI());
  }

  getPref(type, key, def){
    switch (type){
      case "integer":
        return Services.prefs.getIntPref(key, def);
        break;
      case "string":
        return Services.prefs.getStringPref(key, def);
        break;
      case "boolean":
        return Services.prefs.getBoolPref(key, def);
        break;
    }  
  }

  _callback(id, val){
    this._window.document.getElementById(id).checked= (val==this.keylist[id].onvalue);
  }

  newcheckbox(kind, type, name, label, description, defaultvalue, onvalue, offvalue){
    let content = this._window.document.createElement("div");
    content.style="border-top: 1px solid #DDDDDD; padding-top:10px";
    if (kind == "addon")
     sendMessageToChrome("check-addon", [{
        name: name,
      }]);
    else
      Services.prefs.addObserver(name, () => {this._callback(name, this.getPref(type, name, defaultvalue));});
    content.appendChild(this._window.document.createElement("input"));
    content.appendChild(this._window.document.createElement("label"));
    content.appendChild(this._window.document.createElement("p"));
    content.children[0].id=name;
    content.children[0].name=name;
    content.children[0].className=kind;
    content.children[0].type="checkbox";
    content.children[0].style="position:relative; top:2px;";
    content.children[0].checked=this.getPref(type, name, defaultvalue)==onvalue;
    content.children[0].addEventListener("click", this);
    content.children[0].addEventListener("keypress", this);
    content.children[1].for=name;
    content.children[1].innerHTML=label;
    content.children[1].style="font-size:15px";
    if (description != ""){
      content.children[2].innerHTML=description;
      content.children[2].style="padding-left:35px; font-size: small; color:#999; margin-top:5px";
    }

    return content;
  }

  _initUI() {
    if (this.uiInitialized) {
      return;
    }
    this.uiInitialized = true;

    let { body } = this._window.document;

    let main = this._window.document.getElementsByTagName("main")[0];
    let settingsblock = this._window.document.createElement("div");
    settingsblock.style=`border:1px solid #D7D7DB;
                         border-radius:3px;
                         margin-bottom:40px;
                         padding:0 15px 10px 15px;
                         color:#4A4A4F;
                        `;
    let title = this._window.document.createElement("div");
    title.innerHTML=`<h2 style="margin:10px 0 5px; font-size:20px">Privacy settings</h2>
                        <p style="font-size:14px">These options allow you to tune important aspects of the browser's behavior so you can choose the balance between practicality and privacy that fits your needs. Changes to these settings apply to all existing tabs and windows (but you may need to reload them for the changes to show on them).</p>
                    `;
    main.insertBefore(settingsblock, main.childNodes[0]);
    settingsblock.appendChild(title);

    for ( var key in this.keylist){
      key = this.keylist[key];
      settingsblock.appendChild(this.newcheckbox("key", key.type, key.name, key.label, key.description, key.defaultvalue, key.onvalue, key.offvalue));
    }
    settingsblock.appendChild(this.newcheckbox("addon", null, "uBlock0@raymondhill.net", "uBlock Origin", "Block ads and other intrusing trackers."));
    settingsblock.appendChild(this.newcheckbox("addon", null, "jid1-KtlZuoiikVfFew@jetpack", "GNU LibreJs", "Block nonfree <a href=\"https://www.gnu.org/software/librejs/\">JavaScript</a>."));

  }

  _clearPrefObserver() {
    for ( var key in this.keylist){
      key = this.keylist[key];
      Services.prefs.removeObserver(key.name, () => {this._callbacktest(key.name, this.getPref(key.type, key.name, key.defaultvalue));});
    }
  }

  handleClick(target) {
    switch (target.className){
      case "addon":
        sendMessageToChrome("flip-addon", [{
          name: target.name
          }]);
        return;
        break;
      case "key":
        let value
        if (target.checked)
          value = this.keylist[target.name].onvalue
        else
          value = this.keylist[target.name].offvalue
        if (target.name == "captivedetect.canonicalURL" && value != "")
          this._window.alert("You need to restart the browser to apply this change.\n\nWhen this feature is enabled the browser will automatically\ntry to connect to detectportal.firefox.com at the beginning of each browsing session.");
        sendMessageToChrome("set-prefs", [{
          type: this.keylist[target.name].type,
          name: target.name,
          value: value
          }]);
        return;
        break
     }
  }

  /**
   * Wrap keyboard focus within the dialog.
   * When moving forward, focus on the first element when the current focused
   * element is the last one.
   * When moving backward, focus on the last element when the current focused
   * element is the first one.
   * Do nothing if focus is moving in the middle of the list of dialog's focusable
   * elements.
   *
   * @param  {DOMNode} current  currently focused element
   * @param  {Boolean} back     direction
   * @return {DOMNode}          newly focused element if any
   */
  wrapMoveFocus(current, back) {
    let elms = [...this._dialog.querySelectorAll(
      `button, input[type="checkbox"], input[type="email"], [tabindex="0"]`)];
    let next;
    if (back) {
      if (elms.indexOf(current) === 0) {
        next = elms[elms.length - 1];
        next.focus();
      }
    } else if (elms.indexOf(current) === elms.length - 1) {
      next = elms[0];
      next.focus();
    }
    return next;
  }

  handleKeypress(event) {
    let { target, key, shiftKey } = event;
    if ([" ", "Enter"].includes(key)) {
         this.handleClick(target);
         event.preventDefault();
       }
    return;
  }

  handleEvent(evt) {
    switch (evt.type) {
      case "keypress":
        this.handleKeypress(evt);
        break;
      case "click":
        this.handleClick(evt.target);
        break;
      default:
        break;
    }
  }

  destroy() {
    if (!this.uiInitialized) {
      return;
    }
    this.uiInitialized = false;

    this._clearPrefObserver();
  }
}

addEventListener("load", function onLoad(evt) {
  if (!content || evt.target != content.document) {
    return;
  }

  var window = evt.target.defaultView;

  // Set the checked value of addons
  function handleMessageFromChrome(message) {
    if (! window) return;
    var payload = message.data;
    var cb = window.document.getElementById(payload.id);
    if (cb == null) return;
    cb.checked=payload.active;
    cb.parentNode.hidden = ! payload.installed;
  }

  function needsrestart(){
    window.alert("This change will be applied when you restart the browser");
  }
  addMessageListener("Onboarding:message-from-chrome", handleMessageFromChrome);
  addMessageListener("Onboarding:needsrestart", needsrestart);

  let location = window.location.href;
  if (location == ABOUT_NEWTAB_URL || location == ABOUT_HOME_URL) {
    // We just want to run tests as quickly as possible
    // so in the automation test, we don't do `requestIdleCallback`.
    if (Cu.isInAutomation) {
      new Onboarding(window);
      return;
    }
    window.requestIdleCallback(() => {
      new Onboarding(window);
    });
  }
}, true);
