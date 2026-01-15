# CI/CD Documentation

This document describes the Continuous Integration and Continuous Deployment (CI/CD) setup for the Rmotly project.

## Table of Contents

- [Overview](#overview)
- [Continuous Integration](#continuous-integration)
- [Deployment Workflows](#deployment-workflows)
- [Branch Protection](#branch-protection)
- [Status Badges](#status-badges)

---

## Overview

The Rmotly project uses GitHub Actions for automated testing, building, and deployment. The CI/CD setup ensures code quality and enables reliable deployments.

### Workflows

| Workflow | File | Trigger | Purpose |
|----------|------|---------|---------|
| CI | `.github/workflows/ci.yml` | Push to main, PRs | Automated testing and building |
| AWS Deployment | `.github/workflows/deployment-aws.yml` | Push to deployment branches | Deploy to AWS |
| GCP Deployment | `.github/workflows/deployment-gcp.yml` | Push to deployment branches | Deploy to Google Cloud |

---

## Continuous Integration

The CI workflow (`.github/workflows/ci.yml`) runs on every push to the `main` branch and on all pull requests. It ensures code quality through automated analysis, testing, and building.

### Jobs

#### 1. analyze-app

Analyzes the Flutter mobile app code for potential issues.

- **Runs on:** `ubuntu-latest`
- **Flutter version:** 3.27.4
- **Steps:**
  1. Checkout code
  2. Setup Flutter SDK
  3. Install dependencies (`flutter pub get`)
  4. Analyze code (`flutter analyze`)

#### 2. analyze-server

Analyzes the Serverpod backend server code for potential issues.

- **Runs on:** `ubuntu-latest`
- **Dart version:** 3.6.2
- **Steps:**
  1. Checkout code
  2. Setup Dart SDK
  3. Install dependencies (`dart pub get`)
  4. Analyze code (`dart analyze`)

#### 3. test-app

Runs unit and widget tests for the Flutter app with coverage reporting.

- **Runs on:** `ubuntu-latest`
- **Flutter version:** 3.27.4
- **Steps:**
  1. Checkout code
  2. Setup Flutter SDK
  3. Install dependencies
  4. Run tests with coverage (`flutter test --coverage`)
  5. Upload coverage to Codecov (optional)

**Coverage reports** are uploaded to Codecov for tracking test coverage over time.

#### 4. test-server

Runs unit and integration tests for the Serverpod server.

- **Runs on:** `ubuntu-latest`
- **Dart version:** 3.6.2
- **Services:**
  - PostgreSQL 17 (port 5432)
  - Redis 8 (port 6379)
- **Steps:**
  1. Checkout code
  2. Setup Dart SDK
  3. Install dependencies
  4. Run tests (`dart test`)

**Note:** PostgreSQL and Redis services are automatically provisioned and configured with health checks.

#### 5. build-app

Builds a release APK of the Flutter app.

- **Runs on:** `ubuntu-latest`
- **Depends on:** `analyze-app`, `test-app`
- **Flutter version:** 3.27.4
- **Steps:**
  1. Checkout code
  2. Setup Flutter SDK
  3. Install dependencies
  4. Build release APK (`flutter build apk --release`)
  5. Upload APK as artifact (7-day retention)

**Artifacts** are available for download from the GitHub Actions run page.

#### 6. build-server

Compiles the Serverpod server for deployment.

- **Runs on:** `ubuntu-latest`
- **Depends on:** `analyze-server`, `test-server`
- **Dart version:** 3.6.2
- **Steps:**
  1. Checkout code
  2. Setup Dart SDK
  3. Install dependencies
  4. Compile server (`dart compile kernel bin/main.dart`)

### Triggers

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
```

The CI workflow runs on:
- Every push to the `main` branch
- Every pull request targeting the `main` branch

### Environment Variables

The test-server job uses the following environment variables for database connectivity:

| Variable | Value | Description |
|----------|-------|-------------|
| `POSTGRES_HOST` | localhost | PostgreSQL host |
| `POSTGRES_PORT` | 5432 | PostgreSQL port |
| `POSTGRES_USER` | postgres | PostgreSQL username |
| `POSTGRES_PASSWORD` | postgres | PostgreSQL password |
| `POSTGRES_DB` | rmotly_test | Test database name |
| `REDIS_HOST` | localhost | Redis host |
| `REDIS_PORT` | 6379 | Redis port |

---

## Deployment Workflows

### AWS Deployment

**File:** `.github/workflows/deployment-aws.yml`

**Triggers:**
- Push to `deployment-aws-production` or `deployment-aws-staging` branches
- Manual workflow dispatch

**Steps:**
1. Checkout code with submodules
2. Setup Dart SDK (3.5)
3. Configure AWS credentials
4. Create passwords configuration file
5. Install dependencies
6. Compile server
7. Deploy to AWS CodeDeploy

**Required Secrets:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `SERVERPOD_PASSWORDS`

### GCP Deployment

**File:** `.github/workflows/deployment-gcp.yml`

**Triggers:**
- Push to `deployment-gcp-production` or `deployment-gcp-staging` branches
- Manual workflow dispatch

**Steps:**
1. Checkout code with submodules
2. Authenticate to Google Cloud
3. Create passwords configuration file
4. Configure Docker
5. Build Docker image
6. Tag Docker image
7. Push to Google Container Registry

**Required Secrets:**
- `GOOGLE_CREDENTIALS`
- `SERVERPOD_PASSWORDS`

**Note:** You must update the `PROJECT` environment variable in the workflow file with your GCP project ID.

**See also:** [Complete Deployment Guide](DEPLOYMENT.md) for detailed deployment instructions and troubleshooting.

---

## Branch Protection

To ensure code quality, configure branch protection rules for the `main` branch:

### Recommended Settings

1. **Require pull request before merging**
   - Require at least 1 approval
   - Dismiss stale reviews when new commits are pushed

2. **Require status checks to pass before merging**
   - Required checks:
     - `analyze-app`
     - `analyze-server`
     - `test-app`
     - `test-server`
     - `build-app`
     - `build-server`
   - Require branches to be up to date before merging

3. **Require conversation resolution**
   - All review comments must be resolved before merging

4. **Do not allow force pushes**

5. **Do not allow deletions**

### Configuration via GitHub Web UI

1. Go to repository Settings → Branches
2. Add branch protection rule for `main`
3. Configure settings as listed above
4. Click "Create" or "Save changes"

---

## Status Badges

Add CI status badges to your README.md:

```markdown
![CI](https://github.com/ht2-io/rmotly/actions/workflows/ci.yml/badge.svg)
```

This displays the current status of the CI workflow.

### Additional Badges

```markdown
[![codecov](https://codecov.io/gh/ht2-io/rmotly/branch/main/graph/badge.svg)](https://codecov.io/gh/ht2-io/rmotly)
```

For code coverage (requires Codecov integration).

---

## Running Workflows Locally

### Prerequisites

Install the required tools:
- Flutter SDK 3.27.4+
- Dart SDK 3.6.2+
- Docker (for running PostgreSQL and Redis)

### Run Flutter App Tests Locally

```bash
cd rmotly_app
flutter pub get
flutter analyze
flutter test --coverage
```

### Run Serverpod Server Tests Locally

```bash
# Start PostgreSQL and Redis with Docker
docker run -d --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 postgres:17
docker run -d --name redis -p 6379:6379 redis:8

# Run tests
cd rmotly_server
dart pub get
dart analyze
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=postgres
export POSTGRES_DB=rmotly_test
export REDIS_HOST=localhost
export REDIS_PORT=6379
dart test

# Cleanup
docker stop postgres redis
docker rm postgres redis
```

### Build Locally

```bash
# Build Flutter app
cd rmotly_app
flutter build apk --release

# Compile Serverpod server
cd rmotly_server
dart compile kernel bin/main.dart
```

---

## Troubleshooting

### Common Issues

#### 1. Flutter analyze fails

**Problem:** Code analysis errors prevent the workflow from passing.

**Solution:**
- Run `flutter analyze` locally
- Fix all analysis warnings and errors
- Commit and push changes

#### 2. Tests fail in CI but pass locally

**Problem:** Tests behave differently in CI environment.

**Solution:**
- Check for hardcoded paths or environment-specific dependencies
- Ensure tests don't rely on external services
- Use mocks for external dependencies
- Review test logs in GitHub Actions

#### 3. Database connection errors in test-server

**Problem:** Server tests fail to connect to PostgreSQL or Redis.

**Solution:**
- Verify service health checks are passing
- Check environment variables are correctly set
- Ensure connection strings use `localhost`

#### 4. Build artifacts not found

**Problem:** Cannot download build artifacts after workflow completes.

**Solution:**
- Artifacts are only retained for 7 days
- Check the workflow run page for artifact links
- Verify the build job completed successfully

---

## Best Practices

### For Developers

1. **Run tests locally** before pushing to avoid CI failures
2. **Keep commits small** and focused to make CI runs faster
3. **Fix failing tests immediately** - don't let the main branch stay red
4. **Monitor CI results** on pull requests
5. **Update workflows** when adding new tools or dependencies

### For Maintainers

1. **Review CI logs** for recurring issues
2. **Keep actions up to date** (checkout, setup-dart, etc.)
3. **Monitor workflow run times** and optimize as needed
4. **Set up notifications** for CI failures on main branch
5. **Document required secrets** and keep them secure

---

## Future Enhancements

Potential improvements to the CI/CD pipeline:

- [ ] Add code quality checks (complexity, duplication)
- [ ] Implement automated security scanning
- [ ] Add performance testing
- [ ] Set up automated release notes generation
- [ ] Add automated version bumping
- [ ] Implement blue-green deployments
- [ ] Add automated rollback on deployment failure
- [ ] Set up staging environment for pre-production testing

---

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Serverpod Deployment Guide](https://docs.serverpod.dev/deployment)
- [Docker Documentation](https://docs.docker.com/)
- [Rmotly Deployment Guide](DEPLOYMENT.md) - Complete deployment documentation for all environments
