#!/usr/bin/env bash

set -euo pipefail

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S.png"

OUTPUT="$(
    hyprctl -j monitors |
    python -c '
import json
import sys

for monitor in json.load(sys.stdin):
    if monitor.get("focused"):
        print(monitor["name"])
        break
'
)"

[ -n "$OUTPUT" ] || exit 1

grim -o "$OUTPUT" "$FILE"

wl-copy < "$FILE"

notify-send \
    "Screenshot Saved" \
    "$FILE"
