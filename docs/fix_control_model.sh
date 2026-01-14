#!/bin/bash
# Fix script for Control model location issue
# This script moves control.spy.yaml to the correct location as models/control.yaml

cd "$(dirname "$0")/../remotly_server"

echo "Fixing Control model file location..."

# Create models directory
mkdir -p lib/src/models

# Move and rename file
if [ -f "lib/src/control.spy.yaml" ]; then
    mv lib/src/control.spy.yaml lib/src/models/control.yaml
    echo "✓ File moved to lib/src/models/control.yaml"
else
    echo "✗ File lib/src/control.spy.yaml not found"
fi
