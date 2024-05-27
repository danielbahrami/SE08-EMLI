#!/bin/bash

# Change your device accordinly to the usb port.
DEVICE=${1:-"/dev/ttyAIO"}
MQTT_HOST=${2:-"mqtt://mqtt-dashboard.com"}
MQTT_TOPIC_COMMAND=${3:-"org/sdu/2024/emli/group04/wilddrone/rain/command"}
MQTT_TOPIC_RESPONSE=${4:-"org/sdu/2024/emli/group04/wilddrone/rain/response"}

change_wipe() {
    degrees="$1"
    if [ -c $DEVICE ]; then
        JSON= "{\"wiper_angle\": $degrees}"
        echo $JSON >$DEVICE
    fi
    echo "wiping done"
}

while true; do # Keep an infinite loop to reconnect when connection lost/broker unavailable

    # Read JSON message from serial port
    json_message=$(cat "$DEVICE" | jq -c .)

    rain_detect_value=$(echo "$json_message" | jq -r '.rain_detect')

    if [ $rain_detect_value -eq 1 ]; then
        # Publish message to MQTT broker
        mosquitto_pub -h $MQTT_HOST -t $MQTT_TOPIC_COMMAND -m $rain_detect_value
    fi

    mosquitto_sub -h $MQTT_HOST -t $MQTT_TOPIC_RESPONSE | while read -r payload; do
        # Here is the callback to execute whenever you receive a message:
        echo "Rx MQTT: ${payload}"
        # Control the rain wiper.
        change_wipe 180
        echo "wiping 180 degrees"
        sleep 2
        control_wipe 0
        echo "wiping 0 degrees"
    done
    sleep 5 # Wait 5 seconds until reconnection
done
