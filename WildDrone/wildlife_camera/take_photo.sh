#!/bin/bash

# Define variables
base_dir="../wildlife_photos"
current_date=$(date +"%Y-%m-%d")
timestamp=$(date +"%H%M%S_%3N")
local_time=$(date +"%H:%M:%S.%3N%:z")
epoch_seconds=$(date +"%s.%3N")
trigger=$1 # The trigger type is passed as an argument

# Create directory if it doesn't exist
mkdir -p "$base_dir/$current_date"

# Define file paths
photo_filename="${timestamp}.jpg"
json_filename="${timestamp}.json"
photo_filepath="$base_dir/$current_date/$photo_filename"
json_filepath="$base_dir/$current_date/$json_filename"

# Take a photo using the Raspberry Pi Camera
rpicam-still -t 0.01 -o "$photo_filepath"

# Read EXIF data
subject_distance=$(exiftool -s -s -s -SubjectDistance "$photo_filepath")
exposure_time=$(exiftool -s -s -s -ExposureTime "$photo_filepath")
iso=$(exiftool -s -s -s -ISO "$photo_filepath")

# Create JSON metadata
json_content=$(
  cat <<EOF
{
  "File Name": "$photo_filename",
  "Create Date": "$current_date $local_time",
  "Create Seconds Epoch": $epoch_seconds,
  "Trigger": "$trigger",
  "Subject Distance": "$subject_distance",
  "Exposure Time": "$exposure_time",
  "ISO": $iso
}
EOF
)

# Save JSON metadata to file
echo "$json_content" >"$json_filepath"
