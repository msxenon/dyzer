#!/bin/bash
# This script sets up the development workspace for the Dyzer project
# Define the target file path
TARGET_FILE="packages/dyzer/tools/analyzer_plugin/pubspec_overrides.yaml"

# Create the directory if it doesn't exist
mkdir -p "$(dirname "$TARGET_FILE")"

# Write the content to the file
cat > "$TARGET_FILE" <<EOF
dependency_overrides:
    dyzer:
        path: $(pwd)/packages/dyzer
EOF

echo "File created at $TARGET_FILE"