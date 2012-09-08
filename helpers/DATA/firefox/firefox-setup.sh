#!/bin/bash

set -e

cp build-tree/mozilla/security/coreconf/Linux2.6.mk build-tree/mozilla/security/coreconf/Linux3.0.mk

# Add DDG to search plugins
cat << EOF > build-tree/mozilla/browser/locales/en-US/searchplugins/duckduckgo.xml
<SearchPlugin xmlns="http://www.mozilla.org/2006/browser/search/" xmlns:os="http://a9.com/-/spec/opensearch/1.1/">
<os:ShortName>DuckDuckGo</os:ShortName>
<os:Description>Search DuckDuckGo</os:Description>
<os:InputEncoding>UTF-8</os:InputEncoding>
<os:Image width="16" height="16">data:image/x-icon;base64,AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAAAANcNAADXDQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJyDsJmlk8pf6+v3s/v7+++zr/fcnIOyzJyDsgCcg7CYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAnIOwBJyDscCcg7PZttJ7/7Pfs//////++xO7/S5GA/ycg7P8nIOz2JyDscCcg7AEAAAAAAAAAAAAAAAAnIOwBJyDstScg7P8nIOz/Y8p5/2fHZf9Yv0z/YcF2/1rBUv8nIOz/JyDs/ycg7P8nIOy1JyDsAQAAAAAAAAAAJyDscCcg7P8nIOz/JyDs/4jQoP/p9+n//////05X3v9LkYD/JyDs/ycg7P8nIOz/JyDs/ycg7HAAAAAAJyDsJicg7PYnIOz/JyDs/zUu7f/+/v////////////89N+7/JyDs/yUo7f8nIOz/JyDs/ycg7P8nIOz2JyDsJicg7IAnIOz/JyDs/ycg7P9hXPH////////////t/P//GIr2/wfD+/8Gyfz/DKv5/yM57/8nIOz/JyDs/ycg7H8nIOyzJyDs/ycg7P8nIOz/jov1////////////Otz9/w3G/P8cWfH/JSvt/ycg7P8nIOz/JyDs/ycg7P8nIOyzJyDs5icg7P8nIOz/JyDs/7u5+f///////////27l/v8E0v3/BNL9/wTQ/f8Oofn/IT7v/ycg7P8nIOz/JyDs5icg7OYnIOz/JyDs/ycg7P/p6P3/uWsC////////////5fr//6Po/f8Thfb/DKv5/w6f+f8nIOz/JyDs/ycg7OYnIOyzJyDs/ycg7P8nIOz/9/b+/////////////////7lrAv/V1Pv/JyDs/ycg7P8nIOz/JyDs/ycg7P8nIOyzJyDsgCcg7P8nIOz/JyDs/8/N+///////////////////////iIX1/ycg7P8nIOz/JyDs/ycg7P8nIOz/JyDsfycg7CYnIOz2JyDs/ycg7P9FP+7/q6n4/+7u/f/n5v3/fXn0/yoj7P8nIOz/JyDs/ycg7P8nIOz/JyDs9icg7CYAAAAAJyDscCcg7P8nIOz/wsD6/+no/f/Y1/z/eHTz/ycg7P8nIOz/JyDs/ycg7P8nIOz/JyDs/ycg7HAAAAAAAAAAACcg7AEnIOy1JyDs/ycg7P8nIOz/JyDs/ycg7P8nIOz/JyDs/ycg7P8nIOz/JyDs/ycg7LUnIOwBAAAAAAAAAAAAAAAAJyDsAScg7HAnIOz2JyDs/ycg7P8nIOz/JyDs/ycg7P8nIOz/JyDs9icg7HAnIOwBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJyDsJicg7IAnIOyzJyDs5icg7OYnIOyzJyDsgCcg7CYAAAAAAAAAAAAAAAAAAAAA+B8AAPAPAADAAwAAwAMAAIABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAABAACAAQAAwAMAAMADAADwDwAA+B8AAA==</os:Image>
<os:Url type="text/html" method="GET" template="http://duckduckgo.com/?q={searchTerms}">
</os:Url>
</SearchPlugin>
EOF

