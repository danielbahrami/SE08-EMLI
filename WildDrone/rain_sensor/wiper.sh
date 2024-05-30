#!/bin/bash

DEVICE=${1:-"/dev/ttyACM0"}
MQTT_HOST=${2:-"mqtt-dashboard.com"}
MQTT_TOPIC_RESPONSE=${3:-"org/sdu/2024/emli/group04/wilddrone/rain/response"}

change_wipe() {
    degrees="$1"
    if [ -c $DEVICE ]; then
        echo "{\"wiper_angle\": $degrees}" >$DEVICE
    fi
}

# Keep an infinite loop to reconnect when the connection is lost or broker is unavailable
while true; do
    mosquitto_sub -h $MQTT_HOST -t $MQTT_TOPIC_RESPONSE | while read -r payload; do
        # Callback to execute whenever a message is received
        echo "Rx MQTT: ${payload}"
        # Control the wiper
        change_wipe 180
        echo "Wiping 180 degrees..."
        sleep 2
        change_wipe 0
        echo "Wiping finished"
    done
    sleep 5 # Wait 5 seconds before reconnecting
done
