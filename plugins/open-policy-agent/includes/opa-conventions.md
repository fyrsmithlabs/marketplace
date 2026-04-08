# OPA Policy Conventions

## File Organization

```
policies/
├── <platform>/
│   ├── <component>.rego           # Policy rules
│   ├── <component>_test.rego      # Tests
│   └── <component>_helpers.rego   # Platform helpers (optional)
└── lib/
    ├── kubernetes.rego            # Shared K8s helpers
    ├── strings.rego               # String utilities
    └── validation.rego            # Common validation helpers
```

## Package Naming

```rego
# Platform policies
package kubernetes.pod_security
package terraform.aws.s3_encryption
package docker.image_security
package envoy.api_authorization

# Library packages
package lib.kubernetes
package lib.validation

# Test packages
package kubernetes.pod_security_test
```

## Metadata Annotations

Every deny/violation/warn rule should have metadata:

```rego
# METADATA
# title: <rule title>
# description: <what this rule enforces>
# custom:
#   severity: <critical|high|medium|low>
#   benchmarks:
#     cis_kubernetes: ["5.2.1"]
#     soc2: ["CC6.6"]
#     nist_800_53: ["AC-6"]
#   remediation: <how to fix>
```

## Rego v1 Requirements

- Always use `if` keyword for complete rules
- Always use `contains` for partial set rules
- Use `:=` for assignment and defaults
- Use `some x in collection` for iteration
- No `import future.keywords.*` or `import rego.v1`
