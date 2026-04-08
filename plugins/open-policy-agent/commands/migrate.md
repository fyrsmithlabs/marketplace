---
name: migrate
description: Migrate Rego v0 policies to v1 syntax. Say "migrate rego", "opa migrate", "upgrade rego to v1", or "rego v1 migration".
argument-hint: "[path] [--dry-run]"
arguments:
  - name: path
    description: "Path to policy files to migrate (defaults to all .rego files)"
    required: false
  - name: dry-run
    description: "Preview changes without writing files"
    required: false
allowed-tools:
  - Read
  - Edit
  - Bash
  - Glob
  - Grep
---

# /opa:migrate

Migrate Rego policies from v0 to v1 syntax using automated tooling and manual fixes.

## Workflow

### Step 1: Discover Files

Find all `.rego` files in the target path:
- Count total files
- Identify files with v0 patterns (missing `if`, `deny[msg]` syntax, etc.)
- Report scope of migration

### Step 2: Assess v0 Patterns

Grep for v0 patterns across all files:

| Pattern | Regex | Count |
|---------|-------|-------|
| Missing `if` | Rules without `if` keyword | [N] |
| Old partial sets | `\w+\[` without `contains` | [N] |
| Old defaults | `default \w+ =` | [N] |
| Future imports | `import future.keywords` | [N] |
| rego.v1 import | `import rego.v1` | [N] |

Present assessment to user.

### Step 3: Automated Migration

If not `--dry-run`:
```bash
# Run opa fmt with rego-v1 flag
opa fmt --rego-v1 -w <path>
```

If `--dry-run`:
```bash
# Preview changes
opa fmt --rego-v1 -l <path>
```

### Step 4: Manual Fixes

After `opa fmt --rego-v1`, check for remaining issues:

```bash
opa check --strict <path>
```

For any remaining issues, apply manual fixes:
- Implicit boolean rules without bodies
- Complex multi-value rule heads
- Rules that `opa fmt` could not automatically convert

### Step 5: Validate

Run the full validation pipeline:
```bash
# Strict syntax check
opa check --strict <path>

# Run all tests
opa test <path> -v

# Lint
regal lint <path>
```

### Step 6: Report

```
## Migration Report

### Files Processed: [N]

### Automated Fixes (opa fmt --rego-v1)
- [N] files modified
- [N] rules updated with `if` keyword
- [N] partial rules updated with `contains`
- [N] defaults updated to `:=`
- [N] future.keywords imports removed

### Manual Fixes Required
- [list any remaining v0 patterns]

### Validation
- Syntax: [PASS/FAIL]
- Tests: [N] pass, [N] fail
- Lint: [N] issues

### Migration Status: [COMPLETE / NEEDS MANUAL FIXES]
```

### Rollback

If migration causes test failures:
1. Show which tests broke
2. Suggest using `--v0-compatible` flag temporarily
3. Offer to revert changes via `git checkout`
