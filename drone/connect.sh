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

# connect
mcli dev wifi connect $cam_path password $cam_pass

./save_files.sh
