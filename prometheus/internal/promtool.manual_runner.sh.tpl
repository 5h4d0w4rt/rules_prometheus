#!/usr/bin/env bash

set -euo pipefail

ARGS=""
function find_runfile() {
    local runfile=$1
    if [ -f "$runfile" ]; then
        readlink "$runfile"
        return
    fi
    runfile=$(echo "$runfile" | sed -e 's!^\(\.\./\|external/\)!!')
    if grep -q "^$runfile" MANIFEST; then
        grep "^$runfile" MANIFEST | head -n 1 | cut -d' ' -f2
        return
    fi
    # printing nothing indicates failure
}

# If arguments were provided on the command line, either replace or augment
# the generated args.
if [ "${1-}" = "-args" ]; then
    shift
    ARGS+=("$@")
elif [ $# -ne 0 ]; then
    ARGS=("$@")
fi

tool_short_path=$(find_runfile "%tool_path%")
if [ -z "%tool_path%" ]; then
    echo "error: could not locate binary" >&2
    exit 1
fi
if [ -z "${BUILD_WORKSPACE_DIRECTORY-}" ]; then
    echo "error: BUILD_WORKSPACE_DIRECTORY not set" >&2
    exit 1
fi

cd $BUILD_WORKSPACE_DIRECTORY
$tool_short_path "$@"
