#!/bin/bash

cd "$(dirname $(readlink -e $0))"

# read settings
source $PWD/env.sh

# disable service
echo "Disabling service..."
systemctl disable $NAME_SW_LISTENER_SERVICE

# stop service
echo "Stopping service..."
systemctl stop $NAME_SW_LISTENER_SERVICE

# remove files
echo "Removing files..."
rm -f $DIR_SERVICES/$NAME_SW_LISTENER_SERVICE
rm -rf $DIR_DATA

echo "Done."
