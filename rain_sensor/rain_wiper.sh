#!/bin/bash

# Change your device accordinly to the usb port.
DEVICE=${1:-"/dev/ttyAIO"}
MQTT_HOST=${2:-"mqtt-dashboard.com"}
MQTT_TOPIC_RESPONSE=${3:-"org/sdu/2024/emli/group04/wilddrone/rain/response"}

change_wipe() {
    degrees="$1"
    if [ -c $DEVICE ]; then
        JSON= "{\"wiper_angle\": $degrees}"
        echo $JSON >$DEVICE
    fi
    echo "wiping done"
}

while true; do # Keep an infinite loop to reconnect when connection lost/broker unavailable
    mosquitto_sub -h $MQTT_HOST -t $MQTT_TOPIC_RESPONSE | while read -r payload; do
        # Here is the callback to execute whenever you receive a message:
        echo "Rx MQTT: ${payload}"
        # Control the rain wiper.
        change_wipe 180
        echo "wiping 180 degrees"
        sleep 2
        change_wipe 0
        echo "wiping 0 degrees"
    done
    sleep 5 # Wait 5 seconds until reconnection
done
