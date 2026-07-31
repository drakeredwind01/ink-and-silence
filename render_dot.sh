#!/usr/bin/env bash
# Render a .dot file to SVG and open it in Firefox (bypasses the OS default
# SVG viewer, which won't load externally-referenced images).
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "usage: $(basename "$0") <file.dot>" >&2
    exit 1
fi

dot_file="$1"
if [ ! -f "$dot_file" ]; then
    echo "error: no such file: $dot_file" >&2
    exit 1
fi

abs_dot_file="$(realpath "$dot_file")"
svg_file="${abs_dot_file%.dot}.svg"

dot -Tsvg "$abs_dot_file" -o "$svg_file"
firefox "file://$svg_file"
