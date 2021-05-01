#!/bin/bash

WD=$(dirname $0)

files=`find -type f`
while read -r line
do
    sh $WD/deblob-check  $line
done <<< "$files"
