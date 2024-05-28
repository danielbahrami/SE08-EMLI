#!/bin/bash

# Directory containing the images
IMAGE_DIR=${1:-"/path/to/your/images"}
AUTHOR_NAME=${2:-"Name"}
AUTHOR_EMAIL=${3:-"email@example.com"}
# Ollama endpoint - follow the below commands
# $ ollama serve
# $ ollama pull llava ; if not already pulled 
GENERATEENDPOINT=${4:-"http://localhost:11434/api/generate"}

CHECK_ANNOTATION_STATUS=0

while true; do
  # Loop through each image in the directory
  for img in "$IMAGE_DIR"*.{jpg,png}; do
    # Check if the file exists to handle cases where no files match the pattern
    if [[ -f "$img" ]]; then
      # Process the image (e.g., print the file name)
      echo "img path: $img"

      # Get the filename without extension
      filename=$(basename "${img%.*}")

      # Construct the corresponding JSON file path
      json_file="$IMAGE_DIR$filename.json"

      if jq -e '.Annotation' "$json_file" > /dev/null; then
        echo "Skipping already annotated image: $image_file"
        continue
      fi

      # Base64 encode the image
      # Setting it to 0 means there will be no line breaks in the output, resulting in a single continuous line of base64-encoded data
      img_base64=$(base64 -w 0 -i $img)

      ### Ollama send ###
      # Payload for the Ollama
      JSON_MSG="{\"model\": \"llava\", \"prompt\": \"describe this image shortly\", \"stream\": false, \"images\": [\"$img_base64\"]}"

      # Send the JSON payload to Ollama's generate endpoint using curl
      curl_response=$(curl -X POST "$GENERATEENDPOINT" \
        -H "Content-Type: application/json" \
        -d "$JSON_MSG")

      #Check if failed
      if [ $? -ne 0 ]; then
        echo "Annotating $filename failed... Check internet"
        continue
      fi

      # Extract the description response from curl command
      response=$(echo "$curl_response" | jq -r '.response')
      # Create the JSON annotation
      ANNOTATION_JSON="{\"Source\": \"llava\", \"Test\": \"$response\"}"

      # Write the newly created JSON annotation to the json file      
      jq --argjson Annotation "$ANNOTATION_JSON" '.+={$Annotation}' "$json_file" > tmp.json && mv tmp.json "$json_file"

      $CHECK_ANNOTATION_STATUS=1
    fi
  done

  # directss upload.sh
  if [ $CHECK_ANNOTATION_STATUS -eq 1 ]; then
    echo "Uploading annotated files"
    ./upload.sh $IMAGE_DIR $USER_NAME $USER_EMAIL
  else
    echo "No changes in annotated files"
  fi
  sleep 10
done