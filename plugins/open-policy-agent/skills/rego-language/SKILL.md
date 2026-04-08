---
name: rego-language
description: This skill should be used when the user asks to "write rego", "rego syntax", "rego policy", "rego rule", "opa policy", mentions `.rego` files, asks about Rego built-in functions, comprehensions, or partial rules. Provides Rego v1 language reference and idiomatic patterns.
---

# Rego Language

Rego v1 language reference for writing OPA policies. Covers syntax, data types, rules, comprehensions, built-in functions, and idiomatic patterns.

**Rego Version:** v1 (released December 2024). All examples use v1 syntax with mandatory `if` and `contains` keywords.

**CRITICAL: DO NOT write v0 syntax.** Most Rego examples on the internet, in blog posts, and in training data use pre-v1 syntax. The following patterns are DEPRECATED and MUST NOT be used:
- `deny[msg] { ... }` -- WRONG. Use `deny contains msg if { ... }`
- `allow { ... }` -- WRONG. Use `allow if { ... }`
- `default allow = false` -- WRONG. Use `default allow := false`
- `arr[_]` or `arr[i]` -- WRONG. Use `some x in arr`
- `import future.keywords.if` -- WRONG. Keywords are built-in in v1.

If reviewing existing code that uses these patterns, flag them for migration.

## Modes of Operation

| Mode | Trigger | Action |
|------|---------|--------|
| **Write** | Creating new `.rego` files | Apply v1 syntax, idiomatic patterns |
| **Review** | Reviewing existing Rego | Check for v0 patterns, anti-patterns |
| **Reference** | "How do I X in Rego?" | Provide idiomatic solution |

---

## Package and Imports

Every Rego file starts with a package declaration:

```rego
package authz.kubernetes.pod_security

import rego.v1  # Enables v1 syntax (required for OPA < 1.0, optional for OPA >= 1.0)
import data.lib.helpers
import input.request
```

| Rule | Correct | Wrong |
|------|---------|-------|
| Package naming | `package authz.kubernetes` | `package authz-kubernetes` |
| Separator | Dots for hierarchy | Hyphens, slashes |
| Convention | Snake_case segments | CamelCase |

---

## Rules

### Complete Rules (single value)

```rego
# Boolean deny rule
deny if {
    input.request.kind == "Pod"
    not input.request.object.spec.securityContext.runAsNonRoot
}

# Value assignment
default allow := false

allow if {
    input.user.role == "admin"
}

# With else chain
authorize := "allow" if {
    input.user.role == "admin"
} else := "deny"
```

### Partial Rules (set/object generators)

```rego
# Set of violation messages (use `contains`)
violation contains msg if {
    some container in input.request.object.spec.containers
    container.securityContext.privileged
    msg := sprintf("container '%s' must not be privileged", [container.name])
}

# Object generator
labels[key] := value if {
    some key, value in input.request.object.metadata.labels
}
```

### Critical v1 Syntax Rules

| Pattern | v1 (Correct) | v0 (Deprecated) |
|---------|-------------|-----------------|
| Complete rule | `allow if { ... }` | `allow { ... }` |
| Partial set | `deny contains msg if { ... }` | `deny[msg] { ... }` |
| Default | `default allow := false` | `default allow = false` |
| Iteration | `some x in collection` | `collection[x]` |

---

## Data Types and Iteration

### Scalar Types
Strings, numbers, booleans, null.

### Composite Types

```rego
# Array (ordered, duplicates allowed)
arr := [1, 2, 3]

# Object (key-value)
obj := {"name": "nginx", "port": 80}

# Set (unordered, unique)
s := {1, 2, 3}
```

### Iteration with `some` and `in`

```rego
# Iterate array elements
some container in input.spec.containers

# Iterate object keys and values
some key, value in input.metadata.labels

# Iterate with index
some i, container in input.spec.containers

# Check membership
"admin" in input.user.roles
```

### Comprehensions

```rego
# Array comprehension
names := [c.name | some c in input.spec.containers]

# Set comprehension
ports := {c.containerPort | some c in input.spec.containers; some p in c.ports; p.containerPort}

# Object comprehension
label_map := {k: v | some k, v in input.metadata.labels; startswith(k, "app/")}
```

---

## Negation and Every

```rego
# Negation
deny if {
    not input.spec.securityContext.runAsNonRoot
}

# Universal quantification
deny if {
    every container in input.spec.containers {
        not container.resources.limits.memory
    }
}
```

---

## Functions

