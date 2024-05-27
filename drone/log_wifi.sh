#!/bin/bash
chmod +x createDatabase.sh
./createDatabase.sh
# Path to the SQLite database
databasePath="/home/simonplatz/database/wifi_log.db"
echo $databasePath
# Function to get WiFi signal data from /proc/net/wireless
get_wifi_signal_data() {
    # Extract the link quality and signal level from /proc/net/wireless
    local wifi_data=$(grep wlp3s0 /proc/net/wireless)
    local link_quality=$(echo $wifi_data | awk '{print int($3 * 100 / 70)}')
    local signal_level=$(echo $wifi_data | awk '{print int($4)}')
    echo "$link_quality $signal_level"
}

# Main loop to log data
while true; do
    get_wifi_signal_data
    epoch=$(echo $(date +%s))
    wifi_data=($(get_wifi_signal_data))
    link_quality=${wifi_data[0]}
    signal_level=${wifi_data[1]}

    # Insert data into SQLite database
    sqlite3 $databasePath "INSERT INTO WifiLog (epoch, link_quality, signal_level) VALUES ($epoch, $link_quality, $signal_level);"
    # Wait for a defined interval before logging again (e.g., 10 seconds)
    sleep 10
done
