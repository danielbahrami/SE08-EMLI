#!/bin/bash

cam_ssid="EMLI-TEAM-04"
cam_pass="emliemli"

# find wifi
while true;
do
    if nmcli -f SSID device wifi | grep -q $cam_ssid;
    then
        break;
    fi
done
echo "found cam"

# connect
nmcli dev wifi connect $cam_ssid password $cam_pass

chmod 777 ./log_wifi.sh
chmod 777 ./save_files.sh
#./log_wifi.sh &
./save_files.sh

nmcli con down $cam_ssid
