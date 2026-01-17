# Rmotly Custom Agents

This file provides an overview of all custom agents available in the Rmotly repository. Custom agents are specialized AI assistants configured with specific expertise, tools, and constraints to help with particular types of tasks.

## Available Agents

### 1. Flutter Development Agent (`flutter-dev`)

**Purpose:** Specialized agent for Flutter app development following Clean Architecture and Riverpod patterns.

**Use for:**
- Creating new app features and UI components
- Implementing state management with Riverpod
- Writing Flutter widget tests
- Refactoring Flutter code
- Debugging Flutter-specific issues

**Scope:** `rmotly_app/` directory

**Key Expertise:**
- Clean Architecture patterns (data, domain, presentation layers)
- Riverpod state management
- Flutter Material 3 design
- TDD with Mocktail
- Widget, unit, and integration testing

**Configuration:** `.github/agents/flutter-dev.agent.md`

---

### 2. Serverpod Development Agent (`serverpod-dev`)

**Purpose:** Specialized agent for Serverpod API development including endpoints, services, and database models.

**Use for:**
- Creating and modifying Serverpod models (YAML)
- Implementing API endpoints
- Writing service layer business logic
- Database schema design and migrations
- Server-side testing

**Scope:** `rmotly_server/` directory

**Key Expertise:**
- Serverpod framework and conventions
- YAML model definitions
- PostgreSQL database design
- API endpoint implementation
- Async Dart programming
- Error handling patterns

**Configuration:** `.github/agents/serverpod-dev.agent.md`

---

### 3. Documentation Specialist Agent (`docs-specialist`)

**Purpose:** Specialized agent for creating and improving documentation files including README, API docs, and project documentation.

**Use for:**
- Writing new documentation
- Updating existing docs
- Creating API documentation
- Writing guides and tutorials
- Maintaining consistency across documentation

**Scope:** Documentation files (`.md` files in `docs/`, root-level docs)

**Key Expertise:**
- Technical writing best practices
- Markdown formatting
- Documentation structure
- API documentation
- Code examples in documentation

**Configuration:** `.github/agents/docs-specialist.agent.md`

---

## How to Use Custom Agents

### In GitHub Copilot Chat

When working on a task, mention the agent you want to use:

```
@flutter-dev: Create a new button widget for the dashboard
@serverpod-dev: Add a new endpoint for fetching user notifications
@docs-specialist: Update the API documentation with the new endpoints
```

### When to Use Which Agent

| Task Type | Recommended Agent | Why |
|-----------|------------------|-----|
| New Flutter feature | `flutter-dev` | Knows Clean Architecture patterns and Riverpod |
| UI components | `flutter-dev` | Expert in Material 3 design and Flutter widgets |
| API endpoints | `serverpod-dev` | Understands Serverpod conventions and patterns |
| Database models | `serverpod-dev` | Knows YAML model syntax and migration process |
| Writing docs | `docs-specialist` | Focused on clarity and consistency |
| Code explanations | `docs-specialist` | Skilled at technical writing |

### Agent Selection Guidelines

1. **Use the most specific agent** for your task
2. **Combine agents** for multi-faceted tasks (e.g., use `serverpod-dev` for the API and `docs-specialist` for documentation)
3. **Provide context** when invoking agents (mention relevant files, requirements)
4. **Follow agent recommendations** as they're tuned to project conventions

## Agent Capabilities and Boundaries

### What Agents Can Do

- Read and analyze code
- Search the codebase
- Edit files within their scope
- Run commands (flutter-dev and serverpod-dev only)
- Follow project conventions automatically
- Apply best practices specific to their domain

### What Agents Cannot Do

- Work outside their defined scope
- Modify files in other project areas
- Make architectural decisions that affect multiple areas
- Bypass validation and testing requirements
- Override project security guidelines

## Skills Available to Agents

Agents have access to reusable skills defined in `.github/skills/`:

### `flutter-testing`
- Testing patterns and best practices
- Commands for running tests
- Coverage report generation

### `serverpod-generate`
- Code generation workflow
- Migration creation and application
- Model definition syntax

## Agent Configuration

All agent configurations are stored in `.github/agents/` with the `.agent.md` extension. Each agent configuration includes:

- **Name**: Unique identifier for the agent
- **Description**: What the agent does
- **Tools**: Available tools the agent can use
- **Model**: Preferred AI model(s)
- **Expertise**: Detailed knowledge and patterns
- **Constraints**: What the agent should not do

## Best Practices for Working with Agents

1. **Be Specific**: Clearly describe what you want the agent to do
2. **Provide Context**: Include relevant file paths, requirements, and constraints
3. **One Task at a Time**: Break complex work into smaller tasks for each agent
4. **Review Changes**: Always review agent-generated code before committing
5. **Iterate**: Use follow-up questions to refine the agent's output
6. **Respect Boundaries**: Don't ask agents to work outside their expertise area

## Contributing New Agents

To add a new specialized agent:

1. Create a new file in `.github/agents/` with `.agent.md` extension
2. Include proper YAML frontmatter with `name`, `description`, `tools`, and `model`
3. Document the agent's expertise, scope, and constraints
4. Update this `AGENTS.md` file with the new agent
5. Add the agent to the Custom Agents table in `.github/copilot-instructions.md`

## See Also

- [Copilot Instructions](.github/copilot-instructions.md) - Main Copilot configuration
- [Flutter App Instructions](.github/instructions/flutter-app.instructions.md) - Flutter-specific guidelines
- [Serverpod Instructions](.github/instructions/serverpod-models.instructions.md) - Serverpod-specific guidelines
- [Project Conventions](.claude/CONVENTIONS.md) - Detailed coding standards
