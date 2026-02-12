#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Building SketchyBar Swift helpers..."

for src in "$SCRIPT_DIR"/*.swift; do
    name="$(basename "$src" .swift)"
    # Convert PascalCase to snake_case for binary name
    binary=$(echo "$name" | sed 's/\([A-Z][a-z]\)/_\1/g' | sed 's/^_//' | tr '[:upper:]' '[:lower:]')
    echo "  Compiling $name -> $binary"
    swiftc "$src" -o "$SCRIPT_DIR/$binary"
done

echo "Done."
