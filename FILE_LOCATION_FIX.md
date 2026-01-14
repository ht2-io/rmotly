# File Location Fix - Action Required

## Issue

The Event model file was created in the wrong location with the wrong extension:

**Current:** `remotly_server/lib/src/event.spy.yaml` ❌  
**Required:** `remotly_server/lib/src/models/event.yaml` ✅

## Why This Matters

1. **Serverpod Convention:** Models must be in `lib/src/models/` directory for `serverpod generate` to work correctly
2. **File Extension:** Standard is `.yaml` not `.spy.yaml` (the `.spy` prefix is outdated)
3. **Code Generation Will Fail:** Running `serverpod generate` with the file in the wrong location will not work

## Fix Commands

```bash
cd remotly_server/lib/src
mkdir -p models
mv event.spy.yaml models/event.yaml
```

## Environment Limitation

The agent that created the model could not:
- Create directories (no bash access)
- Move files (no file system manipulation tools)
- Only had: view, create, edit, report_progress tools

Therefore, this must be done manually.

## Documentation Status

All documentation has been updated to reflect the correct path:
- ✅ `MANUAL_STEPS.md` - Step 0 added for file fix
- ✅ `COMPLETION_SUMMARY.md` - Documents issue with "Required Fix" section
- ✅ `EVENT_MODEL.md` - Updated file path with note about moving
- ✅ `EVENT_MODEL_QUICK_REF.md` - Setup commands include file move as Step 0
- ✅ `TASKS.md` - Action required note added to task 2.1.5

## Next Steps

1. Run the fix commands above
2. Verify file is at correct location: `ls remotly_server/lib/src/models/event.yaml`
3. Continue with Step 1 in `MANUAL_STEPS.md` (serverpod generate)

## File Content

The file content itself is correct and does not need any changes. Only the location and filename need to be fixed.
