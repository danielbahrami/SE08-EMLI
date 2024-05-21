cam_ssid="EMLI-TEAM-04"

while true;
do
    nmcli con show --active | grep $cam_ssid > /dev/null
    if [$? == 0];
    then
        break
    fi
    nmcli -f SSID,SIGNAL,RATE dev wifi | grep $cam_ssid
    sleep 1
done