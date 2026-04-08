---
name: opa-testing
description: This skill should be used when the user asks to "test opa", "opa test", "test rego", "write rego tests", "policy coverage", "conftest verify", "mock opa", or mentions `_test.rego` files. Provides OPA testing framework guidance including unit tests, mocking, coverage, and Conftest patterns.
---

# OPA Testing

Comprehensive guide for testing OPA/Rego policies using `opa test`, Conftest, and related tooling.

**REQUIRED: Every test suite MUST include all three categories:**
1. **Positive tests** -- valid input that should produce zero violations
2. **Negative tests** -- invalid input that should trigger specific violations
3. **Edge case tests** -- empty input, missing fields, null values, boundary conditions

Edge cases are NOT optional "nice-to-have" tests. They catch the most dangerous bugs: policies that silently fail to enforce when fields are missing. A policy without edge case tests is an untested policy.

**REQUIRED: Verify violation messages, not just counts.** Tests that only assert `count(result) > 0` prove a violation exists but NOT that the correct rule fired. Always verify message content:
```rego
# WRONG: only checks count
test_deny_privileged if {
    result := violation with input as bad_pod
    count(result) > 0
}

# CORRECT: verifies the right violation fired
test_deny_privileged if {
    result := violation with input as bad_pod
    count(result) > 0
    some msg in result
    contains(msg, "privileged")
}
```

## Testing Framework Overview

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `opa test` | Unit test Rego policies | Always - primary testing mechanism |
| `conftest verify` | Test Conftest policies | When using Conftest for structured config |
| `opa eval` | Ad-hoc evaluation | Debugging, exploration |
| `opa bench` | Performance testing | Optimizing hot-path policies |

---

## Test File Conventions

Test files use `_test.rego` suffix and share the same package as the policy under test:

```
policies/
├── kubernetes/
│   ├── pod_security.rego        # Policy
│   └── pod_security_test.rego   # Tests
├── terraform/
│   ├── s3_encryption.rego
│   └── s3_encryption_test.rego
└── lib/
    ├── helpers.rego
    └── helpers_test.rego
```

---

## Writing Tests

### Basic Test Structure

```rego
package kubernetes.pod_security_test

import rego.v1
import data.kubernetes.pod_security

# Test rule prefix: test_
test_deny_privileged_container if {
    result := pod_security.violation with input as {
        "review": {"object": {"spec": {"containers": [
            {"name": "nginx", "securityContext": {"privileged": true}}
        ]}}}
    }
    count(result) > 0
}

test_allow_non_privileged_container if {
    result := pod_security.violation with input as {
        "review": {"object": {"spec": {"containers": [
            {"name": "nginx", "securityContext": {"privileged": false}}
        ]}}}
    }
    count(result) == 0
}
```

### Test Naming Convention

| Prefix | Meaning |
|--------|---------|
| `test_` | Active test (PASS/FAIL) |
| `todo_` | Skipped test (SKIPPED) |

Name tests descriptively: `test_<rule>_<scenario>_<expected_outcome>`

```rego
test_deny_when_container_privileged if { ... }
test_allow_when_securitycontext_drop_all if { ... }
test_deny_when_no_resource_limits_set if { ... }
```

---

## Mocking with `with`

The `with` keyword replaces values during evaluation:

### Mock Input

```rego
test_allow_admin if {
    pod_security.allow with input as {"user": {"role": "admin"}}
}
```

### Mock Data

```rego
test_with_external_data if {
    result := authz.allow with input as {"user": "alice"}
                            with data.roles as {"alice": ["admin"]}
}
```

### Mock Functions

```rego
test_with_mocked_time if {
    result := policy.is_expired with time.now_ns as 1672531200000000000
}

test_with_mocked_http if {
    mock_response := {"status_code": 200, "body": {"allowed": true}}
    result := policy.check_external with http.send as mock_response
}
```

### Mock Built-in Rules

```rego
test_with_mocked_rule if {
    policy.main_decision with data.policy.helper_rule as true
}
```

---

## Running Tests

### Basic Commands

```bash
# Run all tests
opa test . -v

# Run tests in specific directory
opa test ./policies/ -v

# Run tests matching regex
opa test . -v --run "test_deny.*privileged"

# JSON output for CI
opa test . --format=json

# With coverage
opa test . -v --coverage

# With coverage threshold (exit non-zero if below)
opa test . --coverage --threshold 80

# Show variable values on failure
opa test . -v --var-values

# Benchmark tests
opa test . --bench --benchmem
```

