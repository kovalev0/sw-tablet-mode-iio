# sw-tablet-mode-iio
Systemd service to identify SW_TABLET_MODE from iio-sensor-proxy event and handling it:

Tested on ALT linux distro

The iio-sensor-proxy should be able to calculate the hinge angle based on the
readings of two accelerometers (located in screen and base)

mode tablet - disable kbd, touchpad and running virt kbd

mode laptop - enable kbd, touchpad and stopping virt kbd

## Install

```
su-
apt-get install libinput-tools xinput iio-sensor-proxy
cd /path/to/dir/sw-tablet-mode-iio
chmod +x ./*.sh
bash ./install.sh [DEVICE]    # default search in conf.d/list-touchpads.conf
```

You can find out the names or ids of your devices by using

```
xinput --list
```

## Uninstall 
Just run uninstall.sh

```
su -
bash ./uninstall.sh
```
