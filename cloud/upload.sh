#!/bin/bash

# Path to images
IMAGE_DIR=${1:-"/path/to/images"}
# Git author
AUTHOR_NAME=${2:-"Name"}
AUTHOR_EMAIL=${3:-"email@example.com"}

# Configure author
git config --local user.name "$AUTHOR_NAME"
git config --local user.email $AUTHOR_EMAIL

# Fetch everything from remote
git fetch origin

# Check if the branch "metadata" exists on the remote
if git show-ref --verify --quiet refs/remotes/origin/metadata; then
    # Branch exists, check it out and pull
    git checkout metadata
    git pull
else
    # Branch does not exist, create and check it out
    git checkout -b metadata
    git push --set-upstream origin metadata
fi

# Go to images directory
cd "$IMAGE_DIR" || exit

# Commit message
commit_message="Upload metadata"

# Add json files to Git
git add "*.json"

# Commit changes
git commit -m "$commit_message"

# Push changes to the remote branch
git push origin metadata

# Return to original directory
cd -
