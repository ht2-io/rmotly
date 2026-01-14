# Next Steps for User Model Setup

## Status: User Model Created ✅

The User model YAML file has been successfully created at:
- **Location**: `remotly_server/lib/src/models/user.yaml`

## Required Manual Steps

To complete the User model setup, run the following commands in a development environment with Flutter and Dart installed:

### 1. Generate Code from Model

```bash
cd remotly_server
serverpod generate
```

This will:
- Generate Dart classes in `lib/src/generated/`
- Update client code in `remotly_client/`
- Create protocol files

### 2. Create Database Migration

```bash
serverpod create-migration
```

This will:
- Create a migration file in `migrations/` directory
- Include SQL for creating the `users` table with all fields and indexes

### 3. Start Database Services

If not already running:

```bash
docker compose up --build --detach
```

This starts:
- PostgreSQL on port 8090
- Redis on port 8091

### 4. Apply Database Migration

```bash
serverpod apply-migrations
```

This will:
- Execute the SQL migration against PostgreSQL
- Create the `users` table with proper schema

### 5. Verify Server Starts

```bash
dart bin/main.dart
```

Expected output:
```
Server starting...
Serverpod listening on port 8080
```

### 6. Run Server Tests

```bash
dart test
```

Verify all tests pass.

## User Model Details

**Table**: `users`

**Fields**:
- `id` (auto-generated primary key)
- `email` (String, unique indexed)
- `displayName` (String?, optional)
- `fcmToken` (String?, optional - for push notifications)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)

**Indexes**:
- `user_email_idx` - Unique btree index on email field

## Troubleshooting

If you encounter issues:

1. **"serverpod command not found"**
   ```bash
   dart pub global activate serverpod_cli
   export PATH="$PATH:$HOME/.pub-cache/bin"
   ```

2. **"Database connection failed"**
   - Ensure Docker containers are running: `docker compose ps`
   - Check config in `config/development.yaml`

3. **"Migration already applied"**
   - Don't modify existing migrations
   - Create new migration for any future changes

## References

- Serverpod Documentation: https://docs.serverpod.dev
- Model Definition Guide: See `.github/skills/serverpod-generate/README.md`
- Project Tasks: See `TASKS.md` (Task 2.1.1 is now complete)
