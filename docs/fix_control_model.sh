#!/bin/bash
# Fix script for Control model location issue
# This script moves control.spy.yaml to the correct location as models/control.yaml

set -e

cd "$(dirname "$0")/../remotly_server"

echo "Fixing Control model file location and naming..."
echo ""

# Create models directory
echo "Creating lib/src/models directory..."
mkdir -p lib/src/models

# Check if old file exists and move it
if [ -f "lib/src/control.spy.yaml" ]; then
    echo "Moving lib/src/control.spy.yaml to lib/src/models/control.yaml..."
    mv lib/src/control.spy.yaml lib/src/models/control.yaml
    echo "✓ File successfully moved and renamed"
else
    echo "⚠ File lib/src/control.spy.yaml not found"
    echo "  Using template from docs/control.yaml.template instead..."
    if [ -f "../docs/control.yaml.template" ]; then
        cp ../docs/control.yaml.template lib/src/models/control.yaml
        echo "✓ Created lib/src/models/control.yaml from template"
    else
        echo "✗ Template file not found either"
        exit 1
    fi
fi

echo ""
echo "✅ Fix complete!"
echo ""
echo "File is now at: remotly_server/lib/src/models/control.yaml"
echo ""
echo "Next steps:"
echo "  1. Run: serverpod generate"
echo "  2. Run: serverpod create-migration"
echo "  3. Run: serverpod apply-migrations"

