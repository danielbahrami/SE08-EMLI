#!/bin/bash

#path to images
IMAGE_DIR=${1:-"/path/to/your/images"}

# create user
git config --local user.name "Your Name"
git config --local user.email "your.email@example.com"


# go to images directory
cd $PATH_TO_IMAGES || exit


commit_message="Annotations"

# add json files to Git
git add "*.json"

git commit -m "$commit_message"

git push

# return to original directory
cd -
