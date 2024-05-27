#!/bin/bash

# Directory containing the images
IMAGE_DIR=${1:-"/path/to/images"}
AUTHOR_NAME=${2:-"Name"}
AUTHOR_EMAIL=${3:-"email@example.com"}
# Ollama endpoint
GENERATEENDPOINT=${4:-"http://localhost:11434/api/generate"}

CHECK_ANNOTATION_STATUS=false

while true; do
  # Loop through each image in the directory
  for img in "$IMAGE_DIR"/*.{jpg,png}; do
    # Check if the file exists to handle cases where no files match the pattern
    if [[ -f "$img" ]]; then
      echo "Processing $img"

      # Get the filename without the extension
      filename=$(basename "${img%.*}")

      # Construct the corresponding JSON file path
      json_file="$directory/$base_name.json"

      # Check if the annotation already exists
      # 2>&1 silences all output from the command including error messages
      if jq -e '.Annotation' "$json_file" >/dev/null 2>&1; then
        echo "Annotation JSON object already exists for $filename"
        continue
      fi

      # Base64 encode the image
      # Setting it to 0 means there will be no line breaks in the output, resulting in a single continuous line of base64-encoded data
      img_base64=$(base64 -w 0 "$image_file")

      # Payload for Ollama
      JSON_MSG="{\"model\": \"gemma:7b\", \"prompt\": \"describe this image briefly\", \"stream\": false, \"images\": [\"$img_base64\"]}"

      # Send the JSON payload to Ollama's generate endpoint using curl
      curl_response=$(curl -s -X POST "$GENERATEENDPOINT" \
        -H "Content-Type: application/json" \
        -d "$JSON_MSG")

      # Check if failed
      if [ $? -ne 0 ]; then
        echo "Annotation of $filename failed"
        continue
      fi

      # Extract the description response from the curl response
      response=$(echo "$curl_response" | jq -r '.response')
      # Create the JSON annotation
      ANNOTATION_JSON="{\"Annotation\": {\"Source\": \"gemma:7b\", \"Test\": \"$response\"}}"

      # Write the JSON annotation to the .json file
      jq --argjson annotation "$ANNOTATION_JSON" '.+= [$annotation]' $json_file.json >$temp.json && mv $temp.json $json_file.json
      $CHECK_ANNOTATION_STATUS=true
    fi
  done

  # Run upload.sh
  echo "Publishing the metadata by running upload.sh"
  if [ $CHECK_ANNOTATION_STATUS = true ]; then
    echo "Uploading annotated files"
    ./upload.sh $IMAGE_DIR $AUTHOR_NAME $AUTHOR_EMAIL
    CHECK_ANNOTATION_STATUS=false
  else
    echo "No changes in annotated files"
  fi
  sleep 10
done
