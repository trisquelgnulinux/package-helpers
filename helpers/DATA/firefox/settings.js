
// Release notes and vendor URLs
pref("app.releaseNotesURL", "https://trisquel.info/en/wiki/abrowser-help");
pref("app.vendorURL", "https://trisquel.info/en/wiki/abrowser-help");

// PFS url
pref("pfs.datasource.url", "https://trisquel.info/sites/pfs.php?mime=%PLUGIN_MIMETYPE%");
pref("pfs.filehint.url", "https://trisquel.info/sites/pfs.php?mime=%PLUGIN_MIMETYPE%");

// I'm feeling Ducky.
pref("keyword.URL", "https://duckduckgo.com/?q=!+");
pref("browser.search.defaultenginename", "DuckDuckGo");
pref("browser.search.order.1", "DuckDuckGo");
pref("browser.search.defaultenginename", "DuckDuckGo");
pref("browser.search.order.extra.duckduckgo", "DuckDuckGo");
pref("browser.search.showOneOffButtons", false);
pref("browser.search.suggest.enabled",false);
// Disable preconnecting to search engine when clicking on the search bar
pref("network.http.speculative-parallel-limit", 0);


// Disable plugin installer
pref("plugins.hide_infobar_for_missing_plugin", true);
pref("plugins.hide_infobar_for_outdated_plugin", true);
pref("plugins.notifyMissingFlash", false);

//https://developer.mozilla.org/en-US/docs/Web/API/MediaSource
//pref("media.mediasource.enabled",true);

//Speeding it up
pref("network.http.pipelining", true);
pref("network.http.proxy.pipelining", true);
pref("network.http.pipelining.maxrequests", 10);
pref("nglayout.initialpaint.delay", 0);

// Extensions cannot be updated without permission
pref("extensions.update.enabled", false);
pref("extensions.systemAddon.update.enabled", false);
pref("lightweightThemes.update.enabled", false);
// Use LANG environment variable to choose locale
pref("intl.locale.matchOS", true);
// Disable default browser checking.
pref("browser.shell.checkDefaultBrowser", false);
// Prevent EULA dialog to popup on first run
pref("browser.EULA.override", true);

// Default name strings
pref ("distribution.about", "Abrowser for Trisquel");
pref ("distribution.id", "trisquel");
pref ("distribution.version", "1.0");

// Set useragent to Firefox compatible
pref("general.useragent.compatMode.abrowser",true);
// Spoof the useragent to a generic one
//pref("general.useragent.override", "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:24.0) Gecko/20100101 Firefox/58.0");


// Startup pages
//pref ("browser.startup.page" , 3);
//pref ("browser.startup.homepage" , "https://trisquel.info");
//pref ("startup.homepage_welcome_url", "https://trisquel.info/welcome");
//pref ("startup.homepage_override_url" , "https://trisquel.info/newbrowser");
pref ("browser.startup.homepage_override.mstone", "ignore");

// Preferences for the Get Add-ons panel
pref ("extensions.webservice.discoverURL", "https://trisquel.info/browser-plain");
pref ("extensions.getAddons.search.url", "https://trisquel.info");

// Help URL
pref ("app.support.baseURL", "https://trisquel.info/wiki/");
pref ("app.support.inputURL", "https://trisquel.info/contact");
pref ("app.feedback.baseURL", "https://trisquel.info/contact");
pref ("browser.uitour.url", "https://trisquel.info/en/wiki/abrowser-help");
pref ("plugins.update.url", "https://trisquel.info/en/wiki/abrowser-help");
pref ("browser.customizemode.tip0.learnMoreUrl", "https://trisquel.info/en/wiki/abrowser-help");

// Dictionary download preference
pref("browser.dictionaries.download.url", "http://dictionaries.mozdev.org/");
pref("browser.search.searchEnginesURL", "http://mycroft.mozdev.org/");
// Enable Spell Checking In All Text Fields
pref("layout.spellcheckDefault", 2);

