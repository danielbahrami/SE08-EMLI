#!/bin/bash

cam_home="simonplatz@192.168.10.1"
cam_pass="simonplatz"
cam_photo_path="/home/simonplatz/wildlife_photos"
cam_path="$cam_home:$cam_photo_path"
drone_path="/home/simonplatz/Desktop"
dron_id="DRONe_01"

#current_time=$(date + %d %m %Y %H:%M:%S)

ls -a

cd $cam_photo_path
for dir in */; # wildlife_photos
    do
    ls -a
    cd $dir
    for file in *; # some data
        do
        ext="${file##*.}"
        if [[ "$ext" == "json" ]];
        then
            # check that the image has not been copied yet
            copied=$(jq '."Drone Copy" != null' $file)
            echo $copied
            if [[ $copied == "false" ]];
            then
                epoch_seconds=$(date +"%s.%3N")     
                echo "setting copy time"
                jq --arg id "$dron_id" --arg epoch $epoch_seconds '. += {"Drone Copy": { "Drone Id": $id, "Seconds Epoch": $epoch } }' $file &> tmp.json && cp tmp.json $file
                jq $file
                #echo "scp $file:$drone_path"
                #scp $file:$dron_path # save json
                #scp ${file/json/jpg}:$dron_path # save jpg
            fi
        fi
    done
    cd ..
done

# close ssh connection
exit

# copy files over to the drone
# scp -r $cam_path $drone_path
