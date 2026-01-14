# ⚠️ IMPORTANT: File Location Fix Required

## Current Status

The model files were created in the wrong location with the wrong extension. This needs to be fixed before the PR can be merged.

## The Problem

**Current (WRONG):**
```
remotly_server/lib/src/user.spy.yaml
remotly_server/lib/src/notification_topic.spy.yaml
```

**Expected (CORRECT):**
```
remotly_server/lib/src/models/user.yaml
remotly_server/lib/src/models/notification_topic.yaml
```

## Quick Fix (One Command)

The `generate_models.sh` script now automatically fixes the file locations:

```bash
cd /home/runner/work/rmotly/rmotly
chmod +x generate_models.sh
./generate_models.sh
```

This will:
1. Create `lib/src/models/` directory
2. Move `user.spy.yaml` → `models/user.yaml`  
3. Move `notification_topic.spy.yaml` → `models/notification_topic.yaml`
4. Run `serverpod generate`
5. Create and apply migrations
6. Run tests

## After Running the Script

Commit the changes:
```bash
git add remotly_server/lib/src/models/
git status  # Should show old files deleted, new files added
git commit -m "fix: move models to correct location with correct extension"
```

## Why This Happened

The agent that created the files had limited tool access and could not:
- Create directories
- Move files with git commands
- Use bash/shell commands

Therefore, the files were created in the accessible location (`lib/src/`) using the extension from the example file (`.spy.yaml`).

## Alternative: Manual Fix

If you prefer to fix manually:

```bash
cd remotly_server

# Create directory
mkdir -p lib/src/models

# Move and rename files
git mv lib/src/user.spy.yaml lib/src/models/user.yaml
git mv lib/src/notification_topic.spy.yaml lib/src/models/notification_topic.yaml

# Verify
git status
ls -la lib/src/models/

# Then generate code
serverpod generate
```

## What's Correct

✅ **Model content** - All field definitions, indexes, and relations are correct
✅ **Model structure** - Follows Serverpod conventions  
✅ **Documentation** - Comprehensive guides provided
✅ **Tests** - Placeholder tests ready to be enhanced

❌ **File location** - Wrong directory (`lib/src/` instead of `lib/src/models/`)
❌ **File extension** - Wrong extension (`.spy.yaml` instead of `.yaml`)

## Verification

After fixing, verify with:
```bash
# Check files are in correct location
ls -la remotly_server/lib/src/models/
# Should see: user.yaml and notification_topic.yaml

# Check old files are gone
ls remotly_server/lib/src/*.spy.yaml 2>/dev/null || echo "Old files removed ✓"

# Generate and test
cd remotly_server
serverpod generate
dart test
```
