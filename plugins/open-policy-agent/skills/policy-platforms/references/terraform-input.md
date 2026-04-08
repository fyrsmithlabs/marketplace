# Terraform Plan JSON Input Schema

## Generating Plan JSON

```bash
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json
```

## Top-Level Structure

```json
{
  "format_version": "1.2",
  "terraform_version": "1.7.0",
  "planned_values": { /* tree of planned resource values */ },
  "resource_changes": [ /* list of resource changes */ ],
  "configuration": { /* HCL configuration tree */ },
  "prior_state": { /* state before the plan */ },
  "variables": { /* input variables */ },
  "output_changes": { /* output value changes */ }
}
```

## resource_changes (Primary for Policy)

The most commonly used section for OPA policies:

```json
{
  "resource_changes": [
    {
      "address": "aws_s3_bucket.example",
      "module_address": "module.storage",
      "mode": "managed",
      "type": "aws_s3_bucket",
      "name": "example",
      "provider_name": "registry.terraform.io/hashicorp/aws",
      "change": {
        "actions": ["create"],
        "before": null,
        "after": {
          "bucket": "my-bucket",
          "acl": "private",
          "server_side_encryption_configuration": {
            "rule": {
              "apply_server_side_encryption_by_default": {
                "sse_algorithm": "aws:kms"
              }
            }
          },
          "versioning": {
            "enabled": true
          },
          "tags": {
            "Environment": "production",
            "Team": "platform"
          }
        },
        "after_unknown": {
          "arn": true,
          "bucket_domain_name": true,
          "id": true
        },
        "before_sensitive": false,
        "after_sensitive": {}
      }
    }
  ]
}
```

### Change Actions

| Action | Meaning |
|--------|---------|
| `["create"]` | New resource |
| `["update"]` | Modify in-place |
| `["delete"]` | Destroy resource |
| `["delete", "create"]` | Replace (destroy then create) |
| `["create", "delete"]` | Replace (create then destroy) |
| `["read"]` | Data source refresh |
| `["no-op"]` | No changes |

### Common Access Patterns

```rego
# Iterate all resource changes
some rc in input.resource_changes

# Filter by type
rc.type == "aws_s3_bucket"

# Filter by action
"create" in rc.change.actions

# Access planned values
rc.change.after.bucket
rc.change.after.tags.Environment

# Access current state (before change)
rc.change.before.acl

# Check if field is computed (unknown)
rc.change.after_unknown.arn == true

# Filter by provider
startswith(rc.provider_name, "registry.terraform.io/hashicorp/aws")

# Filter by module
startswith(rc.module_address, "module.storage")
```

## planned_values

The planned state after all changes are applied:

```json
{
  "planned_values": {
    "root_module": {
      "resources": [
        {
          "address": "aws_s3_bucket.example",
          "type": "aws_s3_bucket",
          "name": "example",
          "values": {
            "bucket": "my-bucket",
            "acl": "private"
          }
        }
      ],
      "child_modules": [
        {
          "address": "module.storage",
          "resources": [ /* module resources */ ],
          "child_modules": [ /* nested modules */ ]
        }
      ]
    }
  }
}
```

### Recursive Module Access

```rego
# Flatten all resources from all modules
all_resources contains resource if {
    some resource in input.planned_values.root_module.resources
}

all_resources contains resource if {
    some module in input.planned_values.root_module.child_modules
    some resource in module.resources
}

# Recursive for deeply nested modules
all_resources contains resource if {
    walk(input.planned_values.root_module, [path, value])
    value.resources
    some resource in value.resources
}
```

## configuration

The HCL configuration tree (useful for checking provider config):

```json
{
  "configuration": {
    "provider_config": {
      "aws": {
        "name": "aws",
        "expressions": {
          "region": {"constant_value": "us-east-1"}
        }
      }
    },
    "root_module": {
      "resources": [
        {
          "address": "aws_s3_bucket.example",
          "expressions": {
            "bucket": {"constant_value": "my-bucket"}
          }
        }
      ]
    }
  }
}
```

## Common Policy Patterns

### Check Resource Existence

```rego
# Ensure a resource type exists
deny contains msg if {
    resource_types := {rc.type | some rc in input.resource_changes}
    not "aws_cloudtrail" in resource_types
    msg := "CloudTrail must be configured"
}
```

### Cross-Resource Validation

```rego
# Ensure every S3 bucket has an encryption config
deny contains msg if {
    some rc in input.resource_changes
    rc.type == "aws_s3_bucket"
    "create" in rc.change.actions

    # Check for corresponding encryption config
    not _has_encryption_config(rc.address)
    msg := sprintf("S3 bucket '%s' has no encryption configuration resource", [rc.address])
}

_has_encryption_config(bucket_address) if {
    some rc in input.resource_changes
    rc.type == "aws_s3_bucket_server_side_encryption_configuration"
    contains(rc.address, split(bucket_address, ".")[1])
}
```

### Tag Enforcement

```rego
required_tags := {"Environment", "Team", "CostCenter"}

deny contains msg if {
    some rc in input.resource_changes
    "create" in rc.change.actions
    rc.type in taggable_resources
    provided := {k | some k, _ in object.get(rc.change.after, "tags", {})}
    missing := required_tags - provided
    count(missing) > 0
    msg := sprintf("resource '%s' missing required tags: %v", [rc.address, missing])
}

taggable_resources := {
    "aws_s3_bucket",
    "aws_instance",
    "aws_rds_instance",
    "aws_security_group",
    "aws_vpc"
}
```
