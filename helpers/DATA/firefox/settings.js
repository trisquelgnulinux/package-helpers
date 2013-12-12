
// Release notes and vendor URLs
pref("app.releaseNotesURL", "http://trisquel.info/browser");
pref("app.vendorURL", "http://trisquel.info/browser");

// PFS url
pref("pfs.datasource.url", "http://trisquel.info/sites/pfs.php?mime=%PLUGIN_MIMETYPE%");
pref("pfs.filehint.url", "http://trisquel.info/sites/pfs.php?mime=%PLUGIN_MIMETYPE%");

// I'm feeling Ducky.
pref("keyword.URL", "https://duckduckgo.com/?t=trisquel&q=!+");
pref("browser.search.defaultenginename", "DuckDuckGo (SSL)");
pref("browser.search.order.extra.duckduckgo", "DuckDuckGo (SSL)");

// Disable plugin installer
pref("plugins.hide_infobar_for_missing_plugin", true);
pref("plugins.hide_infobar_for_outdated_plugin", true);

//Speeding it up
pref("network.http.pipelining", true);
pref("network.http.proxy.pipelining", true);
pref("network.http.pipelining.maxrequests", 10);
pref("network.dns.disableIPv6", true);
pref("nglayout.initialpaint.delay", 0);

// Disable third party cookies
pref("network.cookie.cookieBehavior", 1);

// Extensions can be updated
pref("extensions.update.enabled", true);
// Use LANG environment variable to choose locale
pref("intl.locale.matchOS", true);
// Disable default browser checking.
pref("browser.shell.checkDefaultBrowser", false);
// Prevent EULA dialog to popup on first run
pref("browser.EULA.override", true);

// Default name strings
pref ("distribution.about", "Abrowser for Trisquel");
pref ("distribution.id", "trisquel");
pref ("distribution.version", "$REVISION");

// UserAgeng
pref("general.useragent.vendor", "Trisquel");
pref("general.useragent.vendorComment", "$CODENAME");
pref("general.useragent.vendorSub", "$REVISION");
// Set useragent to Firefox compatible
pref("general.useragent.compatMode.abrowser",true);

// Startup pages
pref ("browser.startup.page" , 3);
//pref ("browser.startup.homepage" , "http://trisquel.info");
//pref ("startup.homepage_welcome_url", "http://trisquel.info/welcome");
//pref ("startup.homepage_override_url" , "http://trisquel.info/newbrowser");

// Preferences for the Get Add-ons panel
pref ("extensions.webservice.discoverURL", "https://trisquel.info/browser-plain");
pref ("extensions.getAddons.search.url", "http://trisquel.info");

// Help URL
pref ("app.support.baseURL", "http://trisquel.info/wiki/");

// Dictionary download preference
pref("browser.dictionaries.download.url", "http://dictionaries.mozdev.org/");
pref("browser.search.searchEnginesURL", "http://mycroft.mozdev.org/");

// Apturl preferences
pref("network.protocol-handler.app.apt","/usr/bin/apturl");
pref("network.protocol-handler.warn-external.apt",false);
pref("network.protocol-handler.app.apt+http","/usr/bin/apturl");
pref("network.protocol-handler.warn-external.apt+http",false);
pref("network.protocol-handler.external.apt",true);
pref("network.protocol-handler.external.apt+http",true);

// Privacy & Freedom Issues
pref("privacy.donottrackheader.enabled", true);
pref("dom.ipc.plugins.flash.subprocess.crashreporter.enabled", false);
pref("browser.safebrowsing.enabled", false);
pref("browser.safebrowsing.malware.enabled", false);
pref("services.sync.privacyURL", "http://trisquel.info/en/legal");
pref("social.enabled", false);
pref("social.remote-install.enabled", false);
pref("datareporting.healthreport.uploadEnabled", false);
pref("social.toast-notifications.enabled", false);
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.healthreport.service.enabled", false);
pref("browser.slowStartup.notificationDisabled", true);

// Services
pref("gecko.handlerService.schemes.mailto.0.name", "");
pref("gecko.handlerService.schemes.mailto.1.name", "");
pref("handlerService.schemes.mailto.1.uriTemplate", "");
pref("gecko.handlerService.schemes.mailto.0.uriTemplate", "");
pref("browser.contentHandlers.types.0.title", "");
pref("browser.contentHandlers.types.0.uri", "");
pref("browser.contentHandlers.types.1.title", "");
pref("browser.contentHandlers.types.1.uri", "");
pref("gecko.handlerService.schemes.webcal.0.name", "");
pref("gecko.handlerService.schemes.webcal.0.uriTemplate", "");
pref("gecko.handlerService.schemes.ircs.0.name", "");
pref("gecko.handlerService.schemes.ircs.0.uriTemplate", "");
