#!/bin/bash
wifi_interface="wlp3s0"
chmod +x create_database.sh
./create_database.sh
# Path to the SQLite database
databasePath="/home/simonplatz/database/wifi_log.db"
echo $databasePath

# Function to get Wi-Fi signal data from /proc/net/wireless
get_wifi_signal_data() {
    # Extract the link quality and signal level from /proc/net/wireless
    local wifi_data=$(grep $wifi_interface /proc/net/wireless)
    local link_quality=$(echo $wifi_data | awk '{print int($3)}')
    local signal_level=$(echo $wifi_data | awk '{print int($4)}')
    echo "$link_quality $signal_level"
}

echo "begin logging ..."
# Main loop to log data
while true; do    epoch=$(echo $(date +%s))
    wifi_data=($(get_wifi_signal_data))
    link_quality=${wifi_data[0]}
    signal_level=${wifi_data[1]}
    if [ $signal_level -ge 0 ]; then
        break
    fi
    # Insert data into SQLite database
    sqlite3 $databasePath "INSERT INTO WifiLog (epoch, link_quality, signal_level) VALUES ($epoch, $link_quality, $signal_level);"
    sleep 1 # Wait before logging again
done

echo "done logging"
