#!/bin/bash

cd "$(dirname $(readlink -e $0))"

# read settings
source $PWD/env.sh

# Search for an iio-sensor-proxy device in sysfs
for input in /sys/class/input/event*; do
    name=$(cat "$input/device/name")
    if [ "$name" == "iio-sensor-proxy" ]; then
        device_path="/dev/input/$(basename $input)"
        break
    fi
done

if [ -z "$device_path" ]; then
    echo "iio-sensor-proxy device not found"
    exit 1
fi

echo "Monitoring device: $device_path"

# Check tablet mode after reboot
tablet_mode="0"
if [ "$(cat ${NAME_VAR_MODE_TABLET})" -eq 1 ];then
	tablet_mode="1"
	xinput set-prop "AT Translated Set 2 keyboard" "Device Enabled" 0
	xinput set-prop "${NAME_TOUCHPAD}" "Device Enabled" 0
	onboard &
fi

# Launch libinput debug-event and event handling
stdbuf -oL libinput debug-events --device=$device_path | while read -r line; do
    echo "$line"
    if echo "$line" | grep -q 'SWITCH_TOGGLE'; then
        state=$(echo "$line" | grep -oP 'state \K\d')
        if [ "$state" == "1" ]; then
            echo "$(date): Tablet mode enabled"
            echo "1" > "${NAME_VAR_MODE_TABLET}"
            if [ "$tablet_mode" == "0" ]; then
                xinput set-prop "AT Translated Set 2 keyboard" "Device Enabled" 0
                xinput set-prop "${NAME_TOUCHPAD}" "Device Enabled" 0
                onboard &
            fi
            tablet_mode="1"
        else
            echo "$(date): Tablet mode disabled"
            echo "0" > "${NAME_VAR_MODE_TABLET}"
            xinput set-prop "AT Translated Set 2 keyboard" "Device Enabled" 1
            xinput set-prop "${NAME_TOUCHPAD}" "Device Enabled" 1
            killall onboard
            tablet_mode="0"
        fi
    fi
done
