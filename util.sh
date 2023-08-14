#!/bin/bash

function is_debug() {
  if [[ "$RUNNER_DEBUG" == "1" ]]; then
    return 0
  else
    return 1
  fi
}

# Output all commands
if is_debug; then
  set -x
fi

# Show line numbers
if is_debug; then
  export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
fi
