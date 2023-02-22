#! /usr/bin/python3

#    Copyright (C) 2020, 2021  grizzlyuser <grizzlyuser@protonmail.com>
#    Copyright (C) 2020, 2021  Ruben Rodriguez <ruben@trisquel.info>
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
import time
import copy
import argparse
import pathlib
from collections import namedtuple
from jsonschema import validate

parser = argparse.ArgumentParser()
parser.add_argument(
    'MAIN_PATH',
    type=pathlib.Path,
    help='path to main application source code directory')
parser.add_argument(
    'BRANDING_PATH',
    type=pathlib.Path,
    help='path to branding source code directory')
parser.add_argument(
    '-i',
    '--indent',
    type=int,
    default=2,
    help='indent for pretty printing of output files')
arguments = parser.parse_args()

File = namedtuple('File', ['path', 'content'])


class RemoteSettings:
    DUMPS_PATH_RELATIVE = 'services/settings/dumps'
    DUMPS_PATH_ABSOLUTE = arguments.MAIN_PATH / DUMPS_PATH_RELATIVE

    _WRAPPER_NAME = 'data'
    _LAST_MODIFIED_KEY_NAME = 'last_modified'

    @classmethod
    def get_collection_timestamp(cls, collection):
        return max((record[cls._LAST_MODIFIED_KEY_NAME]
                   for record in collection.content), default=0)

    @classmethod
    def wrap(cls, processed):
        return File(processed.path,
                    {cls._WRAPPER_NAME: processed.content,
                     'timestamp': cls.get_collection_timestamp(processed)})

    @classmethod
    def unwrap(cls, parsed_jsons):
        return [File(json.path, json.content[cls._WRAPPER_NAME])
                for json in parsed_jsons]

    @classmethod
    def should_modify_collection(cls, collection):
        return True

    @classmethod
    def now(cls):
        return int(round(time.time() / 10 ** 6))

    @classmethod
    def process_raw(cls, unwrapped_jsons, parsed_schema):
        timestamps, result = [], []
        for collection in unwrapped_jsons:
            should_modify_collection = cls.should_modify_collection(collection)
            for record in collection.content:
                if should_modify_collection:
                    if cls.should_drop_record(record):
                        continue

                    clone = copy.deepcopy(record)

                    record = cls.process_record(record)

                    if clone != record:
                        timestamp = cls.now()
                        while timestamp in timestamps:
                            timestamp += 1
                        timestamps.append(timestamp)
                        record[cls._LAST_MODIFIED_KEY_NAME] = timestamp

                if parsed_schema is not None:
                    validate(record, schema=parsed_schema)

                result.append(record)

        result.sort(
            key=lambda record: record[cls._LAST_MODIFIED_KEY_NAME], reverse=True)
        cls.OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

        return File(cls.OUTPUT_PATH, result)

    @classmethod
    def process(cls, parsed_jsons, parsed_schema):
        return cls.wrap(
            cls.process_raw(
                cls.unwrap(parsed_jsons),
                parsed_schema))


class Changes(RemoteSettings):
    JSON_PATHS = tuple(RemoteSettings.DUMPS_PATH_ABSOLUTE.glob('*/*.json'))
    OUTPUT_PATH = RemoteSettings.DUMPS_PATH_ABSOLUTE / 'monitor/changes'

    @classmethod
    def wrap(cls, processed):
        return File(
            processed.path, {
                'changes': processed.content, 'timestamp': cls.now()})

    @classmethod
    def process_raw(cls, unwrapped_jsons, parsed_schema):
        changes = []

        for collection in unwrapped_jsons:
            if collection.path != RemoteSettings.DUMPS_PATH_ABSOLUTE / 'main/example.json':
                latest_change = {}
                latest_change[cls._LAST_MODIFIED_KEY_NAME] = cls.get_collection_timestamp(
                    collection)
                latest_change['bucket'] = collection.path.parent.name
                latest_change['collection'] = collection.path.stem
                changes.append(latest_change)

        cls.OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

        return File(cls.OUTPUT_PATH, changes)


