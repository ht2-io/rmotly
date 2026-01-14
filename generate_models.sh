#!/bin/bash
# Script to fix model locations and generate Serverpod code
# Run this script from the repository root directory

set -e  # Exit on error

echo "==================================="
echo "Serverpod Model Fix & Generation"
echo "==================================="
echo ""

cd remotly_server

# Step 0: Fix model file locations
echo "Step 0: Fixing model file locations..."
if [ -f "lib/src/user.spy.yaml" ] || [ -f "lib/src/notification_topic.spy.yaml" ]; then
    echo "  Creating lib/src/models directory..."
    mkdir -p lib/src/models
    
    if [ -f "lib/src/user.spy.yaml" ]; then
        echo "  Moving user.spy.yaml -> lib/src/models/user.yaml"
        mv lib/src/user.spy.yaml lib/src/models/user.yaml
    fi
    
    if [ -f "lib/src/notification_topic.spy.yaml" ]; then
        echo "  Moving notification_topic.spy.yaml -> lib/src/models/notification_topic.yaml"
        mv lib/src/notification_topic.spy.yaml lib/src/models/notification_topic.yaml
    fi
    
    echo "✓ Model files moved to correct location"
else
    echo "✓ Model files already in correct location"
fi

# Check if serverpod CLI is installed
if ! command -v serverpod &> /dev/null; then
    echo "✗ Serverpod CLI not found"
    echo "Install it with: dart pub global activate serverpod_cli"
    exit 1
fi

echo "✓ Serverpod CLI found: $(serverpod --version)"
echo ""

echo "Step 1: Running serverpod generate..."
serverpod generate

if [ $? -eq 0 ]; then
    echo "✓ Code generation completed successfully"
else
    echo "✗ Code generation failed"
    exit 1
fi

echo ""
echo "Step 2: Creating database migration..."
serverpod create-migration

if [ $? -eq 0 ]; then
    echo "✓ Migration created successfully"
    echo "  Migration file created in migrations/ directory"
else
    echo "✗ Migration creation failed"
    echo "  This may be normal if database is not running or no schema changes detected"
    echo "  You can skip this step if intentional"
fi

echo ""
echo "Step 3: Applying database migrations..."
echo "  NOTE: This requires PostgreSQL to be running"

read -p "Apply migrations now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    serverpod apply-migrations
    if [ $? -eq 0 ]; then
        echo "✓ Migrations applied successfully"
    else
        echo "✗ Migration application failed"
        echo "  Make sure PostgreSQL is running and config/development.yaml is correct"
        exit 1
    fi
else
    echo "⚠ Skipping migration application"
    echo "  Run manually later with: cd remotly_server && serverpod apply-migrations"
fi

echo ""
echo "Step 4: Running server tests..."
dart test

if [ $? -eq 0 ]; then
    echo "✓ All tests passed"
else
    echo "✗ Some tests failed"
    echo "  Review test output above for details"
    exit 1
fi

echo ""
echo "==================================="
echo "✓ Setup completed successfully!"
echo "==================================="
echo ""
echo "Model files are now at:"
echo "  - lib/src/models/user.yaml"
echo "  - lib/src/models/notification_topic.yaml"
echo ""
echo "Next steps:"
echo "1. Review generated files in lib/src/generated/"
echo "2. Review migration file in migrations/"
echo "3. Git add the model files: git add lib/src/models/"
echo "4. Update Flutter app: cd ../remotly_app && flutter pub get"
echo "5. Start the server: dart bin/main.dart"
echo ""
echo "Generated files are in .gitignore and will not be committed."
echo "Remember to run 'serverpod generate' in CI/CD and local builds."
