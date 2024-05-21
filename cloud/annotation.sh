#!/bin/bash

# Directory containing the images
IMAGE_DIR="/path/to/your/images"

# Ollama endpoint
GENERATEENDPOINT=${2:-"http://localhost:11434/api/generate"}

CHECK_ANNOTATION_STATUS=false

# Loop through each image in the directory
for img in "$IMAGE_DIR"/*.{jpg,png}; do
  # Check if the file exists to handle cases where no files match the pattern
  if [[ -f "$img" ]]; then
    # Process the image (e.g., print the file name)
    echo "Processing $img"

    # NEED TO CHECK IF ANNOTATION FILE OBJECT IS ALREADY IN METADAT, BELLOW WILL NOT SUFFICE
    # Check if the image has already been annotated
    json_file="$img.json"

    if annotatio_exists "$json_file"; then
      echo "Annotation already exists for: $img"
      continue
    fi

    JSON_PAYLOAD="{\"model\": \"gemma:7b\", \"prompt\": \"describe this image briefly\", \"stream\": false, \"images\": [\"$img\"]}"

    curl_response=$(curl -f -s -X POST -H "Content-Type: application/json" --data-binary @payload.json "$GENERATEENDPOINT")
    if [ $? -ne 0 ]; then
      echo "Annotation of $image_file failed. Aborting..."
      continue
    fi

    # Extract model and reponse from curl command
    model=$(echo "$curl_response" | jq -r '.model')
    description=$(echo "$curl_response" | jq -r '.response')

    # Create annotation JSON object
    annotation="{\"Annotation\": {\"Source\": \"gemma:7b\", \"Description\": \"$description\"}}"
    $CHECK_ANNOTATION_STATUS=true
  fi
done

# go to upload.sh
echo "Now pushing the annotated image up into Github by running cloud.sh"
if [ $CHECK_ANNOTATION_STATUS == true ]; then
  echo "Uploading annotated files"
  ./upload.sh $PATH_TO_IMAGES
else
  echo "No new annotated files."
fi
