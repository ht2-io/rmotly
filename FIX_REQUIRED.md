# Fix Required: Model Files Location and Naming

## Issue
The model files were created with incorrect naming and location:
- ❌ Wrong extension: `.spy.yaml` instead of `.yaml`
- ❌ Wrong location: `lib/src/` instead of `lib/src/models/`

## Required Changes

### Current Structure (Incorrect)
```
remotly_server/lib/src/
├── user.spy.yaml                    # WRONG
└── notification_topic.spy.yaml      # WRONG
```

### Expected Structure (Correct)
```
remotly_server/lib/src/models/
├── user.yaml                        # CORRECT
└── notification_topic.yaml          # CORRECT
```

## How to Fix

### Option 1: Automated Script (Recommended)
```bash
chmod +x fix_model_locations.sh
./fix_model_locations.sh
```

### Option 2: Manual Steps
```bash
cd remotly_server

# Create models directory
mkdir -p lib/src/models

# Move and rename user model
git mv lib/src/user.spy.yaml lib/src/models/user.yaml

# Move and rename notification_topic model
git mv lib/src/notification_topic.spy.yaml lib/src/models/notification_topic.yaml

# Verify
ls -la lib/src/models/
```

### Option 3: Delete and Recreate
If git mv doesn't work properly:

```bash
cd remotly_server

# Create models directory
mkdir -p lib/src/models

# Remove old files
git rm lib/src/user.spy.yaml
git rm lib/src/notification_topic.spy.yaml

# Create new files with correct names in correct location
# (Copy content from old files to new location)
```

## After Fixing

Once files are in the correct location, run:

```bash
cd remotly_server
serverpod generate
serverpod create-migration
serverpod apply-migrations
```

## Why This Matters

1. **Serverpod Convention**: Models should be in `lib/src/models/` directory
2. **File Extension**: Should be `.yaml` not `.spy.yaml`
3. **Documentation**: TASKS.md specifies `lib/src/models/` as the location
4. **Code Generation**: Serverpod looks for models in `lib/src/models/*.yaml`

## Model Content (Unchanged)

The actual model definitions are correct - only the file location and names need to be fixed. The content remains the same.
