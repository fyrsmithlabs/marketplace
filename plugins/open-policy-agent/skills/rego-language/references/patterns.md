# Advanced Rego Patterns

## Partial Evaluation

Partial evaluation pre-computes parts of a policy that don't depend on unknown input:

```bash
opa eval --partial -d policy.rego --unknowns input "data.authz.allow"
```

Use case: Compile policies to simpler queries for downstream enforcement (e.g., SQL WHERE clauses, API gateway rules).

---

## Bundle Structure

### Standard Bundle Layout

```
bundle/
├── authz/
│   ├── policy.rego        # Policy files
│   └── helpers.rego       # Helper library
├── data.json              # Static data (roles, allowlists)
├── .manifest              # Bundle metadata
└── .signatures.json       # Cryptographic signatures
```

### .manifest Format

```json
{
  "revision": "abc123",
  "roots": ["authz"],
  "metadata": {
    "created": "2024-01-15T10:00:00Z"
  }
}
```

### Data Layering

```
bundle/
├── roles/
│   └── data.json          # data.roles = {...}
├── tenants/
│   └── data.json          # data.tenants = {...}
└── policies/
    └── authz.rego         # References data.roles, data.tenants
```

Files named `data.json` or `data.yaml` are loaded into the `data` tree based on their directory path.

---

## Schema Validation

Define JSON schemas for policy inputs:

```rego
# METADATA
# schemas:
#   - input: schema.input
package authz

import rego.v1

allow if {
    input.user.role == "admin"  # Schema ensures input.user.role exists
}
```

Schema file (`schema/input.json`):
```json
{
  "type": "object",
  "properties": {
    "user": {
      "type": "object",
      "properties": {
        "role": {"type": "string"},
        "groups": {"type": "array", "items": {"type": "string"}}
      },
      "required": ["role"]
    }
  },
  "required": ["user"]
}
```

Check with schemas:
```bash
opa check --schema schema/ ./policies/
```

---

## Custom Metadata for Policy Discovery

Use `# METADATA` annotations for policy cataloging:

```rego
# METADATA
# title: Deny public S3 buckets
# description: S3 buckets must not have public ACLs
# scope: rule
# custom:
#   severity: critical
#   benchmarks:
#     cis_aws: ["2.1.5"]
#     soc2: ["CC6.1"]
#   remediation: Set bucket ACL to 'private' or remove public access grants
#   tags: ["aws", "s3", "storage", "encryption"]
deny contains msg if {
    # ...
}
```

Extract metadata programmatically:
```bash
opa inspect --annotations ./policies/
```

---

## Policy Composition Patterns

### Base + Override

```rego
# base.rego
package authz

import rego.v1

default allow := false

allow if {
    data.authz.exceptions[input.user.id]
}
```

```rego
# team_overrides.rego
package authz

import rego.v1

allow if {
    input.user.team == "platform"
    input.resource.namespace == "platform"
}
```

Multiple files in the same package merge their rules.

### Library Pattern

```rego
# lib/kubernetes.rego
package lib.kubernetes

import rego.v1

pods contains pod if {
    some pod in data.kubernetes.pods
}

containers contains container if {
    some pod in pods
    some container in pod.spec.containers
}

init_containers contains container if {
    some pod in pods
    some container in pod.spec.initContainers
}

all_containers := containers | init_containers
```

### Policy Layers

```
policies/
├── lib/                   # Shared helpers (platform-agnostic)
│   ├── kubernetes.rego
│   └── strings.rego
├── baseline/              # Organization-wide minimum
│   └── pod_security.rego
├── team/                  # Team-specific overrides
│   └── platform_exceptions.rego
└── project/               # Project-specific rules
    └── api_gateway.rego
```

---

## Performance Patterns

### Indexing

OPA automatically indexes rule heads for fast lookup. Structure rules for indexing:

```rego
# Good: OPA indexes on input.method and input.path
allow if {
    input.method == "GET"
    input.path == "/public"
}

# Less efficient: computation before indexable check
allow if {
    trimmed := trim_space(input.path)
    trimmed == "/public"
}
```

### Caching External Data

Avoid `http.send` in hot paths. Use data bundles instead:

```rego
# Bad: HTTP call per evaluation
allow if {
    resp := http.send({"method": "GET", "url": "https://api.example.com/roles"})
    resp.body.roles[input.user.id] == "admin"
}

# Good: Data loaded via bundle
allow if {
    data.roles[input.user.id] == "admin"
}
```

### Set Membership vs Array Iteration

```rego
# Fast: Set membership check
allowed_registries := {"gcr.io", "docker.io", "quay.io"}
deny if {
    not allowed_registries[input.image.registry]
}

# Slower: Array iteration
allowed_registries := ["gcr.io", "docker.io", "quay.io"]
deny if {
    not input.image.registry in allowed_registries
}
```

---

## Error Handling Patterns

### Safe Navigation with object.get

```rego
# Unsafe: crashes if securityContext is missing
deny if {
    not input.spec.securityContext.runAsNonRoot
}

# Safe: default to empty object
deny if {
    sc := object.get(input.spec, "securityContext", {})
    not object.get(sc, "runAsNonRoot", false)
}
```

### Optional Fields with Default

```rego
# Check field exists before accessing
container_privileged(c) if {
    sc := object.get(c, "securityContext", {})
    object.get(sc, "privileged", false) == true
}
```

---

## String Interpolation (OPA 1.0+)

```rego
msg := $"container '{container.name}' in namespace '{input.namespace}' is privileged"
```

Equivalent to:
```rego
msg := sprintf("container '%s' in namespace '%s' is privileged", [container.name, input.namespace])
```