cat << EOF > build-tree/mozilla/browser/locales/en-US/searchplugins/duckduckgo-ssl.xml
<SearchPlugin xmlns="http://www.mozilla.org/2006/browser/search/" xmlns:os="http://a9.com/-/spec/opensearch/1.1/">
<os:ShortName>DuckDuckGo (SSL)</os:ShortName>
<os:Description>Search DuckDuckGo (SSL)</os:Description>
<os:InputEncoding>UTF-8</os:InputEncoding>
<os:Image width="16" height="16">data:image/x-icon;base64,AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAAAANcNAADXDQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJyDsJmlk8pf6+v3s/v7+++zr/fcnIOyzJyDsgCcg7CYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAnIOwBJyDscCcg7PZttJ7/7Pfs//////++xO7/S5GA/ycg7P8nIOz2JyDscCcg7AEAAAAAAAAAAAAAAAAnIOwBJyDstScg7P8nIOz/Y8p5/2fHZf9Yv0z/YcF2/1rBUv8nIOz/JyDs/ycg7P8nIOy1JyDsAQAAAAAAAAAAJyDscCcg7P8nIOz/JyDs/4jQoP/p9+n//////05X3v9LkYD/JyDs/ycg7P8nIOz/JyDs/ycg7HAAAAAAJyDsJicg7PYnIOz/JyDs/zUu7f/+/v////////////89N+7/JyDs/yUo7f8nIOz/JyDs/ycg7P8nIOz2JyDsJicg7IAnIOz/JyDs/ycg7P9hXPH////////////t/P//GIr2/wfD+/8Gyfz/DKv5/yM57/8nIOz/JyDs/ycg7H8nIOyzJyDs/ycg7P8nIOz/jov1////////////Otz9/w3G/P8cWfH/JSvt/ycg7P8nIOz/JyDs/ycg7P8nIOyzJyDs5icg7P8nIOz/JyDs/7u5+f///////////27l/v8E0v3/BNL9/wTQ/f8Oofn/IT7v/ycg7P8nIOz/JyDs5icg7OYnIOz/JyDs/ycg7P/p6P3/uWsC////////////5fr//6Po/f8Thfb/DKv5/w6f+f8nIOz/JyDs/ycg7OYnIOyzJyDs/ycg7P8nIOz/9/b+/////////////////7lrAv/V1Pv/JyDs/ycg7P8nIOz/JyDs/ycg7P8nIOyzJyDsgCcg7P8nIOz/JyDs/8/N+///////////////////////iIX1/ycg7P8nIOz/JyDs/ycg7P8nIOz/JyDsfycg7CYnIOz2JyDs/ycg7P9FP+7/q6n4/+7u/f/n5v3/fXn0/yoj7P8nIOz/JyDs/ycg7P8nIOz/JyDs9icg7CYAAAAAJyDscCcg7P8nIOz/wsD6/+no/f/Y1/z/eHTz/ycg7P8nIOz/JyDs/ycg7P8nIOz/JyDs/ycg7HAAAAAAAAAAACcg7AEnIOy1JyDs/ycg7P8nIOz/JyDs/ycg7P8nIOz/JyDs/ycg7P8nIOz/JyDs/ycg7LUnIOwBAAAAAAAAAAAAAAAAJyDsAScg7HAnIOz2JyDs/ycg7P8nIOz/JyDs/ycg7P8nIOz/JyDs9icg7HAnIOwBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJyDsJicg7IAnIOyzJyDs5icg7OYnIOyzJyDsgCcg7CYAAAAAAAAAAAAAAAAAAAAA+B8AAPAPAADAAwAAwAMAAIABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAABAACAAQAAwAMAAMADAADwDwAA+B8AAA==</os:Image>
<os:Url type="text/html" method="GET" template="https://duckduckgo.com/?q={searchTerms}">
</os:Url>
</SearchPlugin>
EOF

