#!/bin/bash

cam_ssid="EMLI-TEAM-04"
cam_wifi_pass="emliemli"

cam_pass="simonplatz"
cam_home="simonplatz@192.168.10.1"
cam_photo_path="$cam_home:/home/simonplatz/wildlife_photos"
cam_photo_pass="simonplatz"

echo "Looking for cam"
# Find Wi-Fi
while true; do
    if nmcli -f SSID device wifi | grep -q $cam_ssid; then
        break
    fi
done
echo "Found cam"
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

mkdir -p ~/wildlife_photos
sshpass -p $cam_photo_pass rsync -a --ignore-existing $cam_photo_path ~/wildlife_photos

sleep 5

nmcli con down $cam_ssid
