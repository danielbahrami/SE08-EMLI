#!/bin/bash

MQTT_HOST=${1:-"mqtt://mqtt-dashboard.com"}
MQTT_TOPIC_COMMAND=${2:-"sdu/2024/emuli/group04/itrains"}
MQTT_TOPIC_LISTEN=${3:-"sdu/2024/emuli/group04/rain_sensor"}

while true  # Keep an infinite loop to reconnect when connection lost/broker unavailable
do
    mosquitto_sub -h $MQTT_HOST -t $MQTT_TOPIC_COMMAND | while read -r payload
    do
        # Check if there is rain
        if [ $payload -eq 1 ]; then
            mosquitto_pub -h $MQTT_HOST -t $MQTT_TOPIC_LISTEN -m "trigger wiper"
        fi
    done
    sleep 5  # Wait 5 seconds until reconnection
done
