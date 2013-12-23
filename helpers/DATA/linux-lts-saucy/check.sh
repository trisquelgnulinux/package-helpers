#!/bin/bash

files=`find -type f`
while read -r line
do
    ./deblob-check $line
done <<< "$files"
