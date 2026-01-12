# Verification Criteria Types

Define how each task type should be verified.

## Verification Types

### command
Execute a CLI command and check output.

```yaml
type: command
command: "<exact command to run>"
expected: "<expected output or exit code>"
```

**Example:**
```yaml
type: command
command: "npm test -- --testPathPattern=auth"
expected: "All tests pass (exit 0)"
```

### api
Make an HTTP request and verify response.

```yaml
type: api
method: "<GET|POST|PUT|DELETE>"
endpoint: "<url or path>"
body: "<request body if applicable>"
expected_status: <status code>
expected_body: "<response body pattern>"
```

**Example:**
```yaml
type: api
method: POST
endpoint: "/api/auth/login"
body: '{"email": "test@example.com", "password": "test123"}'
expected_status: 200
expected_body: "token field present"
```

### browser
Manual browser verification steps.

```yaml
type: browser
steps:
  - "<step 1>"
  - "<step 2>"
  - "<step 3>"
success_criteria: "<what to look for>"
```

**Example:**
```yaml
type: browser
steps:
  - "Navigate to /login"
  - "Enter test credentials"
  - "Click submit"
success_criteria: "Redirects to /dashboard, no console errors"
```

### e2e
Run end-to-end test suite.

```yaml
type: e2e
command: "<e2e test command>"
test_file: "<specific test file if applicable>"
expected: "<expected outcome>"
```

**Example:**
```yaml
type: e2e
command: "npx playwright test"
test_file: "tests/auth.spec.ts"
expected: "All auth tests pass"
```

### manual
Human verification checklist.

```yaml
type: manual
checklist:
  - "<item 1>"
  - "<item 2>"
  - "<item 3>"
reviewer: "<who should verify>"
```

**Example:**
```yaml
type: manual
checklist:
  - "Verify email template renders correctly"
  - "Check mobile responsiveness"
  - "Confirm accessibility compliance"
reviewer: "Product owner or designer"
```

## Type Selection Guidelines

| Task Type | Primary Verification | Fallback |
|-----------|---------------------|----------|
| API endpoint | `api` | `command` (curl) |
| UI component | `browser` | `e2e` |
| CLI tool | `command` | - |
| Config change | `command` | `manual` |
| Database migration | `command` | `api` |
| Documentation | `manual` | - |
| Refactoring | `command` (tests) | `e2e` |
| Bug fix | `e2e` or original repro | `manual` |