if ! grep -q duckduckgo build-tree/mozilla/browser/locales/en-US/searchplugins/list.txt
then
    echo duckduckgo >> build-tree/mozilla/browser/locales/en-US/searchplugins/list.txt
    echo duckduckgo-ssl >> build-tree/mozilla/browser/locales/en-US/searchplugins/list.txt
fi

#Disable missingPluginInstaller
sed -i 's/\(^.*missingPluginInstaller\.prototype.*$\)/\1\nreturn;/; s/\(^.*get the urls of missing plugins.*$\)/\1\nreturn;/'  build-tree/mozilla/browser/base/content/browser.js

cp debian/default*.png build-tree/mozilla/browser/app/
cp debian/default*.png build-tree/mozilla/browser/branding/unofficial/
cp debian/default*.png build-tree/mozilla/browser/branding/awesome-browser/
cp debian/default*.png build-tree/mozilla/other-licenses/branding/firefox/
cp debian/default*.png build-tree/mozilla/xulrunner/app/

#Hides the link to mozilla.org in the search engine manager
sed -i 's/\(.*addEngine.label.*\)/\1 hidden="true"/' build-tree/mozilla/browser/components/search/content/engineManager.xul
sed -i 's/\(.*releaseNotes.*\)/\1 hidden="true"/' build-tree/mozilla/browser/base/content/baseMenuOverlay.xul

# This file hides the search form in the extensions manager
cat << EOF > build-tree/mozilla/browser/locales/en-US/profile/localstore.rdf
<?xml version="1.0"?>
<RDF:RDF xmlns:NC="http://home.netscape.com/NC-rdf#"
         xmlns:RDF="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <RDF:Description RDF:about="chrome://browser/content/browser.xul">
    <NC:persist RDF:resource="chrome://browser/content/browser.xul#main-window"/>
    <NC:persist RDF:resource="chrome://browser/content/browser.xul#sidebar-box"/>
    <NC:persist RDF:resource="chrome://browser/content/browser.xul#sidebar-title"/>
    <NC:persist RDF:resource="chrome://browser/content/browser.xul#toolbar-menubar"/>
    <NC:persist RDF:resource="chrome://browser/content/browser.xul#nav-bar"/>
    <NC:persist RDF:resource="chrome://browser/content/browser.xul#PersonalToolbar"/>
  </RDF:Description>
  <RDF:Description RDF:about="chrome://browser/content/browser.xul#main-window"
                   sizemode="maximized"
                   width="610"
                   height="450" />
  <RDF:Description RDF:about="chrome://mozapps/content/extensions/extensions.xul#viewGroup"
                   last-selected="extensions" />
  <RDF:Description RDF:about="chrome://mozapps/content/extensions/extensions.xul#extensions-view"
                   selected="true" />
  <RDF:Description RDF:about="chrome://browser/content/browser.xul#PersonalToolbar"
                   currentset="new-tab-button,personal-bookmarks" />
  <RDF:Description RDF:about="chrome://mozapps/content/extensions/extensions.xul#extensionsManager"
                   width="520"
                   height="380"
                   sizemode="normal"
                   screenX="1"
                   screenY="48" />
  <RDF:Description RDF:about="chrome://mozapps/content/extensions/extensions.xul">
    <NC:persist RDF:resource="chrome://mozapps/content/extensions/extensions.xul#search-view"/>
    <NC:persist RDF:resource="chrome://mozapps/content/extensions/extensions.xul#viewGroup"/>
    <NC:persist RDF:resource="chrome://mozapps/content/extensions/extensions.xul#extensionsManager"/>
    <NC:persist RDF:resource="chrome://mozapps/content/extensions/extensions.xul#extensions-view"/>
  </RDF:Description>
  <RDF:Description RDF:about="chrome://browser/content/browser.xul#toolbar-menubar"
                   currentset="menubar-items,spring,throbber-box" />
  <RDF:Description RDF:about="chrome://global/content/customizeToolbar.xul">
    <NC:persist RDF:resource="chrome://global/content/customizeToolbar.xul#CustomizeToolbarWindow"/>
  </RDF:Description>
  <RDF:Description RDF:about="chrome://global/content/customizeToolbar.xul#CustomizeToolbarWindow"
                   width="636"
                   height="400" />
  <RDF:Description RDF:about="chrome://browser/content/browser.xul#nav-bar"
                   currentset="unified-back-forward-button,back-button,forward-button,reload-button,stop-button,home-button,urlbar-container,search-container" />
  <RDF:Description RDF:about="chrome://browser/content/browser.xul#sidebar-title"
                   value="" />
