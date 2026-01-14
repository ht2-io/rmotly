#!/bin/bash
# This script must be run to complete the file migration
# Run from repository root: bash MIGRATE_CONTROL_MODEL.sh

set -e

echo "Migrating Control model file..."

cd remotly_server/lib/src

# Create models directory
mkdir -p models

# Move and rename file
mv control.spy.yaml models/control.yaml

echo "✓ File migrated to lib/src/models/control.yaml"
echo ""
echo "Now run:"
echo "  cd remotly_server"
echo "  serverpod generate"