### Test Output Format

```
PASS: 12/15
FAIL: 2/15
SKIPPED: 1/15

data.kubernetes.pod_security_test.test_deny_privileged: PASS (1.234ms)
data.kubernetes.pod_security_test.test_deny_no_limits: FAIL (0.567ms)
  rule "test_deny_no_limits" body was undefined
data.kubernetes.pod_security_test.todo_future_feature: SKIPPED
```

---

## Coverage Analysis

```bash
# Generate coverage report
opa test . --coverage --format=json > coverage.json

# Threshold enforcement
opa test . --coverage --threshold 80
```

Coverage tracks which lines of policy code are exercised by tests. Target:
- **80%+** for critical security policies (deny rules, admission control)
- **70%+** for standard policies
- **60%+** for helper libraries

---

## Test Organization Patterns (All Three Categories Required)

### Positive/Negative/Edge Case Structure

```rego
# === Positive Tests (policy should allow) ===

test_allow_valid_pod if {
    count(violation) == 0 with input as valid_pod
}

# === Negative Tests (policy should deny -- ALWAYS verify message content) ===

test_deny_privileged if {
    result := violation with input as privileged_pod
    count(result) > 0
    some msg in result
    contains(msg, "privileged")  # Verify the RIGHT rule fired
}

# === Edge Cases (REQUIRED -- catch silent enforcement failures) ===

test_edge_empty_containers if {
    count(violation) == 0 with input as {"spec": {"containers": []}}
}

test_edge_missing_security_context if {
    # This catches the most dangerous bug: policy silently not firing on missing fields
    result := violation with input as {"spec": {"containers": [{"name": "test"}]}}
    count(result) > 0  # Container with NO securityContext should still trigger deny
}

test_edge_empty_input if {
    count(violation) == 0 with input as {}
}

test_edge_null_field if {
    result := violation with input as {"spec": {"containers": [{"name": "test", "securityContext": null}]}}
    count(result) > 0
}

# === Test Fixtures ===

valid_pod := {"spec": {"containers": [
    {"name": "app", "securityContext": {"runAsNonRoot": true, "privileged": false}}
]}}

privileged_pod := {"spec": {"containers": [
    {"name": "app", "securityContext": {"privileged": true}}
]}}
```

### Parameterized Tests

```rego
# Multiple test cases via separate rules
test_deny_privileged_single if { _test_deny_privileged(1) }
test_deny_privileged_multiple if { _test_deny_privileged(3) }

_test_deny_privileged(n) if {
    containers := [c |
        some i in numbers.range(0, n - 1)
        c := {"name": sprintf("c%d", [i]), "securityContext": {"privileged": true}}
    ]
    result := violation with input as {"spec": {"containers": containers}}
    count(result) == n
}
```

---

## Conftest Testing

For testing structured configuration files (Terraform, K8s YAML, Docker):

```bash
# Test Terraform plan
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
conftest test tfplan.json -p policy/

# Test Kubernetes manifests
conftest test deployment.yaml -p policy/

# Test Dockerfiles
conftest test Dockerfile -p policy/

# Verify policy tests
conftest verify -p policy/
```

### Conftest Test File

```rego
package main_test

import rego.v1
import data.main

test_deny_no_encryption if {
    result := main.deny with input as {
        "resource_changes": [{"type": "aws_s3_bucket", "change": {"after": {"server_side_encryption_configuration": null}}}]
    }
    count(result) > 0
}
```

---

## CI/CD Integration

```yaml
# GitHub Actions example
- name: Run OPA Tests
  run: |
    opa test ./policies/ -v --coverage --threshold 80 --format=json > test-results.json

- name: Run Conftest
  run: |
    conftest test tfplan.json -p policy/ --output json
```

---

## Additional Resources

### Reference Files

- **`references/test-patterns.md`** - Advanced testing patterns: table-driven tests, golden file testing, integration test helpers
- **`references/conftest-guide.md`** - Conftest deep dive: parsers, namespaces, output formats, OCI registries

### Example Files

- **`examples/pod_security_test.rego`** - Complete K8s pod security test suite
- **`examples/terraform_test.rego`** - Terraform plan evaluation tests
