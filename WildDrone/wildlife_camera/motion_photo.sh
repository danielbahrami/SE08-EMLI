#! bin/bash

rm *.jpg
# Define first photo
output_dir="../wildlife_photos"
photo_time1=$(date +"%H%M%S_%3N")
photo_file1="${photo_time1}.jpg"
# Take first initial photo
rpicam-still -t 0.01 --width 500 --height 500 -o "$photo_file1"

while true; do
    sleep 2
    # Take second photo
    photo_time2=$(date +"%H%M%S_%3N")
    photo_file2="${photo_time2}.jpg"
    rpicam-still -t 0.01 --width 500 --height 500 -o "$photo_file2"
    motion=$(python3 ./motion_detect.py $photo_file1 $photo_file2)
    if [[ $motion == "1" ]]; then # Save image
        # Create the dir if needed
        current_date=$(date '+%Y-%m-%d')
        mkdir -p "$output_dir/$current_date"
        # Copy image
        cp $photo_file2 $output_dir/$current_date/$photo_file2
        # Create sidecar
        sidecar_file="$output_dir/$current_date/${photo_time2}.json"
        epoch_seconds=$(date +"%s.%3N")
        local_time=$(date +"%H:%M:%S.%3N%:z")
        # Read EXIF data
        subject_distance=$(exiftool -s -s -s -SubjectDistance "$photo_file2")
        exposure_time=$(exiftool -s -s -s -ExposureTime "$photo_file2")
        iso=$(exiftool -s -s -s -ISO "$photo_file2")

        # Create JSON metadata
        json_content=$(
            cat <<EOF
        {
        "File Name": "$photo_file2",
        "Create Date": "$current_date $local_time",
        "Create Seconds Epoch": $epoch_seconds,
        "Trigger": "Motion",
        "Subject Distance": "$subject_distance",
        "Exposure Time": "$exposure_time",
        "ISO": $iso
        }
EOF
        )
        # Save JSON metadata to file
        echo "$json_content" >"$output_dir/$current_date/${photo_time2}.json"
    fi

    # Second photo becomes first photo
    rm $photo_file1
    photo_file1=$photo_file2
    photo_time1=$photo_time2
done
