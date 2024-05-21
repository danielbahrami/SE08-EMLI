#!/bin/bash

# Change your device accordinly to the usb port.
DEVICE=${1:-"/dev/ttyAIO"}
MQTT_HOST=${2:-"mqtt://mqtt-dashboard.com"}
MQTT_TOPIC_COMMAND=${3:-"sdu/2024/emuli/group04/itrains"}
MQTT_TOPIC_LISTEN=${4:-"sdu/2024/emuli/group04/rain_sensor"}

change_wipe() {
    angle="$1"
    if [ -c $DEVICE ]; then
        JSON= "{\"wiper_angle\": $angle}"
        echo $JSON > $DEVICE
    fi
    echo "wiping potentially done"
}

while true  # Keep an infinite loop to reconnect when connection lost/broker unavailable
do

    # Read JSON message from serial port
    json_message=$(cat "$serial_port" | jq -c .)

    rain_detect_value=$(echo "$json_message" | jq -r '.rain_detect')
    

    if [ $rain_detect_value -eq 1 ]; then
        # Publish message to MQTT broker
        mosquitto_pub -h $MQTT_HOST -t $MQTT_TOPIC_COMMAND -m $rain_detect_value
    fi

    mosquitto_sub -h $MQTT_HOST -t $MQTT_TOPIC_LISTEN | while read -r payload
    do
        # Here is the callback to execute whenever you receive a message:
        echo "Rx MQTT: ${payload}"
        # Control the rain wiper.
        change_wipe 180
        echo "wiping 180"
        sleep 2
        control_wipe 0
        echo "wiping 0"
    done
    sleep 5  # Wait 10 seconds until reconnection
done # &  # Discomment the & to run in background (but you should rather run THIS script in background)