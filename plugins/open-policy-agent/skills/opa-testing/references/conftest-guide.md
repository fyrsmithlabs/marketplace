# Conftest Deep Dive

## Overview

Conftest is a testing framework for structured configuration data. It uses OPA/Rego for policy definitions and supports multiple input formats.

## Supported Input Formats

| Format | File Extensions | Parser |
|--------|----------------|--------|
| JSON | `.json` | Native |
| YAML | `.yaml`, `.yml` | Native |
| TOML | `.toml` | Native |
| HCL | `.tf`, `.hcl` | HCL2 parser |
| Dockerfile | `Dockerfile*` | Dockerfile parser |
| INI | `.ini` | INI parser |
| XML | `.xml` | XML parser |
| CUE | `.cue` | CUE parser |
| Jsonnet | `.jsonnet` | Jsonnet parser |
| TextProto | `.textproto` | Protocol Buffers text |
| Spdx | `.spdx` | SPDX SBOM |
| CycloneDX | `.cdx.json`, `.cdx.xml` | CycloneDX SBOM |

## Core Commands

### `conftest test`

```bash
# Test a file against policies
conftest test deployment.yaml -p policy/

# Test multiple files
conftest test *.yaml -p policy/

# Test with specific namespace
conftest test tfplan.json -p policy/ --namespace terraform.aws

# JSON output
conftest test file.yaml -p policy/ --output json

# Custom data
conftest test file.yaml -p policy/ --data data/

# Combine inputs
conftest test --combine deployment.yaml service.yaml -p policy/

# Fail on warnings too
conftest test file.yaml -p policy/ --fail-on-warn
```

### `conftest verify`

Test the policies themselves (policy unit tests):

```bash
conftest verify -p policy/
```

Test files must be in the same directory as policies with `_test.rego` suffix.

### `conftest push` / `conftest pull`

Distribute policies via OCI registries:

```bash
# Push policies to registry
conftest push registry.example.com/policies:v1.0 -p policy/

# Pull policies from registry
conftest pull registry.example.com/policies:v1.0 -p policy/

# Pull specific policy
conftest pull oci://ghcr.io/org/policies:latest
```

### `conftest fmt`

Format Rego files:
```bash
conftest fmt policy/
```

## Policy Structure for Conftest

### Namespace Convention

Conftest uses `package main` by default, but supports namespacing:

```rego
# Default package (most common)
package main

# Namespaced package
package terraform.aws.s3
```

Use `--namespace` to target specific packages:
```bash
conftest test tfplan.json --namespace terraform.aws.s3
```

### Deny, Warn, Violation Rules

```rego
package main

import rego.v1

# deny - blocks with exit code 1
deny contains msg if {
    input.kind == "Deployment"
    not input.spec.template.spec.securityContext.runAsNonRoot
    msg := "Deployment must set runAsNonRoot"
}

# warn - prints warning but exit code 0 (unless --fail-on-warn)
warn contains msg if {
    input.kind == "Deployment"
    not input.metadata.labels.team
    msg := "Deployment should have a 'team' label"
}

# violation - same as deny (Gatekeeper compatibility)
violation contains {"msg": msg} if {
    # Gatekeeper-style output
    msg := "violation message"
}
```

### Multi-Resource Policies

Use `--combine` to pass multiple resources as an array:

```bash
conftest test --combine deployment.yaml service.yaml configmap.yaml -p policy/
```

```rego
package main

import rego.v1

# input is now an array of resources
deny contains msg if {
    some resource in input
    resource.kind == "Deployment"
    not _has_service(resource.metadata.name)
    msg := sprintf("Deployment '%s' has no matching Service", [resource.metadata.name])
}

_has_service(name) if {
    some resource in input
    resource.kind == "Service"
    resource.spec.selector.app == name
}
```

## Conftest with Terraform

### Workflow

```bash
# 1. Generate plan
terraform plan -out=tfplan

# 2. Convert to JSON
terraform show -json tfplan > tfplan.json

# 3. Test with Conftest
conftest test tfplan.json -p policy/terraform/
```

### Accessing Terraform Plan Data

```rego
package terraform.aws

import rego.v1

# Access resource changes
deny contains msg if {
    some rc in input.resource_changes
    rc.type == "aws_s3_bucket"
    "create" in rc.change.actions
    not rc.change.after.server_side_encryption_configuration
    msg := sprintf("S3 bucket '%s' must have encryption", [rc.address])
}

# Access planned values
deny contains msg if {
    some resource in input.planned_values.root_module.resources
    resource.type == "aws_security_group"
    some rule in resource.values.ingress
    "0.0.0.0/0" in rule.cidr_blocks
    msg := sprintf("Security group '%s' allows 0.0.0.0/0", [resource.address])
}
```

## Conftest with Kubernetes

```bash
# Test single manifest
conftest test deployment.yaml -p policy/kubernetes/

# Test all manifests in directory
conftest test manifests/*.yaml -p policy/kubernetes/

# Test Helm output
helm template my-release ./chart | conftest test - -p policy/kubernetes/

# Test kustomize output
kustomize build ./overlay | conftest test - -p policy/kubernetes/
```

## Conftest with Docker

```bash
conftest test Dockerfile -p policy/docker/
```

Dockerfile input structure:
```json
{
  "Stages": [
    {
      "Name": "",
      "From": {"Image": "ubuntu", "Tag": "22.04"},
      "Commands": [
        {"Cmd": "run", "Value": ["apt-get update && apt-get install -y curl"]},
        {"Cmd": "copy", "Value": [".", "/app"]},
        {"Cmd": "expose", "Value": ["8080"]},
        {"Cmd": "cmd", "Value": ["./app"]}
      ]
    }
  ]
}
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Install Conftest
  run: |
    LATEST=$(curl -s https://api.github.com/repos/open-policy-agent/conftest/releases/latest | jq -r .tag_name)
    curl -LO "https://github.com/open-policy-agent/conftest/releases/download/${LATEST}/conftest_${LATEST#v}_Linux_x86_64.tar.gz"
    tar xzf conftest_*.tar.gz
    sudo mv conftest /usr/local/bin/

- name: Test Terraform Plan
  run: conftest test tfplan.json -p policy/ --output json

- name: Test K8s Manifests
  run: conftest test manifests/*.yaml -p policy/ --output json
```

### GitLab CI

```yaml
conftest:
  image: openpolicyagent/conftest:latest
  script:
    - conftest test tfplan.json -p policy/
```

## Output Formats

```bash
# Standard (default)
conftest test file.yaml -p policy/

# JSON
conftest test file.yaml -p policy/ --output json

# TAP (Test Anything Protocol)
conftest test file.yaml -p policy/ --output tap

# Table
conftest test file.yaml -p policy/ --output table

# JUnit XML
conftest test file.yaml -p policy/ --output junit

# GitHub Actions format
conftest test file.yaml -p policy/ --output github
```
