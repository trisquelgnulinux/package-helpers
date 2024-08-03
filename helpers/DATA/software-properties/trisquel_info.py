#
#    Copyright (C) 2024 Luis Guzman <ark@switnet.org>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
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
#

# replaced lsb_release in favor of distro
import csv
from datetime import datetime
from distro import distro

release_name = distro.codename()
release_description = distro.name(pretty=True)
#print(release_name)
#print(release_description)

def trisquel_eol():
        with open('/usr/share/distro-info/trisquel.csv', 'r') as distro_data:
                trisquel_distro_data = csv.DictReader(distro_data)
                for line in trisquel_distro_data:
                        if line['series'] == (release_name):
                                eol_datetime = datetime.strptime(line['eol'], '%Y-%m-%d')
                                eol_date = eol_datetime.date()
                                return eol_date
def trisquel_upstream():
    with open('/usr/share/distro-info/trisquel.csv', 'r') as distro_data:
                trisquel_distro_data = csv.DictReader(distro_data)
                for line in trisquel_distro_data:
                        if line['series'] == (release_name):
                                codename_upstream = line['upstream']
                                return(codename_upstream)

trisquel_rel_desc = release_description
trisquel_eol = trisquel_eol()
trisquel_upstream_rel = trisquel_upstream()
