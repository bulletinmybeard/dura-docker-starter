#!/bin/bash

# Exit script immediately on any error
set -e

EVENT=$1
GIT_REPOS_DIR="/usr/local/src/git-repos"

if [[
  "$EVENT" != *".DS_Store"*
  || "$EVENT" != *"AttributeModified"*
  || "$EVENT" != *"PlatformSpecific"*
  || "$EVENT" != *"${GIT_REPOS_DIR} IsDir"*
]]; then

    EVENT_ARRAY=($EVENT)
    EVENTS=${EVENT_ARRAY[1]}
    DIRECTORY_PATH=${EVENT_ARRAY[0]}
    DIRECTORY_NAME=${DIRECTORY_PATH/${GIT_REPOS_DIR}/""}
    DIRECTORY_NAME="${DIRECTORY_NAME#?}"

    if [[ "$EVENTS" == *"Created"*
      && $(stat --format="%F" "${DIRECTORY_PATH}/.git") > /dev/null ]]; then
      echo "run dura watch (${DIRECTORY_NAME})"
    elif [[ "$EVENTS" == *"Removed"* ]]; then
      # Also check if the directory doesn't exists
      echo "run dura kill (${DIRECTORY_NAME})"
    fi
fi
