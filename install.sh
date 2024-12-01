#!/bin/bash

cd "$(dirname $(readlink -e $0))"

# # libinput-tools, xinput, iio-sensor-proxy
# apt-get install libinput-tools xinput iio-sensor-proxy

# read settings
source $PWD/env.sh

if [ -z "$1" ]; then
    echo "Usage:   $0 <touchscreen_name>"
    # check list of touchpad's
    if [ -f "$DIR_DATA/conf.d/$NAME_TOUCHPAD_LIST" ]; then
	TOUCHPAD_LIST_FILE="$DIR_DATA/conf.d/$NAME_TOUCHPAD_LIST"
    elif [ -f "conf.d/$NAME_TOUCHPAD_LIST" ]; then
	TOUCHPAD_LIST_FILE="conf.d/$NAME_TOUCHPAD_LIST"
    else
	echo "Touchpad list file not found in '$DIR_DATA' or current directory."
	TOUCHPAD_LIST_FILE=""
    fi

    touchpad_found=false

    if [ -n "$TOUCHPAD_LIST_FILE" ]; then
	echo "Using touchpad list file: $TOUCHPAD_LIST_FILE"
	while IFS= read -r touchpad_name; do
		if xinput list | grep -q "$touchpad_name"; then
			NAME_TOUCHPAD="$touchpad_name"
			echo "Found touchpad in file: $NAME_TOUCHPAD"
			touchpad_found=true
			break
		fi
	done < "$TOUCHPAD_LIST_FILE"
    fi

    if ! $touchpad_found; then
	echo "No touchpad from the list found in xinput."
	NAME_TOUCHPAD="NOT_FOUND_TOUCHPAD"
    fi
else
    NAME_TOUCHPAD="$1"
fi

XINPUT_LIST=$(xinput list | grep "$NAME_TOUCHPAD")
if [ -z "$XINPUT_LIST" ]; then
    echo "Touchpad '$NAME_TOUCHPAD' not found in xinput list."
    exit 1
fi

sed -i "s|^NAME_TOUCHPAD=.*|NAME_TOUCHPAD=\"$NAME_TOUCHPAD\"|" "$PWD/env.sh"
echo "Using touchpad: $NAME_TOUCHPAD"

# create directories
echo "$DIR_NAME scripts  in ${DIR_DATA} directory"
echo "$DIR_NAME/conf.d/ conf file  in ${DIR_DATA}/conf.d/ directory"
echo "$DIR_VAR variables in ${DIR_VAR} directory"

mkdir -p $DIR_DATA
mkdir -p $DIR_DATA/conf.d
mkdir -p $DIR_VAR

# move exec scripts to data directory
echo "Copying scripts to $DIR_DATA directory..."
cp -f  $PWD/$NAME_SW_LISTENER $PWD/env.sh $DIR_DATA

# move .conf
cp -f $PWD/conf.d/$NAME_TOUCHPAD_LIST $DIR_DATA/conf.d/

# root does not have access rights to the X server,
# so let's take the first available one

found=false
for home in ${HOME_DIRS[@]}; do
  if [ -d "$home" ]; then
    if [ -f "$home/.Xauthority" ]; then
      USER_NAME=$(basename "$home")
      XAUTHORITY_VALUE="$home/.Xauthority"
      echo "User: $USER_NAME"
      echo "DISPLAY: $DISPLAY_VALUE"
      echo "XAUTHORITY: $XAUTHORITY_VALUE"
      found=true
      break
    fi
  fi
done

if [ "$found" = false ]; then
  echo "No .Xauthority file found for any user. Exiting with error."
  exit 1
fi

# move service files to systemd directory
echo "Copying files to systemd ${DIR_SERVICES} directory..."
cp -f $PWD/$NAME_SW_LISTENER_SERVICE $DIR_SERVICES

cat "${DIR_SERVICES}/${NAME_SW_LISTENER_SERVICE}"

sed -i "/\[Service\]/a Environment=\"XAUTHORITY=$XAUTHORITY_VALUE\"" "$DIR_SERVICES/$NAME_SW_LISTENER_SERVICE"
echo -e "\nExecStart=/bin/bash $DIR_DATA/$NAME_SW_LISTENER " >> "$DIR_SERVICES/$NAME_SW_LISTENER_SERVICE"

# enable systemd services
echo "Enabling service root..."
systemctl enable --now $NAME_SW_LISTENER_SERVICE

echo "Done."
