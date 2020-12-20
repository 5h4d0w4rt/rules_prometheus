#!/usr/bin/env bash

set -euo pipefail

TOOL_PATH="%tool_path%"

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

TOOL_SHORT_PATH=$(find_runfile "$TOOL_PATH")
if [ -z "$TOOL_SHORT_PATH" ]; then
    echo "error: could not locate binary" >&2
    exit 1
fi
if [ -z "${BUILD_WORKSPACE_DIRECTORY-}" ]; then
    echo "error: BUILD_WORKSPACE_DIRECTORY not set" >&2
    exit 1
fi

pushd "${BUILD_WORKSPACE_DIRECTORY}" && pwd && $TOOL_SHORT_PATH "$@" \
    --config.file="$(readlink bazel-rules_prometheus)/external/prometheus_darwin/prometheus.yml" \
    --storage.tsdb.path="$(readlink bazel-rules_prometheus)/data/" && popd
