#!/bin/bash

set -e

JSON=$1
FILE_PATH=$2

if [ -z $FILE_PATH ] || [ ! -f $FILE_PATH ] || [ -z $JSON ]; then
	echo "Usage: $0 <lineage_device.json> <lineage-XX.Y-...zip>"
	exit 1
fi

shift 2

ADDITIONAL_FILES=$@
FILE=$(basename $FILE_PATH)

ID=$(sha256sum $FILE_PATH | cut -d " " -f 1)
VERSION=$(echo $FILE | cut -d \- -f 2)
DATETIME=$(unzip -p $FILE_PATH META-INF/com/android/metadata | grep post-timestamp | cut -d = -f 2)
RELEASE=$(echo $FILE | sed s/\.zip//g)-$DATETIME
URL=https://github.com/danielml3/releases/releases/download/$RELEASE/$FILE
SIZE=$(du -b $FILE_PATH | cut -f 1)

cat << EOF > $JSON
{
    "response":[
        {
            "filename":"$FILE",
            "id":"$ID",
            "version":"$VERSION",
            "romtype":"unofficial",
            "datetime":$DATETIME,
            "url":"$URL",
            "size":$SIZE
        }
    ]
}
EOF

git add .
git commit -m "$FILE" || true
git push

gh release create $RELEASE $FILE_PATH $ADDITIONAL_FILES --title $RELEASE --latest
