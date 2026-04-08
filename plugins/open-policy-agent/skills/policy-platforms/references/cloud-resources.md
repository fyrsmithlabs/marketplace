# Cloud Resource Security Properties

Comprehensive reference for cloud resource types and their security-relevant properties, used when writing Terraform OPA policies.

## AWS Resources

### Compute

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `aws_instance` | `metadata_options.http_tokens`, `monitoring`, `ebs_block_device.encrypted` | IMDSv1 enabled, no monitoring, unencrypted EBS |
| `aws_launch_template` | `metadata_options.http_tokens`, `monitoring.enabled` | IMDSv1 enabled |
| `aws_autoscaling_group` | `launch_template`, `min_size` | Missing launch template |

### Storage

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `aws_s3_bucket` | `server_side_encryption_configuration`, `versioning`, `logging` | No SSE, no versioning |
| `aws_s3_bucket_public_access_block` | `block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets` | Any set to false |
| `aws_ebs_volume` | `encrypted`, `kms_key_id` | `encrypted: false` |
| `aws_efs_file_system` | `encrypted`, `kms_key_id` | `encrypted: false` |

### Database

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `aws_db_instance` | `storage_encrypted`, `backup_retention_period`, `deletion_protection`, `publicly_accessible`, `auto_minor_version_upgrade` | Unencrypted, public, no backups |
| `aws_rds_cluster` | `storage_encrypted`, `backup_retention_period`, `deletion_protection` | Unencrypted, no backups |
| `aws_dynamodb_table` | `server_side_encryption.enabled`, `point_in_time_recovery.enabled` | No SSE, no PITR |

### Networking

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `aws_security_group` | `ingress[].cidr_blocks`, `ingress[].from_port`, `ingress[].to_port` | `0.0.0.0/0` on ports 22, 3389, or all |
| `aws_lb` | `internal`, `drop_invalid_header_fields` | Public-facing without justification |
| `aws_vpc` | `enable_dns_hostnames`, `enable_dns_support` | Missing flow logs |
| `aws_flow_log` | `traffic_type`, `log_destination` | Not present for VPC |

### IAM

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `aws_iam_policy` | `policy` (JSON document) | `"Action": "*"` with `"Resource": "*"` |
| `aws_iam_user_policy` | existence | Any (prefer group/role policies) |
| `aws_iam_role` | `assume_role_policy` | Overly permissive trust policy |

### Monitoring

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `aws_cloudtrail` | `is_multi_region_trail`, `enable_log_file_validation`, `kms_key_id`, `cloud_watch_logs_group_arn` | Single-region, no validation, no KMS |
| `aws_cloudwatch_log_group` | `retention_in_days`, `kms_key_id` | No retention, no encryption |

---

## Azure Resources

### Compute

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `azurerm_linux_virtual_machine` | `admin_ssh_key`, `disable_password_authentication` | Password auth enabled |
| `azurerm_managed_disk` | `encryption_settings`, `disk_encryption_set_id` | No encryption |

### Storage

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `azurerm_storage_account` | `enable_https_traffic_only`, `min_tls_version`, `allow_blob_public_access`, `network_rules` | HTTP allowed, TLS < 1.2, public access |
| `azurerm_storage_container` | `container_access_type` | Not `"private"` |

### Database

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `azurerm_mssql_server` | `minimum_tls_version`, `public_network_access_enabled` | TLS < 1.2, public access |
| `azurerm_postgresql_server` | `ssl_enforcement_enabled`, `public_network_access_enabled` | SSL not enforced, public |
| `azurerm_cosmosdb_account` | `is_virtual_network_filter_enabled`, `public_network_access_enabled` | No VNet filter, public |

### Networking

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `azurerm_network_security_group` | `security_rule[].source_address_prefix` | `*` or `Internet` on sensitive ports |
| `azurerm_network_watcher` | existence per region | Missing for any region |

### Key Management

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `azurerm_key_vault` | `purge_protection_enabled`, `soft_delete_retention_days`, `network_acls` | No purge protection, short retention |

---

## GCP Resources

### Compute

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `google_compute_instance` | `service_account.email`, `metadata.block-project-ssh-keys`, `shielded_instance_config` | Default service account, project-wide SSH |
| `google_compute_firewall` | `source_ranges`, `direction`, `allow[].ports` | `0.0.0.0/0` on SSH/RDP |

### Storage

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `google_storage_bucket` | `uniform_bucket_level_access`, `encryption.default_kms_key_name`, `versioning.enabled` | No uniform access, no versioning |
| `google_storage_bucket_iam_member` | `member` | `allUsers` or `allAuthenticatedUsers` |

### Database

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `google_sql_database_instance` | `settings.ip_configuration.require_ssl`, `settings.ip_configuration.authorized_networks`, `settings.backup_configuration.enabled` | SSL not required, `0.0.0.0/0` authorized, no backups |

### Networking

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `google_compute_network` | `name`, `auto_create_subnetworks` | Name is "default" |
| `google_compute_subnetwork` | `log_config` | Missing flow log config |

### IAM

| Resource | Security Properties | Deny Conditions |
|----------|-------------------|-----------------|
| `google_project_iam_member` | `role`, `member` | `roles/owner` or `roles/editor` on service accounts |
| `google_service_account_key` | existence | User-managed keys (prefer workload identity) |
