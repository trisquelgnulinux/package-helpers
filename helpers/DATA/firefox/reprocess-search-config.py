#! /usr/bin/python3

#    Copyright (C) 2020  Ruben Rodriguez <ruben@trisquel.info>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

import json
import sys

data={}

with open(sys.argv[1]) as f:
  data=json.load(f)

  whitelist=['ddg@search.mozilla.org','google@search.mozilla.org','wikipedia@search.mozilla.org','bing@search.mozilla.org']

  i=0
  newdata={"data":[]}
  trisquel={}

  for item in data["data"]:
    if item["webExtension"]["id"] in whitelist:
      item["appliesTo"][0]["included"]["everywhere"]=True
      item["appliesTo"][0]["default"]="no"
      if item["webExtension"]["id"] == 'ddg@search.mozilla.org':
        item["appliesTo"][0]["default"]="yes"
        item["appliesTo"][0]["orderHint"]=5000
        item["appliesTo"][0]["override"]=True
#        del item["appliesTo"][1]["application"]["distributions"]
#        del item["appliesTo"][1]["extraParams"]
#        del item["extraParams"]
      newdata["data"].append(item)
    i+=1
  trisquel={u'webExtension': {u'id': u'trisquel@search.mozilla.org'}, u'appliesTo': [{u'included': {u'everywhere': True}, 'default': 'no'}, {u'override': True, u'application': {'override': True, 'orderHint': 4000}}], u'id': u'4341e834-7290-4d33-beb0-377c04a49566', u'last_modified': 1595254832054, u'telemetryId': u'trisquel', u'schema': 1594312388241}
  ddghtml={u'webExtension': {u'id': u'ddg-html@search.mozilla.org'}, u'appliesTo': [{u'included': {u'everywhere': True}, 'default': 'no'}, {u'override': True, u'application': {'override': True, 'orderHint': 3000}}], u'id': u'55bf6437-3b82-41a6-98be-09c3b53b5b4d', u'last_modified': 1595254832054, u'telemetryId': u'ddg-html', u'schema': 1594312388241}
  newdata["data"].append(trisquel)
  newdata["data"].append(ddghtml)

with open(sys.argv[1], 'w') as outfile:
    json.dump(newdata, outfile, indent=4)
