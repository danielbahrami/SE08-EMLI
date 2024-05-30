#!/bin/bash

cam_home="simonplatz@10.0.0.10"
cam_pass="simonplatz"
cam_photo_path="SE08-EMLI/WildDrone/wildlife_photos/"
cam_path="$cam_home:$cam_photo_path"
dron_id="DRONe_01"

cd $cam_photo_path
for dir in */; do
    cd $dir
    for file in *; do
        ext="${file##*.}"
        if [[ "$ext" == "json" ]]; then
            # Check that the image has not been copied yet
            copied=$(jq '."Drone Copy" != null' $file)
            echo $copied
            if [[ $copied == "false" ]]; then
                epoch_seconds=$(date +"%s.%3N")
                echo "setting copy time"
                jq --arg id "$dron_id" --arg epoch $epoch_seconds '. += {"Drone Copy": { "Drone Id": $id, "Seconds Epoch": $epoch } }' $file &>tmp.json && cp tmp.json $file
                jq $file
                rm tmp.json
            fi
        fi
    done
    cd ..
done

# Close SSH connection
exit
