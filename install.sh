#!/bin/bash -x

cd "$(dirname $(readlink -e $0))"

# # libinput-tools, xinput, iio-sensor-proxy
# apt-get install libinput-tools xinput iio-sensor-proxy

# read settings
source $PWD/env.sh

if [ -z "$1" ]; then
    echo "Usage:   $0 <touchscreen_name>"
    echo "Set default: $NAME_TOUCHPAD"
else
    NAME_TOUCHPAD="$1"
fi

XINPUT_LIST=$(xinput list | grep "$NAME_TOUCHPAD")
if [ -z "$XINPUT_LIST" ]; then
    echo "Touchscreen '$NAME_TOUCHPAD' not found in xinput list."
    exit 1
fi

sed -i "s|^NAME_TOUCHPAD=.*|NAME_TOUCHPAD=\"$NAME_TOUCHPAD\"|" "$PWD/env.sh"

# create directories
echo "$DIR_NAME scripts  in ${DIR_DATA} directory"
echo "$DIR_NAME variables in ${DIR_VAR} directory"

mkdir -p $DIR_DATA
mkdir -p $DIR_VAR

# move exec scripts to data directory
echo "Copying scripts to $DIR_DATA directory..."
cp -f  $PWD/$NAME_SW_LISTENER $PWD/env.sh $DIR_DATA

# root does not have access rights to the X server,
# so let's take the first available one

found=false
for home in "${HOME_DIRS[@]}"; do
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
