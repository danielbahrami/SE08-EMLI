#!/bin/bash

# Path to images
IMAGE_DIR=${1:-"/path/to/your/images"}
#Git users
USER_NAME=${2:-"Your Name"}
USER_EMAIL=${3:-"your.email@example.com"}

# Create user
git config --local user.name "$USER_NAME"
git config --local user.email "$USER_EMAIL"

# Fetch everything from remote
git fetch origin

# Check if the branch "metadata" exists on the remote
if git show-ref --verify --quiet refs/remotes/origin/metadata; then
    # Branch exists, check it out
    git checkout metadata
else
    # Branch does not exist, create and check it out
    git checkout -b metadata
    git push --set-upstream origin metadata
fi

# Pull the latest changes from the branch
git pull origin metadata

# Go to images directory
cd "$IMAGE_DIR" || exit

commit_message="Annotations"

# Add json files to Git
git add "*.json"

# Commit changes
git commit -m "$commit_message"

# Push changes to the remote branch
git push origin metadata

# Return to original directory
cd -
