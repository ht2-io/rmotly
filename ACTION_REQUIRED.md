# ACTION REQUIRED: Control Model File Relocation

## Summary

The Control model file needs to be moved to comply with Serverpod conventions.

## Quick Fix (Copy & Paste)

```bash
cd remotly_server/lib/src
mkdir -p models
mv control.spy.yaml models/control.yaml
cd ../../..
cd remotly_server
serverpod generate
```

## What Changed

| Before (Wrong) | After (Correct) |
|----------------|-----------------|
| `lib/src/control.spy.yaml` | `lib/src/models/control.yaml` |
| `.spy.yaml` extension | `.yaml` extension |
| In `lib/src/` | In `lib/src/models/` |

## Why This Fix is Needed

1. **Serverpod Convention**: Models must be in `lib/src/models/` directory
2. **File Extension**: Should be `.yaml` not `.spy.yaml`
3. **Code Generation**: `serverpod generate` expects models in the correct location
4. **Consistency**: Matches all other model definitions per TASKS.md

## Automated Fix Available

```bash
bash docs/fix_control_model.sh
```

This script will:
- ✅ Create the models directory
- ✅ Move and rename the file
- ✅ Verify the operation
- ✅ Show next steps

## Manual Fix Instructions

If you prefer to do it manually:

```bash
# Navigate to server lib/src
cd remotly_server/lib/src

# Create models directory if it doesn't exist
mkdir -p models

# Move and rename the file
mv control.spy.yaml models/control.yaml

# Verify
ls -la models/control.yaml
# Should show: models/control.yaml

# Generate code
cd ../..
serverpod generate
```

## Verification

After the fix, verify:

```bash
# Check file exists at correct location
ls remotly_server/lib/src/models/control.yaml

# Check old location is gone
ls remotly_server/lib/src/control.spy.yaml
# Should show: No such file or directory

# Generate and test
cd remotly_server
serverpod generate
dart test
```

## Documentation is Already Updated

All documentation has been updated to reference the correct location:
- ✅ docs/MODELS.md
- ✅ remotly_server/README.md  
- ✅ TASKS.md
- ✅ All guide files

So after you move the file, everything will be consistent!

## Need Help?

See `docs/CONTROL_MODEL_FIX.md` for detailed instructions and troubleshooting.
