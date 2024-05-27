cam_ssid="EMLI-TEAM-04"

echo "logging wifi"

nmcli con show --active | grep $cam_ssid

while true;
do
    if [ nmcli con show --active | grep -q $cam_ssid ];
    then
        break
    fi
    nmcli -f SSID,SIGNAL,RATE dev wifi | grep $cam_ssid
    sleep 1
done

echo "done logging"