---
name: test
description: Generate and run OPA policy test suites. Creates _test.rego files with comprehensive coverage. Say "test opa", "generate rego tests", "opa test", or "add test coverage".
argument-hint: "[path] [--generate-only] [--run-only]"
arguments:
  - name: path
    description: "Path to policy files to test (defaults to all .rego files)"
    required: false
  - name: generate-only
    description: "Only generate test files, do not run them"
    required: false
  - name: run-only
    description: "Only run existing tests, do not generate new ones"
    required: false
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Agent
---

# /opa:test

Generate and/or run comprehensive test suites for OPA/Rego policies.

## Workflow

### Step 1: Discover Policies

Find all `.rego` files in the target path (excluding `_test.rego`):
- List each policy file and its package name
- Check for existing `_test.rego` files
- Identify policies with missing or incomplete tests

### Step 2: Analyze Coverage Gaps (unless --run-only)

For each policy file without complete tests:
- Read the policy and identify all deny/violation/warn/allow rules
- Check if corresponding `_test.rego` exists
- If tests exist, check which rules lack coverage
- Check for spec files in `docs/specs/rego/` for test case definitions

### Step 3: Generate Tests (unless --run-only)

Use the `test-generator` agent for each policy needing tests:
- Generate `_test.rego` matching the policy package
- Include positive, negative, and edge case tests
- Use spec test cases if a spec file exists
- Create fixtures matching the platform's input schema

Present generated test files for user review before writing.

### Step 4: Run Tests (unless --generate-only)

```bash
# Run all tests with verbose output and coverage
opa test <path> -v --coverage

# If specific test regex needed
opa test <path> -v --run "<pattern>"
```

### Step 5: Report

```
## Test Report

### Generated Tests
- [N] new test files created
- [N] test functions generated
  - [N] positive tests
  - [N] negative tests
  - [N] edge case tests

### Test Results
- Passed: [N]
- Failed: [N]
- Skipped: [N]

### Coverage
| File | Coverage |
|------|----------|
| policy1.rego | 85% |
| policy2.rego | 72% |

### Overall Coverage: [X]%

### Uncovered Rules
[List of rules still lacking test coverage]
```
