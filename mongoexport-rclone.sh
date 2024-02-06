#!/bin/bash

RCLONE_CONFIG=$RCLONE_CONFIG
RCLONE_CONFIG_FILE="/config/rclone/rclone.conf"

# if RCLONE_CONFIG file does not exist and RCLONE_CONFIG environment variable is not set
if [ ! -f "$RCLONE_CONFIG_FILE" ] && [ -z "$RCLONE_CONFIG" ]; then
    echo "Error: rclone.conf file does not exist and RCLONE_CONFIG environment variable is not set"
    exit 1
fi

RCLONE_REMOTE=${RCLONE_REMOTE:-"default"}

if [ ! -f "$RCLONE_CONFIG_FILE" ]; then
    echo "rclone.conf file does not exist, creating it ($RCLONE_CONFIG_FILE)"
    mkdir -p ~/.config/rclone
    echo "[$RCLONE_REMOTE]" > $RCLONE_CONFIG_FILE
    echo -e "$RCLONE_CONFIG" >> $RCLONE_CONFIG_FILE
fi

RCLONE_ARGS=${RCLONE_ARGS:-""}

RCLONE_ARGS="$RCLONE_ARGS --config $RCLONE_CONFIG_FILE"
RCLONE_REMOTE_PATH=${RCLONE_REMOTE_PATH:-"/"}

MONGOEXPORT_ARGS=${MONGOEXPORT_ARGS:-""}

FILENAME=${FILENAME:-"mongodb"}

if [ -n "$MONGO_DB" ]; then
    MONGOEXPORT_ARGS="$MONGOEXPORT_ARGS -d $MONGO_DB"
fi

if [ -n "$MONGO_COLLECTION" ]; then
  MONGOEXPORT_ARGS="$MONGOEXPORT_ARGS -c $MONGO_COLLECTION"
else
  echo "Error: MONGO_COLLECTION environment variable is not set"
  exit 1
fi

FILENAME_TIMESTAMP=${FILENAME_TIMESTAMP:-"true"}

if [ "$FILENAME_TIMESTAMP" = "true" ]; then
    FILENAME="$FILENAME-$(date "+%H-%M-%S-%F")"
fi

MONGOEXPORT_TYPE=${MONGOEXPORT_TYPE:-"json"}
if [ "$MONGOEXPORT_TYPE" = "json" ]; then
    OUTPUT_FILE="$FILENAME.json"
    MONGOEXPORT_ARGS="$MONGOEXPORT_ARGS --type=json"
elif [ "$MONGOEXPORT_TYPE" = "csv" ]; then
    OUTPUT_FILE="$FILENAME.csv"
    MONGOEXPORT_ARGS="$MONGOEXPORT_ARGS --type=csv"
else
    echo "Error: MONGOEXPORT_TYPE environment variable is not set to json or csv"
    exit 1
fi

echo "Exporting database to $OUTPUT_FILE"
echo "mongoexport options: $MONGOEXPORT_ARGS"
echo "rclone options: $RCLONE_ARGS"

if [ -n "$MONGO_URI" ]; then
    echo "Using MONGO_URI environment variable"
    MONGOEXPORT_ARGS="$MONGOEXPORT_ARGS --uri=$MONGO_URI"
fi

mongoexport $MONGOEXPORT_ARGS | \
rclone rcat $RCLONE_ARGS $RCLONE_REMOTE:"$RCLONE_REMOTE_PATH"/"$OUTPUT_FILE"