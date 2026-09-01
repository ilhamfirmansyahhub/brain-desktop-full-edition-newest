#!/usr/bin/env bash

set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

GEOM="$(slurp)"

[ -n "$GEOM" ] || exit 0

grim -g "$GEOM" "$FILE"

wl-copy < "$FILE"

notify-send \
    "Screenshot Saved" \
    "$FILE"
