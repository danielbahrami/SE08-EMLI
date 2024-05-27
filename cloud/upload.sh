#!/bin/bash

#Path to images
IMAGE_DIR=${1:-"/path/to/your/images"}
#Git users
USER_NAME=${2:-"Your Name"}
USER_EMAIL=${3:-"your.email@example.com"}

# create user
git config --local user.name "$USER_NAME"
git config --local user.email "$USER_EMAIL"

# go to images directory
cd $PATH_TO_IMAGES || exit

commit_message="Annotations"

# add json files to Git
git add "*.json"

git commit -m "$commit_message"

git push

# return to original directory
cd -
