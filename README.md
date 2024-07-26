# sw-tablet-mode-iio
Systemd service to identify SW_TABLET_MODE from iio-sensor-proxy event and handling it:

mode tablet - disable kbd, touchpad and running virt kbd

mode laptop - enable kbd, touchpad and stopping virt kbd

## Install

```
su-
apt-get install libinput-tools xinput iio-sensor-proxy
cd /path/to/dir/sw-tablet-mode-iio
chmod +x ./*.sh
bash ./install.sh [DEVICE]    # default "SYNA3602:00 0911:5288 Touchpad" touchpad for Aquarius
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
