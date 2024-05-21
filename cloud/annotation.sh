#!/bin/bash

# Directory containing the images
IMAGE_DIR=${1:-"/path/to/your/images"}
# Ollama endpoint
GENERATEENDPOINT=${2:-"http://localhost:11434/api/generate"}

CHECK_ANNOTATION_STATUS=false

# Loop through each image in the directory
for img in "$IMAGE_DIR"/*.{jpg,png}; do
  # Check if the file exists to handle cases where no files match the pattern
  if [[ -f "$img" ]]; then
    # Process the image (e.g., print the file name)
    echo "Processing $img"

    # Get the filename without extension
    filename=$(basename "${img%.*}")

    json_file="$filename.json"

    # check if annotaiton alreaddy is there
    if jq -e '.Annotation == "value"' $json_file > /dev/null; then
      echo "Annotation JSON object already exists for $filename"
      # annotation already excists, therefore img is skipped with continue
      continue
    fi


    ### Ollama send ###
    # Payload for the Ollama
    JSON_PAYLOAD="{\"model\": \"gemma:7b\", \"prompt\": \"describe this image briefly\", \"stream\": false, \"images\": [\"$img\"]}"
    # Writes the value of the JSON_PAYLOAD variable to a file named "payload.json"
    echo $JSON_PAYLOAD > "payload.json"

    #The @ symbol indicates that curl should read the data from the payload.json file.
    curl_response=$(curl -f -s -X POST -H "Content-Type: application/json" --data-binary @payload.json "$GENERATEENDPOINT")
    
    #Check if failed
    if [ $? -ne 0 ]; then
      echo "Annotation of $filename failed. Aborting..."
      continue
    fi

    # Extract the description from curl command
    description=$(echo "$curl_response" | jq -r '.response')
    # Create annotation JSON object
    ANNOTATION_JSON="{\"Annotation\": {\"Source\": \"gemma:7b\", \"Test\": \"$description\"}}"

    jq --argjson annotation "$ANNOTATION_JSON" '.annotations += [$ANNOTATION_JSON]' $json_file.json > $temp.json && mv $temp.json $json_file.json
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
  echo "No new annotated files."
fi
