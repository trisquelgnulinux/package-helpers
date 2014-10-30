/*

Copyright (c) 2014, Ruben Rodriguez <ruben@gnu.org>
Copyright (c) 2013, The Tor Project, Inc.
Copyright (c) 2006 Scott Squires, Oleg Ivanov

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

*/

// Module specific constants
const kMODULE_NAME = "about:abrowser";
const kMODULE_CONTRACTID = "@mozilla.org/network/protocol/about;1?what=abrowser";
const kMODULE_CID = Components.ID("a364a9c0-2960-11e4-8c21-0800200c9a66");

const kAboutAbrowserURL = "chrome://abrowserhome/content/aboutAbrowser/aboutAbrowser.xhtml";

const Cc = Components.classes;
const Ci = Components.interfaces;
const Cu = Components.utils;
 
Cu.import("resource://gre/modules/XPCOMUtils.jsm");
 
function AboutAbrowser()
{
}


AboutAbrowser.prototype =
{
  QueryInterface: XPCOMUtils.generateQI([Ci.nsIAboutModule]),

  // nsIClassInfo implementation:
  classDescription: kMODULE_NAME,
  classID: kMODULE_CID,
  contractID: kMODULE_CONTRACTID,

  // nsIAboutModule implementation:
  newChannel: function(aURI)
  {
    let ioSvc = Cc["@mozilla.org/network/io-service;1"]
                  .getService(Ci.nsIIOService);
    let channel = ioSvc.newChannel(kAboutAbrowserURL, null, null);
    channel.originalURI = aURI;

    return channel;
  },

  getURIFlags: function(aURI)
  {
    return Ci.nsIAboutModule.ALLOW_SCRIPT;
  }
};


const NSGetFactory = XPCOMUtils.generateNSGetFactory([AboutAbrowser]);
