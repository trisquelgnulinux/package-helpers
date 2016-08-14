/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

pref("startup.homepage_override_url","http://trisquel.info");
pref("startup.homepage_welcome_url","http://trisquel.info/welcome");
// The time interval between checks for a new version (in seconds)
// nightly=8 hours, official=24 hours
pref("app.update.interval", 86400);
// The time interval between the downloading of mar file chunks in the
// background (in seconds)
pref("app.update.download.backgroundInterval", 60);
// URL user can browse to manually if for some reason all update installation
// attempts fail.
pref("app.update.url.manual", "http://trisquel.info/browser");
// A default value for the "More information about this update" link
// supplied in the "An update is available" page of the update wizard.
pref("app.update.url.details", "http://trisquel.info/browser");

// Release notes and vendor URLs
pref("app.releaseNotesURL", "http://trisquel.info/browser");
pref("app.vendorURL", "http://trisquel.info/browser/");

// Search codes belong only in builds with official branding
pref("browser.search.param.yahoo-fr", "");
pref("browser.search.param.yahoo-fr-cjkt", ""); // now unused
pref("browser.search.param.yahoo-fr-ja", "");
pref("browser.search.param.yahoo-f-CN", "");
