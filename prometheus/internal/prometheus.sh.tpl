#!/usr/bin/env bash

set -euo pipefail

TOOL_PATH="%tool_path%"
DATA_DIRECTORY_PATH="%data_directory_path%"

# apply correct permissions to the directory so prometheus server can write to it
# questionable trick but works
REAL_DIRECTORY="$(readlink $DATA_DIRECTORY_PATH)"
chmod -R 777 $REAL_DIRECTORY

echo $TOOL_PATH
$TOOL_PATH %args% "$@"
