#!/bin/bash

if [ "$USE_MONGOEXPORT" == "true" ]; then
    echo "Using mongoexport"
    bash mongoexport-rclone.sh
else
    echo "Using mongodump"
    bash mongodump-rclone.sh
fi