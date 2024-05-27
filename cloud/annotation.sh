#!/bin/bash

# Directory containing the images
IMAGE_DIR=${1:-"/path/to/your/images"}
# Ollama endpoint
GENERATEENDPOINT=${2:-"http://localhost:11434/api/generate"}

CHECK_ANNOTATION_STATUS=false

while true; do
  # Loop through each image in the directory
  for img in "$IMAGE_DIR"/*.{jpg,png}; do
    # Check if the file exists to handle cases where no files match the pattern
    if [[ -f "$img" ]]; then
      # Process the image (e.g., print the file name)
      echo "Processing $img"

      # Get the filename without extension
      filename=$(basename "${img%.*}")

      # Construct the corresponding JSON file path
      json_file="$directory/$base_name.json"

      # check if annotaiton alreaddy is there
      # 2>&1 silences all output from the command, including error messages
      if jq -e '.Annotation' "$json_file" >/dev/null 2>&1; then
        echo "Annotation JSON object already exists for $filename"
        # annotation already excists, therefore img is skipped with continue
        continue
      fi

      # Base64 encode the image
      # Setting it to 0 means there will be no line breaks in the output, resulting in a single continuous line of base64-encoded data
      img_base64=$(base64 -w 0 "$image_file")

      ### Ollama send ###
      # Payload for the Ollama
      JSON_MSG="{\"model\": \"gemma:7b\", \"prompt\": \"describe this image briefly\", \"stream\": false, \"images\": [\"$img_base64\"]}"

      # Send the JSON payload to Ollama's generate endpoint using curl
      curl_response=$(curl -s -X POST "$GENERATEENDPOINT" \
        -H "Content-Type: application/json" \
        -d "$JSON_MSG")

      #Check if failed
      if [ $? -ne 0 ]; then
        echo "Annotation of $filename failed. Check internet"
        continue
      fi

      # Extract the description response from curl command
      response=$(echo "$curl_response" | jq -r '.response')
      # Create annotation JSON object
      ANNOTATION_JSON="{\"Annotation\": {\"Source\": \"gemma:7b\", \"Test\": \"$response\"}}"

      # Write the newly created JSON annotation to the json file
      jq --argjson annotation "$ANNOTATION_JSON" '.+= [$annotation]' $json_file.json > $temp.json && mv $temp.json $json_file.json
      $CHECK_ANNOTATION_STATUS=true
    fi
  done

  # go to upload.sh
  echo "Now pushing the annotated image up into Github by running cloud.sh"
  if [ $CHECK_ANNOTATION_STATUS = true ]; then
    echo "Uploading annotated files"
    ./upload.sh $IMAGE_DIR
    CHECK_ANNOTATION_STATUS=false
  else
    echo "No changes in annotated files"
  fi
  sleep 10
done
