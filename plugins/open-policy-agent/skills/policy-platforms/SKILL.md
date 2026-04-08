---
name: policy-platforms
description: This skill should be used when the user asks about "kubernetes policy", "gatekeeper", "constraint template", "terraform policy", "conftest", "terraform compliance", "docker policy", "dockerfile policy", "envoy authz", "envoy authorization", "service mesh policy", "cloud policy", "aws policy rego", "azure policy rego", "gcp policy rego", or mentions writing OPA policies for a specific platform. Provides platform-specific Rego patterns and input schemas.
---

# Policy Platforms

Platform-specific OPA/Rego patterns covering Kubernetes, Terraform, Docker, cloud providers, and service mesh. Each platform has unique input schemas and conventions.

## Platform Quick Reference

| Platform | Input Source | Policy Tool | Key Package |
|----------|-------------|-------------|-------------|
| Kubernetes | AdmissionReview | Gatekeeper / OPA | `kubernetes.admission` |
| Terraform | Plan JSON | Conftest / OPA | `terraform.analysis` |
| Docker | Dockerfile AST | Conftest | `main` (Conftest convention) |
| Envoy | CheckRequest | OPA-Envoy plugin | `envoy.authz` |
| AWS/Azure/GCP | Terraform plan / CloudFormation | Conftest / Regula / Terrascan | Varies |

---

## Kubernetes (Gatekeeper)

### Input Schema

Gatekeeper provides an `AdmissionReview` object:

```json
{
  "review": {
    "object": { /* resource being created/updated */ },
    "oldObject": { /* previous version on UPDATE */ },
    "operation": "CREATE",
    "userInfo": { "username": "admin", "groups": ["system:masters"] },
    "namespace": "default"
  },
  "parameters": { /* constraint parameters */ }
}
```

### ConstraintTemplate Pattern

```rego
package k8srequiredlabels

import rego.v1

violation contains {"msg": msg, "details": {"missing_labels": missing}} if {
    provided := {label | some label, _ in input.review.object.metadata.labels}
    required := {label | some label in input.parameters.labels}
    missing := required - provided
    count(missing) > 0
    msg := sprintf("missing required labels: %v", [missing])
}
```

### Common K8s Policy Categories

| Category | Examples |
|----------|---------|
| **Pod Security** | No privileged, runAsNonRoot, drop capabilities, read-only rootfs |
| **Resource Limits** | CPU/memory limits required, ratio constraints |
| **Image Policy** | Allowed registries, no `latest` tag, signed images |
| **Network** | NetworkPolicy required, no hostNetwork, port restrictions |
| **Labels/Annotations** | Required labels, label format validation |
| **RBAC** | No wildcard permissions, namespace isolation |

### Testing Gatekeeper Policies Locally

```bash
# Install gator CLI
go install github.com/open-policy-agent/gatekeeper/v3/cmd/gator@latest

# Test constraint template
gator verify suite.yaml

# Verify against test resources
gator test -f constraint-template.yaml -f constraint.yaml -f test-resource.yaml
```

---

## Terraform

### Input Schema

Terraform plan JSON (via `terraform show -json tfplan`):

```json
{
  "resource_changes": [
    {
      "address": "aws_s3_bucket.example",
      "type": "aws_s3_bucket",
      "provider_name": "registry.terraform.io/hashicorp/aws",
      "change": {
        "actions": ["create"],
        "before": null,
        "after": { /* planned state */ },
        "after_unknown": { /* computed values */ }
      }
    }
  ],
  "configuration": { /* HCL configuration tree */ },
  "planned_values": { /* root_module with resources */ }
}
```

### Conftest Policy Pattern

```rego
package terraform.aws.s3

import rego.v1

deny contains msg if {
    some rc in input.resource_changes
    rc.type == "aws_s3_bucket"
    "create" in rc.change.actions
    not rc.change.after.server_side_encryption_configuration
    msg := sprintf("S3 bucket '%s' must have encryption enabled", [rc.address])
}

deny contains msg if {
    some rc in input.resource_changes
    rc.type == "aws_s3_bucket"
    rc.change.after.acl == "public-read"
    msg := sprintf("S3 bucket '%s' must not be public", [rc.address])
}
```

### Workflow

```bash
# Generate plan JSON
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json

# Evaluate with Conftest
conftest test tfplan.json -p policy/terraform/

# Evaluate with OPA directly
opa eval -d policy/terraform/ -i tfplan.json "data.terraform.aws.s3.deny"
```

### Common Terraform Policy Categories

| Category | Examples |
|----------|---------|
| **Encryption** | S3 SSE, RDS encryption, EBS encryption |
| **Networking** | No public IPs, security group restrictions, VPC required |
| **IAM** | No wildcard actions, MFA required, role boundaries |
| **Tagging** | Required tags (env, team, cost-center) |
| **Compliance** | Logging enabled, backup configured, deletion protection |

---

## Docker

### Input Schema

Conftest parses Dockerfiles into structured commands:

```json
{
  "Stages": [
    {
      "Name": "builder",
      "From": {"Image": "golang", "Tag": "1.22"},
      "Commands": [
        {"Cmd": "run", "Value": ["apt-get install -y curl"]},
        {"Cmd": "copy", "Value": [".", "/app"]},
        {"Cmd": "user", "Value": ["nonroot"]}
      ]
    }
  ]
}
```

### Dockerfile Policy Pattern

