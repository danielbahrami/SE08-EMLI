#! bin/bash

cam_home="simonplatz@10.0.0.10"
cam_pass="simonplatz"
cam_photo_path="/home/simonplatz/wildlife_photos"
cam_path="$cam_home:$cam_photo_path"
drone_path="/home/simonplatz/Desktop"
dron_id="DRONe_01"

# ssh into the camera
sshpass -p $cam_pass ssh $cam_home

cd $cam_photo_path
for dir in */;
    for file in dir;
        if ["$file" == "*.json"];
        then
            epoch_seconds=$(date +"%s.%3N")
            jq  --arg id "$dron_id" --arg epoch $epoch_seconds '. += {"Drone Copy": { "Drone Id": $id, "Seconds Epoch": $epoch } }' $file
        fi
    done
done

# close ssh connection
exit

# copy files over to the drone
scp -r $cam_path $drone_path

