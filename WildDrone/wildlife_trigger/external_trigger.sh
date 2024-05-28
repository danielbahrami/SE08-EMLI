#!/bin/bash

MQTT_HOST=${1:-"mqtt-dashboard.com"}
MQTT_TOPIC_LISTEN=${3:-"org/sdu/2024/emli/group04/wilddrone/trigger"}

# Keep an infinite loop to reconnect when the connection is lost or broker is unavailable
while true; do
    mosquitto_sub -h $MQTT_HOST -t $MQTT_TOPIC_LISTEN | while read -r payload; do
        # Check if pressure is greater than 0
        if [ $payload -gt 0 ]; then
            ../wildlife_camera/take_photo.sh "External"
        fi
    done
    sleep 5 # Wait 5 seconds before reconnecting
done