</RDF:RDF>
EOF

cat << EOF > build-tree/mozilla/browser/branding/awesome-browser/locales/browserconfig.properties
# Do NOT localize or otherwise change these values
browser.startup.homepage=http://trisquel.info/
EOF

cat << EOF >> build-tree/mozilla/browser/app/profile/firefox.js
pref("app.support.baseURL", "http://trisquel.info/wiki/");
pref("xpinstall.whitelist.add", "trisquel.info");
EOF

cat << EOF >> build-tree/mozilla/browser/branding/awesome-browser/pref/firefox-branding.js
pref("app.releaseNotesURL", "http://trisquel.info/newbrowser");
EOF

cat << EOF >> build-tree/mozilla/browser/app/firefox-branding.js
pref("app.releaseNotesURL", "http://trisquel.info/newbrowser");
EOF

#Trisquel custom bookmarks
sed -i /ubuntu_bookmarks/d debian/patches/series
cat << EOF > build-tree/mozilla/browser/locales/generic/profile/bookmarks.html.in
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!-- This is an automatically generated file.
     It will be read and overwritten.
     DO NOT EDIT! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<TITLE>Bookmarks</TITLE>
<H1>Bookmarks Menu</H1>

<DL><p>
    <DT><H3 ADD_DATE="1245542278" LAST_MODIFIED="1245543070" PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Toolbar</H3>
