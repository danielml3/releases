#!/bin/bash

set -e

JSON=$1
JSON_V2=$2
FILE_PATH=$3

if [ -z $FILE_PATH ] || [ ! -f $FILE_PATH ] || [ -z $JSON ]; then
	echo "Usage: $0 <lineage_device.json> <v2_lineage_device.json> <lineage-XX.Y-...zip>"
	exit 1
fi

shift 3

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

cat << EOF > $JSON_V2
[
  {
    "datetime": 1781858358,
    "files": [
      {
        "filename": "ota-package.zip",
        "os_patch_level": "2026-06-01",
        "os_sdk_level": 36,
        "ota_property_files": "payload_metadata.bin:4662:187245,payload.bin:4662:1926274191,payload_properties.txt:1926278911:156,apex_info.pb:2220:1279,care_map.pb:3546:1069,metadata:69:683,metadata.pb:820:1352                        ",
        "sha256": "11468fc263696b8bc0afd35861c35d62a562ba29722447a3972c39f0023deb7f",
        "size": 1926282058,
        "url": "https://example.com/full/ota-package.zip"
      }
    ],
    "type": "nightly",
    "version": "23.2"
  }
]
EOF

git add .
git commit -m "$FILE" || true
git push

gh release create $RELEASE $FILE_PATH $ADDITIONAL_FILES --title $RELEASE --latest
