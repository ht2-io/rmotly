#!/bin/bash
# Script to generate Serverpod code for User and NotificationTopic models
# Run this script from the repository root directory

set -e  # Exit on error

echo "==================================="
echo "Serverpod Code Generation Script"
echo "==================================="
echo ""

# Check if serverpod CLI is installed
if ! command -v serverpod &> /dev/null; then
    echo "✗ Serverpod CLI not found"
    echo "Install it with: dart pub global activate serverpod_cli"
    exit 1
fi

echo "✓ Serverpod CLI found: $(serverpod --version)"
echo ""

# Navigate to server directory
cd remotly_server

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
echo "✓ Generation completed successfully!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Review generated files in lib/src/generated/"
echo "2. Review migration file in migrations/"
echo "3. Update Flutter app dependencies: cd ../remotly_app && flutter pub get"
echo "4. Start the server: dart bin/main.dart"
echo ""
echo "Generated files are in .gitignore and will not be committed."
echo "Remember to run 'serverpod generate' in CI/CD and local builds."
