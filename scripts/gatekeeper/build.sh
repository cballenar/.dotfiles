#!/bin/bash

# Gatekeeper Build Script
# Usage: GATEKEEPER_UUID=your-uuid-here ./build.sh

set -e

# 1. Validate Input
if [ -z "$GATEKEEPER_UUID" ]; then
    echo "❌ Error: GATEKEEPER_UUID environment variable is not set."
    echo "Usage: GATEKEEPER_UUID=your-uuid-here ./build.sh"
    exit 1
fi

SOURCE_FILE="gatekeeper.swift"
TEMP_FILE="gatekeeper_temp.swift"
OUTPUT_BINARY="$HOME/.local/bin/gatekeeper"

# 2. Cleanup Function
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT

# Ensure output directory exists
if [ ! -d "$(dirname "$OUTPUT_BINARY")" ]; then
    echo "❌ Error: Output directory $(dirname "$OUTPUT_BINARY") does not exist."
    exit 1
fi

# 3. Inject Secret
# We use sed to replace the placeholder in a temporary file
echo "🔐 Injecting UUID into temporary build file..."
sed "s/GATEKEEPER_UUID_PLACEHOLDER/$GATEKEEPER_UUID/g" "$SOURCE_FILE" > "$TEMP_FILE"

# 4. Compile
echo "🔨 Compiling Gatekeeper to $OUTPUT_BINARY..."
swiftc "$TEMP_FILE" -o "$OUTPUT_BINARY"

# 5. Verify
if [ -f "$OUTPUT_BINARY" ]; then
    echo "✅ Build successful!"
    echo "   Binary: $OUTPUT_BINARY"
    echo "   UUID:   Indicated as $GATEKEEPER_UUID"
else
    echo "❌ Build failed. No binary produced."
    exit 1
fi
