# Advanced OPA Testing Patterns

## Table-Driven Tests

Use a helper function to run multiple test cases with shared logic:

```rego
package authz_test

import rego.v1
import data.authz

# Define test cases as an array of objects
test_cases := [
    {"name": "admin_allowed", "role": "admin", "method": "POST", "expected": true},
    {"name": "viewer_get", "role": "viewer", "method": "GET", "expected": true},
    {"name": "viewer_post", "role": "viewer", "method": "POST", "expected": false},
    {"name": "unknown_role", "role": "unknown", "method": "GET", "expected": false},
]

# Individual test rules reference the table
test_admin_allowed if { _run_case(test_cases[0]) }
test_viewer_get if { _run_case(test_cases[1]) }
test_viewer_post if { _run_case(test_cases[2]) }
test_unknown_role if { _run_case(test_cases[3]) }

_run_case(tc) if {
    result := authz.allow with input as {"user": {"role": tc.role}, "method": tc.method}
    result == tc.expected
}
```

---

## Golden File Testing

Compare policy output against known-good results:

```rego
package golden_test

import rego.v1
import data.policy

# Golden output stored as data
golden_output := {
    "violations": [
        "container 'nginx' must not be privileged",
        "pod must set runAsNonRoot"
    ]
}

test_golden_match if {
    result := policy.violation with input as data.fixtures.test_pod
    result == golden_output.violations
}
```

Load golden files as data:
```bash
opa test -d fixtures/ -d golden/ ./policies/
```

---

## Integration Test Pattern

Test policy against real resource manifests:

```rego
package integration_test

import rego.v1
import data.kubernetes.pod_security

# Load real manifests as test fixtures
test_production_deployment if {
    result := pod_security.violation with input as data.fixtures.production_deployment
    count(result) == 0
}

test_known_bad_deployment if {
    result := pod_security.violation with input as data.fixtures.bad_deployment
    count(result) > 0
}
```

Directory structure:
```
tests/
├── fixtures/
│   ├── production_deployment/
│   │   └── data.json    # Real deployment manifest
│   └── bad_deployment/
│       └── data.json    # Known-bad manifest
└── integration_test.rego
```

Run:
```bash
opa test -d tests/fixtures/ ./policies/ ./tests/
```

---

## Mocking Complex Data Structures

### Mock Kubernetes RBAC Data

```rego
test_deny_wildcard_role if {
    mock_roles := {
        "admin-role": {
            "rules": [{"apiGroups": ["*"], "resources": ["*"], "verbs": ["*"]}]
        }
    }
    result := rbac.violation with data.kubernetes.roles as mock_roles
    count(result) > 0
}
```

### Mock External API Response

```rego
test_with_external_check if {
    mock_response := {
        "status_code": 200,
        "body": {"allowed": true, "reason": "approved"}
    }
    result := policy.check with http.send as mock_response
    result == true
}
```

### Mock Time

```rego
test_certificate_expired if {
    # Mock time to January 2025
    expired := policy.is_cert_expired with time.now_ns as 1735689600000000000
    expired == true
}

test_certificate_valid if {
    # Mock time to January 2024
    valid := policy.is_cert_expired with time.now_ns as 1704067200000000000
    valid == false
}
```

---

## Testing Helpers and Libraries

Test shared helper functions independently:

```rego
package lib.kubernetes_test

import rego.v1
import data.lib.kubernetes

test_containers_extracts_all if {
    mock_pods := [
        {"spec": {"containers": [{"name": "a"}, {"name": "b"}]}},
        {"spec": {"containers": [{"name": "c"}]}}
    ]
    result := kubernetes.containers with data.kubernetes.pods as mock_pods
    count(result) == 3
}

test_has_label if {
    obj := {"metadata": {"labels": {"app": "nginx", "env": "prod"}}}
    kubernetes.has_label(obj, "app")
}

test_missing_label if {
    obj := {"metadata": {"labels": {"app": "nginx"}}}
    not kubernetes.has_label(obj, "team")
}
```

---

## Coverage-Driven Test Writing

1. Run with coverage to find gaps:
```bash
opa test . --coverage --format=json | jq '.files'
```

2. Identify uncovered lines
3. Write tests targeting uncovered code paths
4. Iterate until threshold met

Focus coverage on:
- All deny rule conditions
- All else branches
- Helper function edge cases
- Default value override scenarios

---

## Performance Testing

```bash
# Benchmark specific test
opa bench -d policies/ -i fixtures/large_input.json "data.authz.allow" --benchmem

# Output:
# BenchmarkEval   10000   123456 ns/op   12345 B/op   234 allocs/op
```

Performance test assertions in Rego are not directly supported, but use benchmarks in CI to catch regressions:

```yaml
- name: Benchmark OPA Policies
  run: |
    opa bench -d policies/ -i fixtures/input.json "data.authz.allow" --benchmem --count 5 > bench.txt
    cat bench.txt
```
