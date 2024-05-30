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
echo "Fetching origin..."
git fetch origin

# Check if the branch "metadata" exists on the remote
if git show-ref --verify --quiet refs/remotes/origin/metadata; then
    # Branch exists, check it out and pull
    echo "Branch 'metadata' already exists"
    echo "Checking out branch 'metadata'..."
    git checkout metadata
    echo "Pulling..."
    git pull
else
    # Branch does not exist, create and check it out
    echo "Branch 'metadata' does not exist"
    echo "Creating and checking out branch 'metadata'..."
    git checkout -b metadata
    echo "Setting upstream and pushing branch 'metadata'..."
    git push --set-upstream origin metadata
fi

# Go to images directory
cd "$IMAGE_DIR" || exit

# Commit message
commit_message="Upload metadata"

# Add json files to Git
echo "Staging .json files..."
git add "*.json"

# Commit changes
echo "Commiting..."
git commit -m "$commit_message"

# Push changes to the remote branch
echo "Pushing..."
git push origin metadata
echo "Push successful"

# Return to original directory
cd -
