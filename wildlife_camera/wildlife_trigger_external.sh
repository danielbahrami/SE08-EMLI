#!/bin/bash

MQTT_HOST=${1:-"mqtt://mqtt-dashboard.com"}
MQTT_TOPIC_LISTEN=${3:-"sdu/2024/emuli/group04/wildfiretrigger"}

while true  # Keep an infinite loop to reconnect when connection lost/broker unavailable
do
    mosquitto_sub -h $MQTT_HOST -t $MQTT_TOPIC_LISTEN | while read -r payload
    do
        # Check if the pressure plate is greater than 0
        if [ $payload -gt 0 ]; then
            ./take_photo.sh "External"
        fi
    done
    sleep 5  # Wait 5 seconds until reconnection
done