```rego
# User-defined function
has_label(obj, key) if {
    some k, _ in obj.metadata.labels
    k == key
}

# With default return
container_image(c) := image if {
    image := concat(":", [c.image, c.tag])
} else := c.image
```

---

## Metadata Annotations

```rego
# METADATA
# title: Deny privileged containers
# description: Containers must not run in privileged mode
# custom:
#   severity: high
#   benchmark: CIS-K8s-5.2.1
deny contains msg if {
    some c in input.spec.containers
    c.securityContext.privileged
    msg := sprintf("privileged container: %s", [c.name])
}
```

---

## Common Built-in Functions

| Category | Functions |
|----------|-----------|
| **Comparison** | `==`, `!=`, `<`, `>`, `<=`, `>=` |
| **Strings** | `concat`, `contains`, `startswith`, `endswith`, `sprintf`, `split`, `trim`, `lower`, `upper`, `replace`, `regex.match` |
| **Numbers** | `count`, `sum`, `product`, `max`, `min`, `abs`, `round`, `ceil`, `floor` |
| **Aggregates** | `count`, `sum`, `min`, `max`, `sort` |
| **Objects** | `object.get`, `object.keys`, `object.remove`, `object.union`, `object.filter` |
| **Sets** | `intersection`, `union` |
| **Types** | `is_string`, `is_number`, `is_boolean`, `is_null`, `is_array`, `is_object`, `is_set`, `type_name` |
| **Encoding** | `json.marshal`, `json.unmarshal`, `base64.encode`, `base64.decode`, `yaml.marshal`, `yaml.unmarshal` |
| **JWT** | `io.jwt.decode`, `io.jwt.verify_hs256`, `io.jwt.verify_rs256` |
| **HTTP** | `http.send` |
| **Crypto** | `crypto.sha256`, `crypto.hmac.sha256` |
| **Time** | `time.now_ns`, `time.parse_rfc3339_ns`, `time.date` |
| **Regex** | `regex.match`, `regex.find_all_string_submatch_n`, `regex.split` |

---

## Idiomatic Patterns

### Deny-by-default with explicit allow

```rego
package authz

import rego.v1

default allow := false

allow if {
    input.user.role == "admin"
}

allow if {
    input.user.role == "viewer"
    input.method == "GET"
}
```

### Collecting violations

```rego
package kubernetes.admission

import rego.v1

violation contains msg if {
    some c in input.review.object.spec.containers
    not c.resources.limits.cpu
    msg := sprintf("container '%s' missing CPU limit", [c.name])
}
```

### Helper library pattern

```rego
package lib.kubernetes

import rego.v1

pods contains pod if {
    some pod in data.kubernetes.pods[_]
}

containers contains container if {
    some pod in pods
    some container in pod.spec.containers
}
```

---

## Safe Navigation for Optional Fields

Rego does NOT raise errors on missing fields -- expressions with undefined paths silently evaluate to undefined, causing rules to silently not fire. This is a critical bug source: a deny rule checking `c.securityContext.privileged` will NOT fire when `securityContext` is missing entirely, allowing the dangerous case through.

**Always use `object.get` for fields that may not exist:**

```rego
# WRONG: silently skips containers without securityContext
deny contains msg if {
    some c in input.spec.containers
    c.securityContext.privileged  # undefined if securityContext missing -> rule doesn't fire
    msg := sprintf("privileged: %s", [c.name])
}

# CORRECT: handles missing securityContext safely
deny contains msg if {
    some c in input.spec.containers
    sc := object.get(c, "securityContext", {})
    object.get(sc, "privileged", false) == true
    msg := sprintf("privileged: %s", [c.name])
}
```

Apply this pattern whenever accessing fields 2+ levels deep in input objects that may have optional fields (securityContext, resources, capabilities, annotations).

---

## Anti-Patterns to Avoid

| Anti-Pattern | Fix |
|-------------|-----|
| Using `=` for assignment | Use `:=` for local assignment |
| Implicit iteration (`arr[_]`) | Use `some x in arr` |
| Missing `if` keyword | Always use `if` in v1 |
| `deny[msg]` syntax | Use `deny contains msg if` |
| Deeply nested rules | Extract helper functions |
| `http.send` in hot paths | Cache data externally, use bundles |

---

## Additional Resources

### Reference Files

For detailed built-in function signatures and advanced patterns:
- **`references/built-ins.md`** - Complete built-in function reference with examples
- **`references/patterns.md`** - Advanced patterns: partial evaluation, bundle structure, schema validation
