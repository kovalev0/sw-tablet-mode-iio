#!/bin/bash -x

DIR_NAME="sw-tablet-mode-iio"
DIR_DATA="/usr/local/bin/$DIR_NAME/"
DIR_SERVICES="/etc/systemd/system/"
DIR_VAR="/var/lib/"

# 0 - laptop,  1 - tablet
NAME_VAR_MODE_TABLET="$DIR_VAR/sw-tablet-mode.txt"

# scripts
NAME_SW_LISTENER="sw-tablet-mode-iio-handler.sh"

# services
NAME_SW_LISTENER_SERVICE="sw-tablet-mode-iio.service"

# overwrite
NAME_TOUCHPAD="SYNA3602:00 0911:5288 Touchpad"

# list of touchpad's
NAME_TOUCHPAD_LIST="list-touchpads.conf"

# for acces to X server
HOME_DIRS=$(find /home -mindepth 1 -maxdepth 1 -type d)
XAUTHORITY_VALUE=""
USER_NAME="user"
