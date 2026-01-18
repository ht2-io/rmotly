# Contributing to Rmotly

Thank you for your interest in contributing to Rmotly! This document provides guidelines for contributing to the project.

> **📖 New to the project?** Start with the [Development Setup Guide](DEVELOPMENT.md) for detailed environment setup instructions.

## Table of Contents

- [Getting Started](#getting-started)
- [Project Architecture](#project-architecture)
- [Development Workflow](#development-workflow)
- [Code Style](#code-style)
- [Git Workflow](#git-workflow)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Testing](#testing)
- [Documentation](#documentation)
- [Database Changes](#database-changes)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Code of Conduct](#code-of-conduct)

## Getting Started

### Prerequisites

- [Dart SDK](https://dart.dev/get-dart) 3.5+
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.24+
- [Docker](https://docs.docker.com/get-docker/)
- [Serverpod CLI](https://docs.serverpod.dev/installation)

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/rmotly.git
   cd rmotly
   ```

2. **Start development services**
   ```bash
   cd rmotly_server
   docker compose up -d
   ```

3. **Install server dependencies**
   ```bash
   cd rmotly_server
   dart pub get
   ```

4. **Generate Serverpod code**
   ```bash
   serverpod generate
   ```

5. **Apply database migrations**
   ```bash
   serverpod apply-migrations
   ```

6. **Start the server**
   ```bash
   dart run bin/main.dart
   ```

7. **Install app dependencies**
   ```bash
   cd rmotly_app
   flutter pub get
   ```

8. **Run the app**
   ```bash
   flutter run
   ```

## Project Architecture

### Server (`rmotly_server`)

The backend uses [Serverpod](https://serverpod.dev/), a Dart backend framework.

```
rmotly_server/
├── bin/main.dart           # Server entry point
├── lib/src/
│   ├── endpoints/          # API endpoints
│   ├── services/           # Business logic
│   └── generated/          # Auto-generated (don't edit)
├── config/                 # Environment configs
└── migrations/             # Database migrations
```

### App (`rmotly_app`)

The mobile app uses Flutter with Clean Architecture.

```
rmotly_app/
└── lib/
    ├── core/               # Shared code
    │   ├── providers/      # Riverpod providers
    │   ├── theme/          # App theming
    │   └── services/       # Core services
    ├── features/           # Feature modules
    │   ├── dashboard/      # Dashboard feature
    │   │   ├── data/       # Data layer
    │   │   ├── domain/     # Domain layer
    │   │   └── presentation/# UI layer
    │   └── ...
    └── shared/             # Shared widgets/services
```

## Development Workflow

### Making Your First Contribution

Follow this step-by-step guide for your first contribution:

1. **Fork the repository**
   - Click the "Fork" button on the GitHub repository page
   - This creates your own copy of the project

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/rmotly.git
   cd rmotly
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/rmotly.git
   ```

4. **Create a feature branch**
   ```bash
   git checkout -b feat/your-feature-name
   ```

5. **Make your changes**
   - Write code following our [Code Style](#code-style) guidelines
   - Add tests for new functionality
   - Update documentation as needed

6. **Test your changes**
   ```bash
   # Server tests
   cd rmotly_server
   dart test
   dart analyze
   
   # App tests
   cd rmotly_app
   flutter test
   flutter analyze
   ```

7. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat(scope): describe your changes"
   ```

8. **Push to your fork**
   ```bash
   git push origin feat/your-feature-name
   ```

9. **Create a Pull Request**
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Select your fork and branch
   - Fill in the PR template
   - Submit for review

### Keeping Your Fork Synced

Keep your fork up to date with the main repository:

```bash
# Fetch upstream changes
git fetch upstream

# Switch to your main branch
git checkout main

# Merge upstream changes
git merge upstream/main

# Push updates to your fork
git push origin main
```

### Rebase vs Merge

**When to rebase:**
- Updating your feature branch with latest `main`
- Cleaning up your commit history before creating a PR
- Your branch hasn't been pushed or shared with others

```bash
git checkout feat/your-feature
git rebase main
```

**When to merge:**
- Incorporating reviewed changes
- Your branch has already been pushed and others may have based work on it
- Resolving conflicts during a pull request

```bash
git checkout feat/your-feature
git merge main
```

**Important:** Never rebase commits that have been pushed to a shared branch or are part of an open pull request.

## Code Style

### Dart/Flutter

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` before committing
- Run `dart analyze` to check for issues
- Keep functions small and focused
- Use meaningful variable names

### File Naming

- Use snake_case for file names: `user_repository.dart`
- Use PascalCase for class names: `UserRepository`
- Use camelCase for variables and functions: `getUserById`

### Imports

Order imports as:
1. Dart SDK
2. Flutter SDK
3. External packages
4. Local imports

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/api_client_provider.dart';
import 'user_model.dart';
```

## Git Workflow

### Branch Naming

- `feat/feature-name` - New features
- `fix/bug-description` - Bug fixes
- `docs/documentation-topic` - Documentation
- `refactor/area` - Code refactoring
- `test/test-area` - Adding tests

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Code style (formatting, semicolons)
- `refactor` - Code refactoring
- `test` - Adding tests
- `chore` - Maintenance tasks

Examples:
```
feat(dashboard): add slider control widget
fix(auth): handle expired session tokens
docs(api): document webhook payload formats
refactor(actions): extract template parser to service
```

### Pull Requests

1. Create a feature branch from `main`
2. Make your changes
3. Run tests: `dart test` and `flutter test`
4. Run linter: `dart analyze`
5. Push and create a PR
6. Fill in the PR template
7. Request review

## Pull Request Process

### PR Size Guidelines

**Keep pull requests small and focused:**

- ✅ **Good PR sizes:**
  - Single feature implementation (< 500 lines)
  - Bug fix with test coverage (< 200 lines)
  - Documentation updates
  - Refactoring a single module

- ⚠️ **PRs that are too large:**
  - Multiple unrelated features (> 1000 lines)
  - Mixing features with refactoring
  - Large-scale architectural changes without discussion

**Breaking down large changes:**
1. Create an issue discussing the overall change
2. Break into smaller, logical PRs
3. Reference the parent issue in each PR
4. Submit PRs in dependency order

### Draft Pull Requests

Use draft PRs when:
- You want early feedback on approach
- Work is in progress but not ready for review
- You're experimenting with a solution

**Creating a draft PR:**
```bash
# Push your branch
git push origin feat/your-feature

# On GitHub, select "Create draft pull request"
```

**Converting to ready for review:**
- Click "Ready for review" button when your PR is complete
- Ensure all tests pass and CI is green
- Self-review your changes before requesting review

### Handling Review Feedback

**Responding to review comments:**

1. **Address each comment:**
   - Make requested changes, or
   - Discuss if you disagree with the suggestion
   - Mark conversations as resolved when addressed

2. **Making changes:**
   ```bash
   # Make changes based on feedback
   git add .
   git commit -m "fix: address review feedback"
   git push origin feat/your-feature
   ```

3. **Requesting re-review:**
   - Click "Re-request review" button after pushing changes
   - Add a comment summarizing what you changed

4. **Disagreements:**
   - Explain your reasoning politely
   - Be open to alternative approaches
   - Escalate to maintainers if needed

### PR Checklist

Before submitting your PR, ensure:

- [ ] Code follows the [Code Style](#code-style) guidelines
- [ ] All tests pass locally (`dart test` / `flutter test`)
- [ ] No linter errors (`dart analyze` / `flutter analyze`)
- [ ] New features include tests
- [ ] Documentation updated (if needed)
- [ ] Commit messages follow [Conventional Commits](#commit-messages)
- [ ] PR description clearly explains the changes
- [ ] References related issues (e.g., "Closes #123")
- [ ] Screenshots included for UI changes
- [ ] No merge conflicts with `main`

### PR Template

When creating a PR, fill in this template (auto-loaded from `.github/pull_request_template.md`):

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Closes #(issue number)

## Testing
How has this been tested?

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Tests pass
- [ ] Linter passes
- [ ] Documentation updated
```

## Issue Reporting

### Using Issue Templates

We provide issue templates to help you report problems effectively:

**Bug Report Template** (`.github/ISSUE_TEMPLATE/bug_report.yml`)
- Use when reporting unexpected behavior
- Include steps to reproduce
- Provide environment details

**Feature Request Template** (`.github/ISSUE_TEMPLATE/feature_request.yml`)
- Use for new feature suggestions
- Describe the problem it solves
- Propose a solution

**Documentation Issue Template** (`.github/ISSUE_TEMPLATE/documentation.yml`)
- Use for doc improvements
- Specify which doc needs updating
- Suggest improvements

### Before Creating an Issue

1. **Search existing issues** - Your issue may already exist
2. **Check discussions** - General questions go in Discussions
3. **Verify it's reproducible** - Confirm the bug on latest version
4. **Gather information** - Version numbers, error logs, screenshots

### Creating a Good Issue

**For bugs:**
- Clear, descriptive title
- Steps to reproduce
- Expected vs actual behavior
- Environment (OS, Dart/Flutter versions)
- Error messages and logs
- Screenshots or videos

**For features:**
- Clear use case
- Why existing solutions don't work
- Proposed implementation (optional)
- Willing to contribute? (mention it!)

**Example bug report:**
```markdown
**Bug:** Server crashes when processing webhook with missing signature

**Steps to Reproduce:**
1. Send POST request to /webhooks/device
2. Omit X-Signature header
3. Server returns 500 error and crashes

**Expected:** Should return 401 Unauthorized

**Environment:**
- Dart SDK: 3.5.0
- Serverpod: 1.2.0
- OS: Ubuntu 22.04

**Logs:**
[paste error logs]
```

## Testing

### Server Tests

```bash
cd rmotly_server
dart test
```

### App Tests

```bash
cd rmotly_app
flutter test
```

### Writing Tests

- Place tests in `test/` directory
- Mirror the `lib/` structure
- Name test files with `_test.dart` suffix
- Use descriptive test names

```dart
void main() {
  group('UserRepository', () {
    test('returns user when found', () async {
      // Arrange
      final repository = UserRepository(mockClient);

      // Act
      final user = await repository.getUser(1);

      // Assert
      expect(user, isNotNull);
      expect(user.id, equals(1));
    });
  });
}
```

## Documentation

### Code Comments

- Use `///` for doc comments on public APIs
- Explain "why", not "what"
- Keep comments up to date

```dart
/// Executes an HTTP action with the given parameters.
///
/// Template variables in the URL, headers, and body are replaced
/// with values from [parameters].
///
/// Throws [ActionExecutionException] if the request fails after
/// all retry attempts.
Future<ActionResult> execute(Action action, Map<String, dynamic> parameters);
```

### Updating Documentation

- Update `docs/*.md` for major changes
- Keep README.md current
- Add JSDoc-style comments to new endpoints

## Database Changes

### Creating Migrations

1. Modify model files in `lib/src/models/`
2. Generate code: `serverpod generate`
3. Create migration: `serverpod create-migration`
4. Review the generated migration
5. Apply: `serverpod apply-migrations`

### Migration Guidelines

- Never modify existing migrations
- Test migrations on a copy of production data
- Include rollback considerations

## Security

- Never commit secrets or credentials
- Use environment variables for sensitive data
- Follow the principle of least privilege
- Validate all user input
- See `docs/SECURITY_BEST_PRACTICES.md`

## Troubleshooting

Common issues developers encounter and how to solve them:

### "serverpod command not found"

**Problem:** The `serverpod` CLI is not in your PATH.

**Solution:**
```bash
# Install/update Serverpod CLI
dart pub global activate serverpod_cli

# Ensure Dart global bin is in PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Add to ~/.bashrc or ~/.zshrc to make permanent
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Database Connection Issues

**Problem:** Server can't connect to PostgreSQL/Redis.

**Symptoms:**
```
Exception: Failed to connect to database
Connection refused on localhost:5432
```

**Solution:**
```bash
# Check if Docker containers are running
docker ps

# If not running, start them
cd rmotly_server
docker compose up -d

# Check container logs
docker compose logs postgres
docker compose logs redis

# Verify connection settings in config/development.yaml
# Ensure host, port, username, password match docker-compose.yml
```

### Model Generation Problems

**Problem:** `serverpod generate` fails or generates incorrect code.

**Common causes:**
- Syntax errors in model YAML files
- Missing dependencies
- Outdated Serverpod CLI

**Solution:**
```bash
# Check for syntax errors in lib/src/models/*.spy.yaml
# Validate YAML syntax online if needed

# Update Serverpod CLI
dart pub global activate serverpod_cli

# Clean and regenerate
cd rmotly_server
rm -rf lib/src/generated
serverpod generate

# If still failing, check Serverpod version compatibility
dart pub outdated
```

### Flutter Analyze Errors

**Problem:** `flutter analyze` reports errors.

**Common errors and fixes:**

**Unused imports:**
```dart
// Remove or comment out unused imports
// import 'package:unused/unused.dart';  // Not used, remove this
```

**Missing await:**
```dart
// Bad
fetchData();  // Returns Future, should be awaited

// Good
await fetchData();
```

**Prefer const constructors:**
```dart
// Bad
Widget build(BuildContext context) {
  return Text('Hello');
}

// Good
Widget build(BuildContext context) {
  return const Text('Hello');
}
```

**Run auto-fix for simple issues:**
```bash
dart fix --apply
flutter analyze
```

### Port Conflicts

**Problem:** Port 8080 or 8090 already in use.

**Symptoms:**
```
SocketException: Address already in use
Failed to start server on port 8080
```

**Solution:**

**Option 1: Kill the process using the port**
```bash
# Find process using port 8080
lsof -i :8080

# Kill the process (replace PID with actual process ID)
kill -9 PID
```

**Option 2: Change the port**
```yaml
# rmotly_server/config/development.yaml
apiServer:
  port: 8081  # Change to available port
  
webServer:
  port: 8091  # Change to available port
```

### Flutter Run Fails

**Problem:** `flutter run` fails with various errors.

**Generic troubleshooting steps:**
```bash
# 1. Clean the project
flutter clean
flutter pub get

# 2. Update Flutter
flutter upgrade

# 3. Check doctor
flutter doctor -v

# 4. Clear derived data (specific issues)
rm -rf ~/Library/Developer/Xcode/DerivedData  # macOS
rm -rf ~/.gradle/caches  # Android

# 5. Restart IDE and try again
```

### Git Merge Conflicts

**Problem:** Conflicts when rebasing or merging.

**Solution:**
```bash
# Check which files have conflicts
git status

# Open conflicting files and look for:
# <<<<<<< HEAD
# your changes
# =======
# their changes
# >>>>>>> branch-name

# Resolve manually, then:
git add resolved-file.dart
git rebase --continue

# Or if you want to abort:
git rebase --abort
```

### Tests Failing Locally

**Problem:** Tests pass in CI but fail locally (or vice versa).

**Common causes:**
- Different Dart/Flutter versions
- Cached test data
- Environment variables not set
- Timezone differences

**Solution:**
```bash
# Check versions
dart --version
flutter --version

# Clean test cache
cd rmotly_server
rm -rf .dart_tool
dart pub get

cd ../rmotly_app
flutter clean
flutter pub get

# Run tests with verbose output
dart test --reporter=expanded
flutter test --verbose

# Check if environment variables are needed
# Copy .env.example to .env and fill values
```

### Still Having Issues?

1. **Check documentation:** Review `docs/*.md` for detailed guides
2. **Search issues:** Someone may have encountered the same problem
3. **Ask for help:** Open a discussion or issue with:
   - What you're trying to do
   - What error you're seeing
   - What you've tried so far
   - Your environment (OS, versions)

## Getting Help

- Open an issue for bugs or feature requests
- Use discussions for questions
- Check existing issues before creating new ones

## Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors.

**Our Standards:**
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards others

**Unacceptable Behavior:**
- Harassment, trolling, or discriminatory comments
- Personal attacks or insults
- Publishing others' private information
- Any conduct inappropriate in a professional setting

**Reporting Issues:**
If you experience or witness unacceptable behavior, please report it to the project maintainers. All complaints will be reviewed and investigated promptly and fairly.

**Full Code of Conduct:**
Please read our complete [Code of Conduct](CODE_OF_CONDUCT.md) for detailed guidelines and enforcement policies.

We follow the [Contributor Covenant](https://www.contributor-covenant.org/) version 2.1.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
