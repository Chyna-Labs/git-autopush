#!/bin/bash

# Directory to monitor
directory=$(dirname "$(realpath "$0")")

# Function to perform the git operations
perform_git_operations() {
  # Get the list of modified files
  files=$(git status --porcelain | awk '$1 != "D" {print $2}')

  # Iterate over each modified or untracked file
  while IFS= read -r file; do
    # Add the file
    git add "$file"

    # Get the filename without the path
    filename=$(basename "$file")

    # Construct the commit message
    commit_message="Updated $filename"

    # Commit the changes with the specific message
    git commit -m "$commit_message"
  done <<< "$files"

  # Get the list of deleted files
  deleted_files=$(git status --porcelain | awk '$1 == "D" {print $2}')

  # Iterate over each deleted file
  while IFS= read -r deleted_file; do
    # Remove the file from the repository
    git rm "$deleted_file"

    # Get the filename without the path
    filename=$(basename "$deleted_file")

    # Construct the commit message for deletion
    commit_message="Deleted $filename"

    # Commit the deletion with the specific message
    git commit -m "$commit_message"
  done <<< "$deleted_files"

  # Push the changes
  git push
}

# Monitor the script directory and its subdirectories for file modifications
while true; do
  # Wait for a file modification event
  inotifywait -q -r -e modify -e create -e delete "$directory"

  # Call the function to perform git operations
  perform_git_operations
done
