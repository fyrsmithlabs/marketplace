---
name: validate
description: Run OPA policy validation pipeline (syntax, lint, test, coverage, benchmark check) on Rego files. Say "validate rego", "check my policies", "opa validate", or "run policy checks".
argument-hint: "[path] [--fix]"
arguments:
  - name: path
    description: "Path to validate (defaults to all .rego files in current directory)"
    required: false
  - name: fix
    description: "Auto-fix formatting issues with opa fmt -w"
    required: false
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
  - Agent
---

# /opa:validate

Run the full validation pipeline on OPA/Rego policy files.

## Workflow

### Step 1: Discover Files

Find all `.rego` files in the target path:
- If path argument provided, use it
- Otherwise, search current directory recursively for `**/*.rego`
- Separate policy files from `_test.rego` files
- Report file counts

### Step 2: Syntax Check

```bash
opa check --strict <path>
```

If `opa` is not installed, inform the user and provide installation instructions:
```bash
# macOS
brew install opa

# Go install
go install github.com/open-policy-agent/opa@latest
```

### Step 3: Format Check

```bash
# List files needing formatting
opa fmt -l <path>
```

If `--fix` flag is set:
```bash
opa fmt -w <path>
```

### Step 4: Lint

```bash
regal lint <path>
```

If `regal` is not installed, note it and skip:
```bash
# macOS
brew install styrainc/packages/regal

# Go install
go install github.com/styrainc/regal@latest
```

### Step 5: Run Tests

```bash
opa test <path> -v --coverage
```

Report:
- Pass/fail/skip counts
- Per-file coverage percentages
- Files with zero test coverage

### Step 6: Benchmark Alignment Check

Read policy files and check for `# METADATA` annotations:
- Count rules with benchmark annotations
- Count rules missing annotations (on deny/violation/warn rules)
- If spec files exist in `docs/specs/rego/`, cross-reference

### Step 7: Rego v1 Compliance

Grep for v0 patterns:
- Rules without `if` keyword
- `deny[msg]` instead of `deny contains msg if`
- `default x = val` instead of `default x := val`
- `import future.keywords.*`
- `import rego.v1` (unnecessary on OPA 1.0+)

### Step 8: Report

Use the `policy-validator` agent output format:
```
## Policy Validation Report

### Files: [N] policy, [N] test
### Syntax: [PASS/FAIL]
### Format: [N] files need formatting
### Lint: [N] errors, [N] warnings
### Tests: [N] pass, [N] fail, [N] skip — Coverage: [X]%
### Benchmarks: [N]/[N] rules annotated
### v1 Compliance: [PASS/N issues]

### Overall: [PASS / WARN / FAIL]
```
