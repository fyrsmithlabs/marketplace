---
name: rego-v1-migration
description: This skill should be used when the user asks to "migrate rego", "rego v1", "v0 to v1", "upgrade rego", "opa fmt --rego-v1", "rego breaking changes", "rego compatibility", mentions Rego version migration, or encounters v0 syntax errors in OPA 1.0+. Provides Rego v0 to v1 migration patterns and tooling.
---

# Rego v1 Migration

Guide for migrating Rego policies from v0 to v1 syntax. Rego v1 was released with OPA 1.0 (December 2024) and introduces mandatory syntax changes.

## What Changed in v1

| Feature | v0 (Deprecated) | v1 (Required) |
|---------|-----------------|---------------|
| Complete rules | `allow { ... }` | `allow if { ... }` |
| Partial set rules | `deny[msg] { ... }` | `deny contains msg if { ... }` |
| Default assignment | `default allow = false` | `default allow := false` |
| `every` keyword | Requires `import future.keywords.every` | Available without import |
| `in` keyword | Requires `import future.keywords.in` | Available without import |
| `contains` keyword | Requires `import future.keywords.contains` | Available without import |
| `if` keyword | Requires `import future.keywords.if` | Available without import |
| Duplicate imports | Allowed | Error |
| `input` and `data` import | Allowed | Error (`import input` / `import data` prohibited) |

---

## Migration Workflow

### Step 1: Assess Current State

```bash
# Check for v0 patterns across all Rego files
opa check --strict ./policies/

# List files that need migration
opa fmt --rego-v1 -l ./policies/
```

### Step 2: Automated Migration

```bash
# Migrate and write in-place (RECOMMENDED FIRST STEP)
opa fmt --rego-v1 -w ./policies/

# Preview changes without writing
opa fmt --rego-v1 ./policies/policy.rego
```

`opa fmt --rego-v1` handles most transformations automatically:
- Adds `if` to complete rules
- Converts `deny[msg]` to `deny contains msg if`
- Converts `default x = val` to `default x := val`
- Removes `future.keywords` imports
- Removes `import rego.v1`

### Step 3: Manual Fixes

After `opa fmt --rego-v1`, manually address:

1. **Implicit boolean rules without bodies**: `allow` (bare rule) needs explicit assignment
2. **Complex rule heads**: Some multi-value rules may need restructuring
3. **Test files**: Ensure test rules also use `if`
4. **Build scripts**: Update any `--v0-compatible` flags

### Step 4: Validate

```bash
# Strict check (catches remaining v0 patterns)
opa check --strict ./policies/

# Run all tests
opa test ./policies/ -v

# Lint with Regal
regal lint ./policies/
```

---

## Common Migration Patterns

### Complete Rules

```rego
# v0
allow {
    input.user.role == "admin"
}

# v1
allow if {
    input.user.role == "admin"
}
```

### Partial Set Rules

```rego
# v0
deny[msg] {
    some c in input.spec.containers
    c.securityContext.privileged
    msg := sprintf("privileged: %s", [c.name])
}

# v1
deny contains msg if {
    some c in input.spec.containers
    c.securityContext.privileged
    msg := sprintf("privileged: %s", [c.name])
}
```

### Partial Object Rules

```rego
# v0
labels[key] = value {
    some key, value in input.metadata.labels
}

# v1
labels[key] := value if {
    some key, value in input.metadata.labels
}
```

### Default Values

```rego
# v0
default allow = false

# v1
default allow := false
```

### Future Keywords Imports

```rego
# v0
import future.keywords.if
import future.keywords.in
import future.keywords.contains
import future.keywords.every

# v1 (remove all future.keywords imports - keywords are built-in)
# Also remove: import rego.v1
```

### Else Chains

```rego
# v0
authorize = "allow" {
    input.role == "admin"
} else = "deny" {
    true
}

# v1
authorize := "allow" if {
    input.role == "admin"
} else := "deny"
```

---

## Compatibility Mode

For gradual migration, OPA supports running v0 policies with compatibility flags:

```bash
# Run v0 policies on OPA 1.0+
opa eval --v0-compatible -d policy.rego -i input.json "data.authz.allow"

# Test v0 policies
opa test --v0-compatible ./policies/

# Check syntax in v0 mode
opa check --v0-compatible ./policies/
```

**Environment variable:** `OPA_V0_COMPATIBLE=true`

### Per-File Compatibility

Add `import rego.v1` to individual files to opt-in to v1 semantics in a v0 codebase:

```rego
package authz

import rego.v1  # This file uses v1 syntax

allow if {
    input.user.role == "admin"
}
```

---

## Gatekeeper Migration

Gatekeeper ConstraintTemplates embed Rego in YAML. Migration requires updating the embedded Rego:

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels

        # v1 syntax
        violation contains {"msg": msg} if {
            provided := {l | some l, _ in input.review.object.metadata.labels}
            required := {l | some l in input.parameters.labels}
            missing := required - provided
            count(missing) > 0
            msg := sprintf("missing labels: %v", [missing])
        }
```

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `rego_parse_error: rule head must contain if` | v0 rule syntax on v1 OPA | Add `if` keyword |
| `rego_parse_error: rule head must contain contains` | v0 partial set syntax | Use `contains` keyword |
| `rego_compile_error: import shadows ...` | Duplicate import | Remove duplicate |
| `rego_compile_error: import input` | Bare `import input` | Remove (input is implicit) |
| `rego_type_error: ... deprecated` | Using `=` for default | Change to `:=` |

---

## Migration Checklist

- [ ] Run `opa fmt --rego-v1 -w` on all `.rego` files
- [ ] Run `opa check --strict` to find remaining issues
- [ ] Update all test files (`_test.rego`) to v1 syntax
- [ ] Remove all `import future.keywords.*` lines
- [ ] Remove all `import rego.v1` lines
- [ ] Convert `default x = val` to `default x := val`
- [ ] Run full test suite: `opa test . -v`
- [ ] Run Regal lint: `regal lint .`
- [ ] Update Gatekeeper ConstraintTemplates if applicable
- [ ] Remove `--v0-compatible` flags from CI/CD
- [ ] Update documentation and examples
