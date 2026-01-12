# Verification Criteria Generators

Auto-generate verification criteria based on task type detection.

## Task Type Detection

Analyze task description to determine type:

### API Endpoint
**Indicators:**
- Contains: "endpoint", "route", "API", "REST", "GraphQL"
- Contains: "GET", "POST", "PUT", "DELETE", "PATCH"
- File paths include: `/api/`, `/routes/`, `controller`

**Generated Verification:**
```yaml
type: api
method: <inferred from task>
endpoint: <inferred from task>
expected_status: 200
expected_body: "Response matches expected schema"
```

### UI Component
**Indicators:**
- Contains: "component", "button", "form", "modal", "page"
- Contains: "UI", "UX", "frontend", "React", "Vue", "Angular"
- File paths include: `/components/`, `/pages/`, `.tsx`, `.jsx`

**Generated Verification:**
```yaml
type: browser
steps:
  - "Navigate to <page containing component>"
  - "Interact with <component>"
  - "Verify expected behavior"
success_criteria: "Component renders correctly, no console errors"
```

### CLI Command
**Indicators:**
- Contains: "command", "CLI", "script", "bin"
- Contains: "terminal", "shell", "bash"
- File paths include: `/bin/`, `/scripts/`, `cli.`

**Generated Verification:**
```yaml
type: command
command: "<command> --help"
expected: "Shows help output without errors"
```

### Configuration
**Indicators:**
- Contains: "config", "environment", "settings", "env"
- Contains: "feature flag", "toggle"
- File paths include: `.env`, `config.`, `.yaml`, `.json`

**Generated Verification:**
```yaml
type: command
command: "<validation command or app startup>"
expected: "Application starts with new config, no errors"
```

### Database Migration
**Indicators:**
- Contains: "migration", "schema", "database", "table", "column"
- Contains: "SQL", "Prisma", "TypeORM", "Sequelize"
- File paths include: `/migrations/`, `.sql`, `schema.`

**Generated Verification:**
```yaml
type: command
command: "<migration status command>"
expected: "Migration applied successfully"
```

### Documentation
**Indicators:**
- Contains: "docs", "documentation", "README", "guide"
- Contains: "comment", "JSDoc", "docstring"
- File paths include: `.md`, `/docs/`

**Generated Verification:**
```yaml
type: manual
checklist:
  - "Documentation is accurate and complete"
  - "Examples are working"
  - "Links are not broken"
reviewer: "Team member or tech writer"
```

### Refactoring
**Indicators:**
- Contains: "refactor", "rename", "extract", "move", "reorganize"
- Contains: "clean up", "simplify", "consolidate"

**Generated Verification:**
```yaml
type: command
command: "<test suite command>"
expected: "All existing tests pass (no regression)"
```

### Bug Fix
**Indicators:**
- Contains: "fix", "bug", "issue", "broken", "error"
- Contains: "crash", "failing", "incorrect"

**Generated Verification:**
```yaml
type: e2e
command: "<reproduce the bug scenario>"
expected: "Bug no longer occurs, original behavior restored"
```

## Generation Algorithm

```
1. Parse task description for indicators
2. Match against task types (first match wins, ordered by specificity)
3. Extract context:
   - Endpoints from route patterns
   - Component names from file paths
   - Commands from task description
4. Fill verification template with extracted context
5. Add fallback verification if primary type unclear
```

## Fallback Rules

If no clear task type detected:

1. **Has test file mentioned?** → `command` with test runner
2. **Has file path?** → Infer type from extension/path
3. **Generic change?** → `manual` with basic checklist

## Example Generation

**Task:** "Add POST /api/users endpoint for user creation"

**Detection:**
- "POST" → API method
- "/api/users" → API endpoint
- "endpoint" → API task type

**Generated:**
```yaml
type: api
method: POST
endpoint: "/api/users"
body: '{"name": "Test User", "email": "test@example.com"}'
expected_status: 201
expected_body: "Returns created user with id"
```

## Integration

Called by github-planning skill when generating Issue body:

```markdown
## Verification

| Step | Type | Details | Expected |
|------|------|---------|----------|
| 1 | api | POST /api/users | 201, user object returned |
| 2 | command | npm test -- users | All user tests pass |
```
