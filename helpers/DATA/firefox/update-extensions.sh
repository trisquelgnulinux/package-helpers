#!/bin/bash

set -e

for extension in 607454; do

rm -rf /tmp/update-extension
mkdir /tmp/update-extension
(cd /tmp/update-extension
wget -O extension.xpi https://addons.mozilla.org/firefox/downloads/latest/$extension/addon-${extension}-latest.xpi
unzip extension.xpi
)


if [ -f /tmp/update-extension/install.rdf ]; then
ID=$(grep em:id /tmp/update-extension/install.rdf |sed 's/.*<em:id>//; s/<.*//' |head -n1)
fi
if [ -f /tmp/update-extension/manifest.json ]; then
ID=$(grep '"id":' /tmp/update-extension/manifest.json |head -n1|cut -d \" -f 4)
fi

mv  /tmp/update-extension/extension.xpi extensions/$ID.xpi


done
