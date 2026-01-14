# Control Model Location Fix

## Problem

The Control model file was created with:
- **Wrong extension**: `.spy.yaml` instead of `.yaml`
- **Wrong location**: `lib/src/` instead of `lib/src/models/`

## Current State

```
remotly_server/lib/src/control.spy.yaml  ❌ WRONG
```

## Expected State

```
remotly_server/lib/src/models/control.yaml  ✅ CORRECT
```

## How to Fix

### Option 1: Run the Fix Script (Recommended)

```bash
cd /path/to/rmotly
bash docs/fix_control_model.sh
```

This will:
1. Create the `lib/src/models` directory
2. Move and rename the file to the correct location
3. Provide next steps for code generation

### Option 2: Manual Fix

```bash
cd remotly_server/lib/src

# Create models directory
mkdir -p models

# Move and rename file
mv control.spy.yaml models/control.yaml
```

### Option 3: Use the Template

If the original file is missing or corrupted:

```bash
cd remotly_server/lib/src
mkdir -p models
cp ../../docs/control.yaml.template models/control.yaml
```

## After Fixing

Once the file is in the correct location, run:

```bash
cd remotly_server
serverpod generate
serverpod create-migration
serverpod apply-migrations
dart test
```

## Documentation Updates

The following files have been updated to reflect the correct path:
- ✅ `docs/MODELS.md` - Updated model file location
- ✅ `remotly_server/README.md` - Updated workflow instructions
- ✅ `TASKS.md` - Added note about file location fix needed
- ✅ `docs/control.yaml.template` - Template with correct content
- ✅ `docs/fix_control_model.sh` - Automated fix script

## Why This Matters

According to Serverpod conventions:
- Model files should use `.yaml` extension (not `.spy.yaml`)
- Model files should be in `lib/src/models/` directory
- This ensures proper code generation and follows framework best practices

## Reference

- Serverpod docs: https://docs.serverpod.dev/concepts/models
- Project TASKS.md: Task 2.1.2
- GitHub Issue: #3
