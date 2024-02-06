#!/bin/bash

export TZ=${TZ:-"UTC"}

echof() {
    builtin echo -e "$(date +"%Y-%m-%dT%H:%M:%S.000%z")\t$*"
}

if [ "$USE_MONGOEXPORT" == "true" ]; then
    echof "using mongoexport"
    bash mongoexport-rclone.sh
else
    echof "using mongodump"
    bash mongodump-rclone.sh
fi