// Apturl preferences
pref("network.protocol-handler.app.apt","/usr/bin/apturl");
pref("network.protocol-handler.warn-external.apt",false);
pref("network.protocol-handler.app.apt+http","/usr/bin/apturl");
pref("network.protocol-handler.warn-external.apt+http",false);
pref("network.protocol-handler.external.apt",true);
pref("network.protocol-handler.external.apt+http",true);

// Privacy & Freedom Issues
// https://webdevelopmentaid.wordpress.com/2013/10/21/customize-privacy-settings-in-mozilla-firefox-part-1-aboutconfig/
// https://panopticlick.eff.org
// https://wiki.mozilla.org/Fingerprinting
pref("browser.contentblocking.features.strict", "tp,tpPrivate,cookieBehavior1,cm,fp,stp");
pref("privacy.donottrackheader.enabled", true);
pref("privacy.donottrackheader.value", 1);
pref("dom.ipc.plugins.flash.subprocess.crashreporter.enabled", false);
pref("browser.safebrowsing.enabled", false);
pref("browser.safebrowsing.downloads.remote.enabled", false);
pref("browser.safebrowsing.malware.enabled", false);
pref("browser.safebrowsing.provider.mozilla.gethashURL", "");
// Uncomment next line to prevent automated connection to mozilla, to fetch block list
//pref("browser.safebrowsing.provider.mozilla.updateURL", "");
pref("services.sync.privacyURL", "https://trisquel.info/en/legal");
pref("social.enabled", false);
pref("social.remote-install.enabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
pref("datareporting.healthreport.uploadEnabled", false);
pref("social.toast-notifications.enabled", false);
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.healthreport.service.enabled", false);
pref("browser.slowStartup.notificationDisabled", true);
pref("network.http.sendRefererHeader", 2);
//http://grack.com/blog/2010/01/06/3rd-party-cookies-dom-storage-and-privacy/
//pref("dom.storage.enabled", false);
pref("dom.event.clipboardevents.enabled",false);
pref("network.prefetch-next", false);
pref("network.dns.disablePrefetch", true);
pref("network.http.sendSecureXSiteReferrer", false);
pref("toolkit.telemetry.enabled", false);
// Do not tell what plugins do we have enabled: https://mail.mozilla.org/pipermail/firefox-dev/2013-November/001186.html
pref("plugins.enumerable_names", "");
pref("plugin.state.flash", 1);
// Don't download ads for the newtab page
pref("browser.newtabpage.directory.source", "");
pref("browser.newtabpage.directory.ping", "");
pref("browser.newtabpage.introShown", true);
// Disable home snippets
pref("browser.aboutHomeSnippets.updateUrl", "");
// Always ask before restoring the browsing session
pref("browser.sessionstore.max_resumed_crashes", 0);
pref("privacy.trackingprotection.introURL", "https://www.mozilla.org/%LOCALE%/firefox/%VERSION%/tracking-protection/start/");
// Disable geolocation
pref("geo.enabled", false);
pref("browser.search.geoip.url", "");
pref("geo.provider-country.network.url", "");
pref("browser.search.geoSpecificDefaults.url", "");
pref("browser.region.network.url","");
// Disable captive portal detection
pref("captivedetect.canonicalURL", "");
pref("network.captive-portal-service.enabled", false);
// Disable shield/heartbeat
pref("extensions.shield-recipe-client.enabled", false);
// Canvas fingerprint protection
// Disabled, as it breaks things and does little improvements to fingerprinting
//pref("privacy.resistFingerprinting", true);
//pref("privacy.resistFingerprinting.autoDeclineNoUserInputCanvasPrompts", false);

// Webgl can be used for fingerprinting
pref("webgl.disabled", true);
// Don't reveal your internal IP when WebRTC is enabled
pref("media.peerconnection.ice.no_host", true);


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
pref("gecko.handlerService.schemes.irc.0.name", "");
pref("gecko.handlerService.schemes.irc.0.uriTemplate", "");

// Poodle attack
pref("security.tls.version.min", 1);

// Do not autoupdate search engines
pref("browser.search.update", false);
// Warn when the page tries to redirect or refresh
//pref("accessibility.blockautorefresh", true);

// Disable channel updates
pref("app.update.enabled", false);
pref("app.update.url", "");
pref("app.update.auto", false);
pref("toolkit.telemetry.enabled", false);

// Don't call home for blacklisting
pref("extensions.blocklist.enabled", false);

pref("font.default.x-western", "sans-serif");

// Disable Gecko media plugins: https://wiki.mozilla.org/GeckoMediaPlugins
pref("media.gmp-manager.url", "");
pref("media.gmp-provider.enabled", false);
// Don't install openh264 codec
pref("media.gmp-gmpopenh264.enabled", false);

//Disable middle click content load
//Avoid loading urls by mistake 
pref("middlemouse.contentLoadURL", false);

//Disable heartbeat
pref("browser.selfsupport.url", "");

//Disable Link to FireFox Marketplace, currently loaded with non-free "apps"
pref("browser.apps.URL", "");

//Disable Firefox Hello
pref("loop.enabled",false);

// Use old style preferences, that allow javascript to be disabled
pref("browser.preferences.inContent",false);

// Avoid logjam attack
pref("security.ssl3.dhe_rsa_aes_128_sha", false);
pref("security.ssl3.dhe_rsa_aes_256_sha", false);
pref("security.ssl3.dhe_dss_aes_128_sha", false);
pref("security.ssl3.dhe_rsa_des_ede3_sha", false);
pref("security.ssl3.rsa_des_ede3_sha", false);

// Disable Pocket integration
pref("browser.pocket.enabled", false);
pref("extensions.pocket.enabled", false);

// disable xpi signing verification
pref("xpinstall.signatures.required", false);
// enable extensions by default in private mode
pref("extensions.allowPrivateBrowsingByDefault",true);

// disable screenshots extension
pref("extensions.screenshots.disabled", true);
// disable onboarding
pref("browser.onboarding.newtour", "performance,private,addons,customize,default");
pref("browser.onboarding.updatetour", "performance,library,singlesearch,customize");
pref("browser.onboarding.enabled", false);

// New tab settings
pref("browser.newtabpage.activity-stream.default.sites", "https://trisquel.info/,https://www.gnu.org/,https://www.fsf.org/,https://directory.fsf.org,https://libreplanet.org/,https://fsfe.org,https://www.wikipedia.org/wiki/,https://www.wikinews.org/wiki/");
pref("browser.newtabpage.activity-stream.showTopSites",true);
pref("browser.newtabpage.activity-stream.feeds.section.topstories",false);
pref("browser.newtabpage.activity-stream.feeds.snippets",false);
pref("browser.newtabpage.activity-stream.disableSnippets", true);
user_pref("browser.newtabpage.activity-stream.tippyTop.service.endpoint", "");

// Enable xrender
pref("gfx.xrender.enabled",true);

// Disable push notifications
pref("dom.webnotifications.enabled",false);
pref("dom.webnotifications.serviceworker.enabled",false);
pref("dom.push.enabled",false);

// Disable services server
pref("services.settings.server", "");
pref("extensions.blocklist.url", "");

// Disable recommended extensions
pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr", false);
pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
pref("extensions.htmlaboutaddons.discover.enabled", false);
pref("extensions.htmlaboutaddons.recommendations.enabled", false);
//pref("browser.newtabpage.activity-stream.asrouterExperimentEnabled", false);
pref("extensions.getAddons.get.url", "");
pref("extensions.getAddons.link.url", "https://trisquel.info/en/browser-plain");
pref("extensions.getAddons.langpacks.url", "");
pref("extensions.getAddons.discovery.api_url", "");
pref("extensions.recommendations.privacyPolicyUrl", "https://trisquel.info/legal");
pref("extensions.getAddons.search.browseURL", "https://trisquel.info/en/browser-plain?keys=%TERMS%&tid=All");


// Disable pingback on first run
pref("browser.newtabpage.activity-stream.fxaccounts.endpoint", "");


// Disable Normandy (remote settings changer for AB testing)
pref("app.normandy.enabled", false);
pref("app.normandy.api_url", "");
