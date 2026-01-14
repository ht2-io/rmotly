#!/bin/bash
# Script to fix model file locations and names
# This addresses the review feedback about incorrect file naming and location

set -e

echo "========================================="
echo "Fixing Model File Locations and Names"
echo "========================================="
echo ""

cd /home/runner/work/rmotly/rmotly/remotly_server

# Create the models directory if it doesn't exist
echo "Creating lib/src/models directory..."
mkdir -p lib/src/models

# Move and rename user model
echo "Moving user.spy.yaml to lib/src/models/user.yaml..."
if [ -f "lib/src/user.spy.yaml" ]; then
    cp lib/src/user.spy.yaml lib/src/models/user.yaml
    git rm lib/src/user.spy.yaml
    echo "✓ User model fixed"
else
    echo "⚠ lib/src/user.spy.yaml not found"
fi

# Move and rename notification_topic model
echo "Moving notification_topic.spy.yaml to lib/src/models/notification_topic.yaml..."
if [ -f "lib/src/notification_topic.spy.yaml" ]; then
    cp lib/src/notification_topic.spy.yaml lib/src/models/notification_topic.yaml
    git rm lib/src/notification_topic.spy.yaml
    echo "✓ NotificationTopic model fixed"
else
    echo "⚠ lib/src/notification_topic.spy.yaml not found"
fi

# Add the new files
echo ""
echo "Adding corrected files to git..."
git add lib/src/models/user.yaml
git add lib/src/models/notification_topic.yaml

echo ""
echo "========================================="
echo "✓ Model files fixed!"
echo "========================================="
echo ""
echo "Files are now in the correct location:"
echo "  - lib/src/models/user.yaml"
echo "  - lib/src/models/notification_topic.yaml"
echo ""
echo "Next steps:"
echo "1. Commit these changes"
echo "2. Run: cd remotly_server && serverpod generate"
echo "3. Run: serverpod create-migration"
echo "4. Run: serverpod apply-migrations"
