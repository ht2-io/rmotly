#!/bin/bash
# Script to fix Action model file naming and location

cd "$(dirname "$0")"

echo "Creating models directory..."
mkdir -p lib/src/models

echo "Moving and renaming action.spy.yaml to models/action.yaml..."
mv lib/src/action.spy.yaml lib/src/models/action.yaml

echo "Done! Action model is now at lib/src/models/action.yaml"
echo "Next step: Run 'serverpod generate' to update generated code"
