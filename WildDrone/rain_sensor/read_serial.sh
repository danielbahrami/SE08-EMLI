#!/bin/bash

DEVICE=${1:-"/dev/ttyACM0"}
MQTT_HOST=${2:-"mqtt-dashboard.com"}
MQTT_TOPIC_COMMAND=${3:-"org/sdu/2024/emli/group04/wilddrone/rain/command"}

# Keep an infinite loop to reconnect when the connection is lost or broker is unavailable
while true; do
    # Read JSON message from serial port
    json_message=$(cat "$DEVICE" | head -1)

    rain_detect_value=$(echo "$json_message" | jq -r '.rain_detect')

    if [ $rain_detect_value -eq 1 ]; then
        # Publish message to MQTT broker
        mosquitto_pub -h $MQTT_HOST -t $MQTT_TOPIC_COMMAND -m $rain_detect_value
    fi
    sleep 5 # Wait 5 seconds before reconnecting
done
