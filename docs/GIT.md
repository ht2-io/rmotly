# Git & GitHub Best Practices

This document defines Git and GitHub conventions for the Remotly project.

## Table of Contents

- [Branching Strategy](#branching-strategy)
- [Commit Conventions](#commit-conventions)
- [Pull Request Workflow](#pull-request-workflow)
- [Code Review Guidelines](#code-review-guidelines)
- [Branch Protection Rules](#branch-protection-rules)
- [Git Commands Reference](#git-commands-reference)

---

## Branching Strategy

### Trunk-Based Development

We use **Trunk-Based Development** with short-lived feature branches. This approach:
- Reduces merge conflicts
- Encourages continuous integration
- Keeps the main branch always deployable

### Branch Naming Convention

```
<type>/<short-description>
```

**Types:**
| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat/user-authentication` |
| `fix` | Bug fix | `fix/login-validation` |
| `refactor` | Code refactoring | `refactor/control-service` |
| `docs` | Documentation | `docs/api-endpoints` |
| `test` | Adding tests | `test/action-executor` |
| `chore` | Maintenance tasks | `chore/update-dependencies` |

**Rules:**
- Use lowercase letters and hyphens only
- Keep descriptions short (2-4 words)
- Be descriptive but concise

### Branch Workflow

```
main (protected)
  │
  ├── feat/dashboard-controls
  │     └── (merged back to main)
  │
  ├── fix/notification-display
  │     └── (merged back to main)
  │
  └── feat/openapi-import
        └── (merged back to main)
```

### Branch Lifecycle

1. **Create** branch from `main`
2. **Develop** with small, focused commits
3. **Push** regularly to remote
4. **Open PR** when ready for review
5. **Merge** after approval (squash preferred)
6. **Delete** branch after merge

---

## Commit Conventions

### Conventional Commits

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Commit Message Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description | Version Bump |
|------|-------------|--------------|
| `feat` | New feature | Minor |
| `fix` | Bug fix | Patch |
| `docs` | Documentation only | None |
| `style` | Code style (formatting, etc.) | None |
| `refactor` | Code change that neither fixes nor adds | None |
| `perf` | Performance improvement | Patch |
| `test` | Adding or correcting tests | None |
| `build` | Build system or dependencies | None |
| `ci` | CI configuration | None |
| `chore` | Other changes (tooling, etc.) | None |
| `revert` | Revert a previous commit | Varies |

### Scopes

Project-specific scopes:

| Scope | Description |
|-------|-------------|
| `api` | Serverpod API changes |
| `app` | Flutter app changes |
| `client` | Generated client changes |
| `models` | Data model changes |
| `auth` | Authentication related |
| `controls` | Dashboard controls |
| `actions` | Action execution |
| `notifications` | Notification system |
| `openapi` | OpenAPI integration |
| `deps` | Dependencies |
| `config` | Configuration files |

### Subject Line Rules

- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize first letter
- No period at the end
- Maximum 50 characters

### Examples

**Good commits:**
```
feat(controls): add slider control widget

fix(api): handle null payload in event endpoint

docs(readme): update installation instructions

refactor(actions): extract template parser to separate service

test(auth): add unit tests for login validation

chore(deps): update serverpod to 2.9.2
```

**Bad commits:**
```
Fixed bug                          # No type, not descriptive
feat: Added new feature.           # Capitalized, has period, vague
update stuff                       # No type, not descriptive
WIP                                # Work in progress shouldn't be committed
```

### Breaking Changes

Indicate breaking changes with `!` after type/scope:

```
feat(api)!: change event endpoint response format

BREAKING CHANGE: The event endpoint now returns a different JSON structure.
Old format: { "status": "ok" }
New format: { "success": true, "eventId": "..." }
```

### Commit Body

Use the body for:
- Explaining **why** (not what) the change was made
- Providing context that isn't obvious from the code
- Referencing related issues or discussions

```
fix(notifications): prevent duplicate FCM token registration

The previous implementation could register the same FCM token multiple
times if the app was opened quickly after being backgrounded. This adds
a check to skip registration if the token hasn't changed.

Fixes #42
```

---

## Pull Request Workflow

### Creating a Pull Request

1. **Ensure tests pass locally**
   ```bash
   flutter test
   dart test
   ```

2. **Push your branch**
   ```bash
   git push -u origin feat/your-feature
   ```

3. **Open PR via GitHub CLI**
   ```bash
   gh pr create --title "feat(scope): description" --body "..."
   ```

### PR Title Format

Follow the same format as commit messages:
```
<type>(<scope>): <subject>
```

### PR Description Template

```markdown
## Summary

Brief description of what this PR does.

## Changes

- List of specific changes
- Another change
- etc.

## Testing

- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)

[Add screenshots for UI changes]

## Related Issues

Fixes #123
Related to #456
```

### PR Size Guidelines

| Size | Lines Changed | Review Time |
|------|---------------|-------------|
| Small | < 200 | Quick review |
| Medium | 200-400 | Standard review |
| Large | 400-800 | Extended review |
| X-Large | > 800 | Consider splitting |

**Best practice:** Keep PRs small and focused. Multiple small PRs are better than one large PR.

### Draft Pull Requests

Use draft PRs for:
- Work in progress that needs early feedback
- Changes that aren't ready for final review
- Exploratory changes

```bash
gh pr create --draft --title "WIP: feat(scope): description"
```

---

## Code Review Guidelines

### For Authors

1. **Self-review first** - Review your own changes before requesting review
2. **Provide context** - Explain non-obvious decisions in comments
3. **Respond promptly** - Address feedback within 24 hours
4. **Be open** - Consider all feedback, even if you disagree

### For Reviewers

1. **Be timely** - Review within 24 hours when possible
2. **Be constructive** - Suggest improvements, don't just criticize
3. **Be specific** - Point to exact lines, provide examples
4. **Prioritize** - Distinguish blocking issues from suggestions

### Comment Prefixes

Use prefixes to indicate severity:

| Prefix | Meaning | Action Required |
|--------|---------|-----------------|
| `blocking:` | Must be fixed before merge | Yes |
| `suggestion:` | Nice to have improvement | Optional |
| `question:` | Clarification needed | Response needed |
| `nit:` | Minor style issue | Optional |
| `praise:` | Good work callout | None |

**Examples:**
```
blocking: This will cause a null pointer exception when payload is empty.

suggestion: Consider using a switch expression here for better readability.

question: Why did we choose to cache this instead of fetching fresh data?

nit: Missing trailing comma after the last parameter.

praise: Nice use of the builder pattern here!
```

### Review Checklist

- [ ] Code follows project conventions
- [ ] Tests are included and passing
- [ ] Documentation is updated if needed
- [ ] No security vulnerabilities introduced
- [ ] No performance regressions
- [ ] Error handling is appropriate
- [ ] No unnecessary code duplication

---

## Branch Protection Rules

### Main Branch Protection

Configure these rules for the `main` branch:

1. **Require pull request before merging**
   - Require at least 1 approval
   - Dismiss stale reviews when new commits are pushed

2. **Require status checks to pass**
   - Required checks: `test`, `analyze`, `build`
   - Require branches to be up to date

3. **Require conversation resolution**
   - All review comments must be resolved

4. **Do not allow force pushes**

5. **Do not allow deletions**

### Setting Up via GitHub CLI

```bash
gh api repos/{owner}/{repo}/branches/main/protection \
  -X PUT \
  -H "Accept: application/vnd.github+json" \
  -f required_status_checks='{"strict":true,"contexts":["test","analyze"]}' \
  -f enforce_admins=true \
  -f required_pull_request_reviews='{"required_approving_review_count":1}'
```

---

## Git Commands Reference

### Daily Workflow

```bash
# Start new feature
git checkout main
git pull origin main
git checkout -b feat/new-feature

# Make changes and commit
git add .
git commit -m "feat(scope): add new feature"

# Push and create PR
git push -u origin feat/new-feature
gh pr create

# After PR is merged
git checkout main
git pull origin main
git branch -d feat/new-feature
```

### Keeping Branch Updated

```bash
# Rebase onto latest main (preferred)
git fetch origin
git rebase origin/main

# Or merge main into feature branch
git fetch origin
git merge origin/main
```

### Undoing Changes

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Revert a specific commit (creates new commit)
git revert <commit-hash>

# Discard all local changes
git checkout -- .
```

### Cleaning Up

```bash
# Delete local branches that are gone on remote
git fetch --prune
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d

# Delete specific local branch
git branch -d feat/merged-feature

# Delete remote branch
git push origin --delete feat/old-branch
```

### Stashing

```bash
# Stash current changes
git stash push -m "description of changes"

# List stashes
git stash list

# Apply most recent stash
git stash pop

# Apply specific stash
git stash apply stash@{2}

# Drop a stash
git stash drop stash@{0}
```

### Viewing History

```bash
# View commit history (graph)
git log --oneline --graph --all

# View file history
git log --follow -p -- path/to/file

# View who changed each line
git blame path/to/file

# Search commit messages
git log --grep="keyword"

# Search code changes
git log -S "function_name" --oneline
```

### Interactive Rebase

```bash
# Squash last 3 commits
git rebase -i HEAD~3

# In the editor:
# pick abc1234 First commit
# squash def5678 Second commit
# squash ghi9012 Third commit
```

---

## GitHub CLI Reference

### Pull Requests

```bash
# List open PRs
gh pr list

# View PR details
gh pr view <number>

# Check out PR locally
gh pr checkout <number>

# Create PR
gh pr create --title "title" --body "description"

# Merge PR
gh pr merge <number> --squash

# Close PR
gh pr close <number>
```

### Issues

```bash
# Create issue
gh issue create --title "title" --body "description"

# List issues
gh issue list

# Close issue
gh issue close <number>
```

### Repository

```bash
# Clone repository
gh repo clone owner/repo

# View repository
gh repo view

# Create repository
gh repo create name --public
```

---

## CI/CD Integration

### GitHub Actions Workflow

The Remotly project uses GitHub Actions for continuous integration. The workflow is defined in `.github/workflows/ci.yml` and runs on every push to `main` and on all pull requests.

#### Workflow Jobs

The CI workflow includes the following jobs:

1. **analyze-app** - Analyzes Flutter app code with `flutter analyze`
2. **analyze-server** - Analyzes Serverpod server code with `dart analyze`
3. **test-app** - Runs Flutter app tests with coverage reporting
4. **test-server** - Runs Serverpod server tests with PostgreSQL and Redis services
5. **build-app** - Builds release APK (runs after app analysis and tests pass)
6. **build-server** - Compiles Serverpod server (runs after server analysis and tests pass)

#### Example Configuration

See `.github/workflows/ci.yml` for the complete workflow configuration.

#### Additional Workflows

- **deployment-aws.yml** - Deploys to AWS on specific branches
- **deployment-gcp.yml** - Deploys to Google Cloud Platform on specific branches

---

## Quick Reference Card

### Branch Names
```
feat/description    # New feature
fix/description     # Bug fix
refactor/description # Refactoring
docs/description    # Documentation
test/description    # Tests
chore/description   # Maintenance
```

### Commit Messages
```
feat(scope): add feature       # New feature
fix(scope): fix bug            # Bug fix
docs(scope): update docs       # Documentation
refactor(scope): clean code    # Refactoring
test(scope): add tests         # Tests
chore(scope): update deps      # Maintenance
```

### Review Comments
```
blocking: Must fix before merge
suggestion: Optional improvement
question: Need clarification
nit: Minor style issue
praise: Good work!
```
