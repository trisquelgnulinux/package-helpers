#!/bin/bash

WD=$(dirname $0)

files=`find -type f`
while read -r line
do
    sh $WD/deblob-check --use-awk -C $line
done <<< "$files"
