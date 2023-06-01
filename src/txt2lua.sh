#!/bin/bash

TEXTPATH="./../zh_cn_text"

for file in $(ls $TEXTPATH/*.lua)
do
    mv $file ${file%.txt}.lua
done

sed -i '1i\return' $TEXTPATH/*.lua