<DD>Add bookmarks to this folder to see them displayed on the Bookmarks Toolbar
    <DL><p>
	<HR>
        <DT><A HREF="http://trisquel.info/" ADD_DATE="1245542718" LAST_MODIFIED="1245542736" ICON_URI="http://trisquel.info/sites/default/themes/trisquel2/favicon.ico" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACi0lEQVQ4jY2T3UtTARiH92/0DxR0E10EZTeBF3VhBEqF9EEXUURUpn2AmohNS60oUrRMQ1D86ItKKz+atjmd25w5S82zlXPOqfNsc27nzOPOeboQJlakL/xuXnifi+d9Xx1bLEVZxTHhxzjsRZJXkn3dVob9gQhp+d1kFhs5rv9C6s1ufnjEjQDHhJ+bNXbOlJsprHfwyxdMAgrrHbzvcxONxXF7F6l47eRUaR+qqq4BWgwCO85+5KjeyMm7Jraf62DnhU5aDZMA3KodJByR0DSNmjdDCFML7L/Wy4IYQReNxUm52oXB7sEzG6Lb5sEx7uNgXi8pOT04JuYwO308bB3mrclNfbuTFoNAWoGJmLSCzusPcij3M6GlGJUvhzDYpymuH6Tvq5cDuX0cKzHjW1jCMxtk1DWPecRLZqkFfcPwmoNgOMrhgl5m5sJJu2UNVqZnRY7oLaSXWDlRZuFGjZ3LlVYOFpg5c6+fxVB0XeLjV07OP7LwosfFs7YxGjvGsI3Nkl5iJTW/nz3Zvey+1Mm+rA7y6uyEI9LGNWqahlOY59Ogh1HXPAA51Va2ne4gv86GazqQlPhn/fMOFCXB3qxOMu+YCASXud80RNFzC7Yx/9YAYijKrotd1LZP8OTtKG6viCSvcL16AGF6cXNATFohJbubqnffefruG+M/51FVlWaDQE3b+OYAgOyqQTKKTATEZT6YXQieAOXNIzR2Tf4N0DQNVVVZXV1FURQURcHrF8m4beTsgwFaewTKm0c4qjcy5RNJJBJJoTpN04jH40QiEUKhEKIoJuOemuFBs40rFWbuN9kYFzwEg0HC4TCSJK3/QiKRQJZlZFkmHo//N7IsI0kSiqKgaRq/AbKDgxgo7zYPAAAAAElFTkSuQmCC">Trisquel GNU/Linux</A>
        <DT><A HREF="http://trisquel.info/wiki/" ADD_DATE="1245542718" LAST_MODIFIED="1245542736" ICON_URI="http://trisquel.info/sites/default/themes/trisquel2/favicon.ico" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACi0lEQVQ4jY2T3UtTARiH92/0DxR0E10EZTeBF3VhBEqF9EEXUURUpn2AmohNS60oUrRMQ1D86ItKKz+atjmd25w5S82zlXPOqfNsc27nzOPOeboQJlakL/xuXnifi+d9Xx1bLEVZxTHhxzjsRZJXkn3dVob9gQhp+d1kFhs5rv9C6s1ufnjEjQDHhJ+bNXbOlJsprHfwyxdMAgrrHbzvcxONxXF7F6l47eRUaR+qqq4BWgwCO85+5KjeyMm7Jraf62DnhU5aDZMA3KodJByR0DSNmjdDCFML7L/Wy4IYQReNxUm52oXB7sEzG6Lb5sEx7uNgXi8pOT04JuYwO308bB3mrclNfbuTFoNAWoGJmLSCzusPcij3M6GlGJUvhzDYpymuH6Tvq5cDuX0cKzHjW1jCMxtk1DWPecRLZqkFfcPwmoNgOMrhgl5m5sJJu2UNVqZnRY7oLaSXWDlRZuFGjZ3LlVYOFpg5c6+fxVB0XeLjV07OP7LwosfFs7YxGjvGsI3Nkl5iJTW/nz3Zvey+1Mm+rA7y6uyEI9LGNWqahlOY59Ogh1HXPAA51Va2ne4gv86GazqQlPhn/fMOFCXB3qxOMu+YCASXud80RNFzC7Yx/9YAYijKrotd1LZP8OTtKG6viCSvcL16AGF6cXNATFohJbubqnffefruG+M/51FVlWaDQE3b+OYAgOyqQTKKTATEZT6YXQieAOXNIzR2Tf4N0DQNVVVZXV1FURQURcHrF8m4beTsgwFaewTKm0c4qjcy5RNJJBJJoTpN04jH40QiEUKhEKIoJuOemuFBs40rFWbuN9kYFzwEg0HC4TCSJK3/QiKRQJZlZFkmHo//N7IsI0kSiqKgaRq/AbKDgxgo7zYPAAAAAElFTkSuQmCC">Wiki</A>
        <DT><A HREF="http://trisquel.info/donate" ADD_DATE="1245542718" LAST_MODIFIED="1245542736" ICON_URI="http://trisquel.info/sites/default/themes/trisquel2/favicon.ico" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACi0lEQVQ4jY2T3UtTARiH92/0DxR0E10EZTeBF3VhBEqF9EEXUURUpn2AmohNS60oUrRMQ1D86ItKKz+atjmd25w5S82zlXPOqfNsc27nzOPOeboQJlakL/xuXnifi+d9Xx1bLEVZxTHhxzjsRZJXkn3dVob9gQhp+d1kFhs5rv9C6s1ufnjEjQDHhJ+bNXbOlJsprHfwyxdMAgrrHbzvcxONxXF7F6l47eRUaR+qqq4BWgwCO85+5KjeyMm7Jraf62DnhU5aDZMA3KodJByR0DSNmjdDCFML7L/Wy4IYQReNxUm52oXB7sEzG6Lb5sEx7uNgXi8pOT04JuYwO308bB3mrclNfbuTFoNAWoGJmLSCzusPcij3M6GlGJUvhzDYpymuH6Tvq5cDuX0cKzHjW1jCMxtk1DWPecRLZqkFfcPwmoNgOMrhgl5m5sJJu2UNVqZnRY7oLaSXWDlRZuFGjZ3LlVYOFpg5c6+fxVB0XeLjV07OP7LwosfFs7YxGjvGsI3Nkl5iJTW/nz3Zvey+1Mm+rA7y6uyEI9LGNWqahlOY59Ogh1HXPAA51Va2ne4gv86GazqQlPhn/fMOFCXB3qxOMu+YCASXud80RNFzC7Yx/9YAYijKrotd1LZP8OTtKG6viCSvcL16AGF6cXNATFohJbubqnffefruG+M/51FVlWaDQE3b+OYAgOyqQTKKTATEZT6YXQieAOXNIzR2Tf4N0DQNVVVZXV1FURQURcHrF8m4beTsgwFaewTKm0c4qjcy5RNJJBJJoTpN04jH40QiEUKhEKIoJuOemuFBs40rFWbuN9kYFzwEg0HC4TCSJK3/QiKRQJZlZFkmHo//N7IsI0kSiqKgaRq/AbKDgxgo7zYPAAAAAElFTkSuQmCC">Donate</A>
        <DT><A HREF="http://store.trisquel.info/" ADD_DATE="1245542718" LAST_MODIFIED="1245542736" ICON_URI="http://trisquel.info/sites/default/themes/trisquel2/favicon.ico" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACi0lEQVQ4jY2T3UtTARiH92/0DxR0E10EZTeBF3VhBEqF9EEXUURUpn2AmohNS60oUrRMQ1D86ItKKz+atjmd25w5S82zlXPOqfNsc27nzOPOeboQJlakL/xuXnifi+d9Xx1bLEVZxTHhxzjsRZJXkn3dVob9gQhp+d1kFhs5rv9C6s1ufnjEjQDHhJ+bNXbOlJsprHfwyxdMAgrrHbzvcxONxXF7F6l47eRUaR+qqq4BWgwCO85+5KjeyMm7Jraf62DnhU5aDZMA3KodJByR0DSNmjdDCFML7L/Wy4IYQReNxUm52oXB7sEzG6Lb5sEx7uNgXi8pOT04JuYwO308bB3mrclNfbuTFoNAWoGJmLSCzusPcij3M6GlGJUvhzDYpymuH6Tvq5cDuX0cKzHjW1jCMxtk1DWPecRLZqkFfcPwmoNgOMrhgl5m5sJJu2UNVqZnRY7oLaSXWDlRZuFGjZ3LlVYOFpg5c6+fxVB0XeLjV07OP7LwosfFs7YxGjvGsI3Nkl5iJTW/nz3Zvey+1Mm+rA7y6uyEI9LGNWqahlOY59Ogh1HXPAA51Va2ne4gv86GazqQlPhn/fMOFCXB3qxOMu+YCASXud80RNFzC7Yx/9YAYijKrotd1LZP8OTtKG6viCSvcL16AGF6cXNATFohJbubqnffefruG+M/51FVlWaDQE3b+OYAgOyqQTKKTATEZT6YXQieAOXNIzR2Tf4N0DQNVVVZXV1FURQURcHrF8m4beTsgwFaewTKm0c4qjcy5RNJJBJJoTpN04jH40QiEUKhEKIoJuOemuFBs40rFWbuN9kYFzwEg0HC4TCSJK3/QiKRQJZlZFkmHo//N7IsI0kSiqKgaRq/AbKDgxgo7zYPAAAAAElFTkSuQmCC">Store</A>
        <DT><A FEEDURL="http://trisquel.info/en/planet/rss" HREF="http://trisquel.info/en/planet">Planet</A>
        <DT><A HREF="http://identi.ca/group/trisquel" ADD_DATE="1262084293" ICON_URI="http://identi.ca/favicon.ico" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABEElEQVQ4jZWTsW3EMAxF3wgeQSNkBI2QETyCR1BnII7BLl2gAVyovkrXpbur3B3gwgMYmYBpYkPS2QaOABtJ/4miPiEJB1UPTmAS0CQnAWnBcBSf8C6wFMIylx7qI/GZMMsM4qAqbx6s1dF7nWPUm4gO1j5Vsj3n/83b5o9zuheXui4hHoC0YYO1u+I1ikqWFbAtPkI4BdxEsipaMBlgjvEUMMeYATqwL1Uwep8BPuCN9AcudX0KuDZNBlh74NPF0ftDwCOEFBAAaMGURrk2zdaP1Qu/06Sqql9VtZ6Lm5lKLxzltzEpQB1UG0RAXrHzk6UBOrAC9wPBfWdKw+5ktmA6sD24Dmw6xi2YHhqBIKB/yV7X1RXblbAAAAAASUVORK5CYII=">@identi.ca</A>
	<HR>
        <DT><A HREF="http://www.gnu.org/" ADD_DATE="1245542746" LAST_MODIFIED="1245542763" ICON_URI="http://www.gnu.org/graphics/gnu-head-mini.png" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAAGFBMVEVFRUV+fn6mpqa/v7/Ozs7Y2Njg4OD8/Pwuhn+TAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAALEQAACxEBf2RfkQAAAAd0SU1FB9MBDhQ6Gd8s57cAAAEkSURBVHicXdFNc4JADAbgoP0Bi4d6dcGBMzp2z2rrnjulcsavnKuQ9+83K37vDAN5yIZsILws0uv3i7ugLTnAwpjBOsTLOE4VmmKQTFYBioGNKkI5drcCReRItmNAyinSCjianJo6A/aGRtRjtPadpB5CRkQRUaYPGbXW4UgKMfXQxDnJPIeJ0qyOrclrLXoqou8+5p7HM9EkT/JtyEsqB2QYnRv7sT2ArRPLf0kWOp1sA3hYPq3Oh/t0EAjjVIG703II9awr3l3BhxAf5foMLaaasPEZqm5A+0RzGCmuIKJbWi284csIJbzykBQ3aIADsL2CFtBWpovhA1Td7Q6NzqZ/B+38APG3HxU+sYO4B9Akt+AnqGbp/gmwTN6eAWt+gcv6B4rivVin0bWbAAAAAElFTkSuQmCC">GNU&#39;s not UNIX!</A>
        <DT><A FEEDURL="http://planet.gnu.org/atom.xml" HREF="http://planet.gnu.org/">GNU Planet</A>
 <DT><A HREF="http://www.fsf.org/" ADD_DATE="1245542771" LAST_MODIFIED="1245542780" ICON_URI="http://www.fsf.org/favicon.ico" ICON="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAACXBIWXMAAAsTAAALEwEAmpwYAAADG0lEQVQoFQEQA+/8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQECAAAAAAAAAAAAAAAAAAAA2qOp7tTXAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAP///wAAAAAAAOCyt7pUXQcSEgcQDwAAAP///wAAAAAAAAD//x9NSDqNhQEBAQQAAAAAAAAAAAAAAAAQJiQGDQ0aPToZPjoAAQEAAAAAAAAAAAABAQEpZV4AAAAAAAAAAAAA////////////////pSIv05KZ////////////////////////////////AAAAAQAAAP///6krNwAAAAAAAPHc3ggSEQcSEQAAAAAAAAAAABY3NEGelQAAAAAAAAEBAQEAAAD///+YARAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGDg1g690CBgYAAAABAQEEAAAAAAAAS7etAAAAAAAAwGVtHklFIlJOAAAAAAAAAAAAAAAA+/X2BwYGAAAAAAAABAAAAAAAAB1IQwAAAAAAAAYNDBAmJB1IQwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAgL//v4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAQEB//7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAECAv/+/gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD////////////////cqK3qzM////////////////////////////////8AAAABAAAA////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGuLjDf9F8oBAAAAAElFTkSuQmCC">Free Software Foundation</A>
    </DL><p>
</DL><p>
EOF
