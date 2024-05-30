#!/bin/bash

cam_ssid="EMLI-TEAM-04"
cam_wifi_pass="emliemli"

cam_pass="simonplatz"
cam_home="simonplatz@10.0.0.10"
cam_photo_path="$cam_home:SE08-EMLI/WildDrone/wildlife_photos"
cam_photo_pass="simonplatz"

while true; do
    echo "Looking for camera..."
    # Find Wi-Fi
    while true; do
        if nmcli -f SSID device wifi | grep -q $cam_ssid; then
            break
        fi
    done
    echo "Found camera"
    echo "Connecting..."
    # Connect
    nmcli dev wifi connect $cam_ssid password $cam_wifi_pass
    echo "Connected"

    # Sync time
    echo "Sync time"
    sshpass -p $cam_pass ssh $cam_home sudo date --set @$(date -u +%s)

    chmod 777 ./log_wifi.sh
    chmod 777 ./save_files.sh
    ./log_wifi.sh &
    cat ./save_files.sh | sshpass -p $cam_pass ssh $cam_home

    sshpass -p $cam_photo_pass rsync -a --ignore-existing $cam_photo_path ./

    nmcli con down $cam_ssid

    sleep 60
done
