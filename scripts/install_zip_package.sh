#!/bin/bash

export ZIP_URL=$1
export TARGET_DIR=$2
export TMP_FILE=/tmp/download.zip

mkdir -p $TARGET_DIR
wget -O $TMP_FILE $ZIP_URL
unzip $TMP_FILE -d $TARGET_DIR
rm -rf $TMP_FILE