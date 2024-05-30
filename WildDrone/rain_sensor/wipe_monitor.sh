#!/bin/bash

MQTT_HOST=${1:-"mqtt-dashboard.com"}
MQTT_TOPIC_COMMAND=${2:-"org/sdu/2024/emli/group04/wilddrone/rain/command"}
MQTT_TOPIC_RESPONSE=${3:-"org/sdu/2024/emli/group04/wilddrone/rain/response"}

# Keep an infinite loop to reconnect when the connection is lost or broker is unavailable
while true; do
    mosquitto_sub -h $MQTT_HOST -t $MQTT_TOPIC_COMMAND | while read -r payload; do
        # Check if there is rain
        if [ $payload -eq 1 ]; then
            mosquitto_pub -h $MQTT_HOST -t $MQTT_TOPIC_RESPONSE -m "wipe"
        fi
    done
    sleep 5 # Wait 5 seconds before reconnecting
done