```rego
package docker.security

import rego.v1

deny contains msg if {
    some stage in input.Stages
    stage.From.Tag == "latest"
    msg := sprintf("stage '%s' uses 'latest' tag - pin to specific version", [stage.Name])
}

deny contains msg if {
    some stage in input.Stages
    not _has_user(stage)
    msg := sprintf("stage '%s' missing USER instruction - must not run as root", [stage.Name])
}

warn contains msg if {
    some stage in input.Stages
    some cmd in stage.Commands
    cmd.Cmd == "add"
    msg := "prefer COPY over ADD unless extracting archives"
}

_has_user(stage) if {
    some cmd in stage.Commands
    cmd.Cmd == "user"
}
```

### Workflow

```bash
conftest test Dockerfile -p policy/docker/
```

---

## Envoy / Service Mesh

### Input Schema

OPA-Envoy external authorization request:

```json
{
  "attributes": {
    "request": {
      "http": {
        "method": "GET",
        "path": "/api/v1/users",
        "headers": {
          "authorization": "Bearer eyJ..."
        }
      }
    },
    "source": {
      "principal": "spiffe://cluster.local/ns/default/sa/frontend"
    },
    "destination": {
      "principal": "spiffe://cluster.local/ns/default/sa/backend"
    }
  }
}
```

### Envoy Authorization Pattern

```rego
package envoy.authz

import rego.v1

default allow := false

allow if {
    input.attributes.request.http.method == "GET"
    glob.match("/api/v1/public/*", ["/"], input.attributes.request.http.path)
}

allow if {
    input.attributes.request.http.method in {"GET", "POST"}
    token := io.jwt.decode(bearer_token)
    "admin" in token[1].roles
}

bearer_token := t if {
    auth_header := input.attributes.request.http.headers.authorization
    startswith(auth_header, "Bearer ")
    t := substring(auth_header, 7, -1)
}
```

---

## Cloud Provider Patterns

### AWS (Terraform)

Common AWS resource types and their security properties:

| Resource | Security Properties |
|----------|-------------------|
| `aws_s3_bucket` | `server_side_encryption_configuration`, `acl`, `versioning`, `logging` |
| `aws_security_group` | `ingress[].cidr_blocks` (no `0.0.0.0/0` on sensitive ports) |
| `aws_rds_instance` | `storage_encrypted`, `backup_retention_period`, `deletion_protection` |
| `aws_iam_policy` | No `*` in `Action` or `Resource` |
| `aws_cloudtrail` | `enable_logging`, `is_multi_region_trail` |

### Azure (Terraform)

| Resource | Security Properties |
|----------|-------------------|
| `azurerm_storage_account` | `enable_https_traffic_only`, `min_tls_version`, `network_rules` |
| `azurerm_key_vault` | `purge_protection_enabled`, `soft_delete_retention_days` |
| `azurerm_sql_server` | `administrator_login`, `minimum_tls_version` |

### GCP (Terraform)

| Resource | Security Properties |
|----------|-------------------|
| `google_storage_bucket` | `uniform_bucket_level_access`, `encryption` |
| `google_compute_firewall` | `source_ranges` (no `0.0.0.0/0`) |
| `google_sql_database_instance` | `settings.ip_configuration.require_ssl` |

---

## Common Mistakes -- DO NOT MAKE THESE

These are the most frequent platform-specific errors. Check every policy against this table before finalizing.

### Kubernetes / Gatekeeper

| WRONG | CORRECT | Why |
|-------|---------|-----|
| `input.spec.containers` | `input.review.object.spec.containers` | Gatekeeper wraps the resource under `input.review.object` |
| `deny contains msg if` | `violation contains {"msg": msg} if` | Gatekeeper uses `violation` returning objects, not `deny` returning strings |
| `input.labels` | `input.review.object.metadata.labels` | Labels are nested under the full K8s object path |
| Checking only `containers` | Also check `initContainers` | Init containers can also have security issues |
| `input.spec.template.spec.containers` (for Deployments) | Check `input.review.object.spec.template.spec.containers` | Workload controllers nest pod spec under `.spec.template.spec` |

### Terraform

| WRONG | CORRECT | Why |
|-------|---------|-----|
| `input.resources` | `input.resource_changes` | `resources` does not exist in plan JSON; use `resource_changes` |
| `input.planned_values.resources` | `input.planned_values.root_module.resources` | Missing `root_module` intermediate key |
| `rc.after.bucket` | `rc.change.after.bucket` | Planned values are under `rc.change.after`, not `rc.after` |
| Not checking `rc.change.actions` | Filter by `"create" in rc.change.actions` | Policies should only enforce on relevant actions (create/update) |

### Docker / Conftest

| WRONG | CORRECT | Why |
|-------|---------|-----|
| `input.commands` | `input.Stages[].Commands[]` | Docker AST nests commands under Stages; fields are PascalCase |
| `cmd == "ADD"` | `cmd.Cmd == "add"` | Commands are objects with `.Cmd` field; command type values are lowercase |
| `input.from` | `input.Stages[].From.Image` | Base image is nested under PascalCase `From.Image` per stage |
| Lowercase field names | PascalCase: `Stages`, `Commands`, `Name`, `From`, `Cmd`, `Value` | Conftest Dockerfile parser uses PascalCase for all struct fields |

### Envoy

| WRONG | CORRECT | Why |
|-------|---------|-----|
| `input.request.method` | `input.attributes.request.http.method` | Envoy nests HTTP details under `attributes.request.http` |
| `input.headers` | `input.attributes.request.http.headers` | Headers are deeply nested |

---

## Additional Resources

### Reference Files

- **`references/kubernetes-input.md`** - Complete K8s AdmissionReview schema, Gatekeeper ConstraintTemplate authoring, gator testing
- **`references/terraform-input.md`** - Full Terraform plan JSON schema, resource_changes structure, configuration tree navigation
- **`references/cloud-resources.md`** - Comprehensive cloud resource security properties for AWS, Azure, GCP