class SearchConfig(RemoteSettings):
    JSON_PATHS = (
        RemoteSettings.DUMPS_PATH_ABSOLUTE /
        'main/search-config.json',
    )
    SCHEMA_PATH = arguments.MAIN_PATH / \
        'toolkit/components/search/schema/search-engine-config-schema.json'
    OUTPUT_PATH = JSON_PATHS[0]

    _DUCKDUCKGO_SEARCH_ENGINE_ID = 'ddg@search.mozilla.org'

    @classmethod
    def should_drop_record(cls, search_engine):
        return search_engine['webExtension']['id'] not in (
            cls._DUCKDUCKGO_SEARCH_ENGINE_ID, 'wikipedia@search.mozilla.org',
            'trisquel@search.mozilla.org', 'trisquel-packages@@search.mozilla.org',
            'wiktionary@search.mozilla.org', 'qwant@search.mozilla.org',
            'ecosia@search.mozilla.org')

    @classmethod
    def process_record(cls, search_engine):
        [search_engine.pop(key, None)
         for key in ['extraParams', 'telemetryId']]

        general_specifier = {}
        for specifier in search_engine['appliesTo'].copy():
            if 'application' in specifier:
                if 'distributions' in specifier['application']:
                    search_engine['appliesTo'].remove(specifier)
                    continue
                specifier['application'].pop('extraParams', None)

            if 'included' in specifier and 'everywhere' in specifier[
                    'included'] and specifier['included']['everywhere']:
                if search_engine['webExtension']['id'] == cls._DUCKDUCKGO_SEARCH_ENGINE_ID:
                    specifier['default'] = 'yes'
                general_specifier = specifier

        if not general_specifier:
            general_specifier = {'included': {'everywhere': True}}
            search_engine['appliesTo'].insert(0, general_specifier)
        if search_engine['webExtension']['id'] == cls._DUCKDUCKGO_SEARCH_ENGINE_ID:
            general_specifier['default'] = 'yes'

        return search_engine


class TippyTopSites:
    JSON_PATHS = (
        arguments.MAIN_PATH /
        'browser/components/newtab/data/content/tippytop/top_sites.json',
        arguments.BRANDING_PATH /
        'tippytop/top_sites.json')

    @classmethod
    def process(cls, parsed_jsons, parsed_schema):
        tippy_top_sites_main = parsed_jsons[0]
        tippy_top_sites_branding = parsed_jsons[1]
        result = tippy_top_sites_branding.content + \
            [site for site in tippy_top_sites_main.content if 'wikipedia.org' in site['domains']]
        return File(tippy_top_sites_main.path, result)


class TopSites(RemoteSettings):
    _TOP_SITES_JSON_PATH = 'main/top-sites.json'
    _TOP_SITES_PATH_MAIN = RemoteSettings.DUMPS_PATH_ABSOLUTE / _TOP_SITES_JSON_PATH

    JSON_PATHS = (
        arguments.BRANDING_PATH /
        RemoteSettings.DUMPS_PATH_RELATIVE /
        _TOP_SITES_JSON_PATH,
        _TOP_SITES_PATH_MAIN)
    OUTPUT_PATH = _TOP_SITES_PATH_MAIN

    @classmethod
    def should_modify_collection(cls, collection):
        return cls._TOP_SITES_PATH_MAIN == collection.path

    @classmethod
    def should_drop_record(cls, site):
        return site['url'] != 'https://www.wikipedia.org/'

    @classmethod
    def process_record(cls, site):
        site.pop('exclude_regions', None)
        return site


# To reflect the latest timestamps, Changes class should always come after
# all other RemoteSettings subclasses
processors = (SearchConfig, Changes)

for processor in processors:
    parsed_jsons = []
    for json_path in processor.JSON_PATHS:
        with json_path.open(encoding='utf-8') as file:
            parsed_jsons.append(File(json_path, json.load(file)))

    parsed_schema = None
    if hasattr(processor, "SCHEMA_PATH"):
        with processor.SCHEMA_PATH.open() as file:
            parsed_schema = json.load(file)

    processed = processor.process(parsed_jsons, parsed_schema)
    with processed.path.open('w') as file:
        json.dump(processed.content, file, indent=arguments.indent)
