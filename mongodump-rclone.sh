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


MONGODUMP_ARGS=${MONGODUMP_ARGS:-""}

FILENAME=${FILENAME:-"mongodb"}

if [ -n "$MONGO_DB" ]; then
  MONGODUMP_ARGS="$MONGODUMP_ARGS -d $MONGO_DB"
fi

if [ -n "$MONGO_COLLECTION" ]; then
  MONGODUMP_ARGS="$MONGODUMP_ARGS -c $MONGO_COLLECTION"
fi


FILENAME_TIMESTAMP=${FILENAME_TIMESTAMP:-"true"}

if [ "$FILENAME_TIMESTAMP" = "true" ]; then
  FILENAME="$FILENAME-$(date "+%H-%M-%S-%F")"
fi

OUTPUT_FILE="$FILENAME.archive"

# if --gzip is in MONGODUMP_ARGS, add .gz to the file name
if [[ $MONGODUMP_ARGS == *"--gzip"* ]]; then
  OUTPUT_FILE="$OUTPUT_FILE.gz"
fi


echo "Dumping database to $OUTPUT_FILE"
echo "mongodump options: $MONGODUMP_ARGS"
echo "rclone options: $RCLONE_ARGS"

if [ -n "$MONGO_URI" ]; then
  echo "Using MONGO_URI environment variable"
  MONGODUMP_ARGS="$MONGODUMP_ARGS --uri=$MONGO_URI"
fi

mongodump $MONGODUMP_ARGS --archive | \
rclone rcat $RCLONE_ARGS $RCLONE_REMOTE:"$RCLONE_REMOTE_PATH"/"$OUTPUT_FILE"