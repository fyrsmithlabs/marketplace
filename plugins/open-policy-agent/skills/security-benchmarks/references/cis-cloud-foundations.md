# CIS Cloud Foundations Benchmarks

Resource-level CIS control mappings for AWS, Azure, and GCP Terraform policies.

## CIS AWS Foundations Benchmark v3.0

### Section 1: Identity and Access Management

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 1.4 | Ensure no root account access key exists | 1 | `aws_iam_access_key` | Deny keys for root account |
| 1.5 | Ensure MFA is enabled for root account | 1 | N/A (account-level) | Audit check only |
| 1.14 | Ensure access keys are rotated every 90 days | 1 | `aws_iam_access_key` | Check `create_date` age |
| 1.16 | Ensure IAM policies are attached only to groups/roles | 1 | `aws_iam_user_policy` | Deny user-attached policies |
| 1.22 | Ensure IAM policies with full "*:*" admin are not attached | 1 | `aws_iam_policy` | Deny `*` Action + `*` Resource |

### Section 2: Storage

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 2.1.1 | Ensure S3 bucket encryption is enabled | 1 | `aws_s3_bucket` | Require `server_side_encryption_configuration` |
| 2.1.2 | Ensure S3 bucket policy denies HTTP | 1 | `aws_s3_bucket_policy` | Require `aws:SecureTransport` condition |
| 2.1.4 | Ensure S3 buckets have versioning enabled | 1 | `aws_s3_bucket_versioning` | Require `status: "Enabled"` |
| 2.1.5 | Ensure S3 bucket logging is enabled | 1 | `aws_s3_bucket_logging` | Require logging configuration |
| 2.2.1 | Ensure EBS volume encryption is enabled | 1 | `aws_ebs_volume` | Require `encrypted: true` |
| 2.3.1 | Ensure RDS instance encryption is enabled | 1 | `aws_db_instance` | Require `storage_encrypted: true` |
| 2.3.2 | Ensure RDS auto minor version upgrade is enabled | 1 | `aws_db_instance` | Require `auto_minor_version_upgrade: true` |
| 2.3.3 | Ensure RDS instances are not public | 1 | `aws_db_instance` | Require `publicly_accessible: false` |

### Section 3: Logging

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 3.1 | Ensure CloudTrail is enabled in all regions | 1 | `aws_cloudtrail` | Require `is_multi_region_trail: true` |
| 3.2 | Ensure CloudTrail log file validation is enabled | 1 | `aws_cloudtrail` | Require `enable_log_file_validation: true` |
| 3.4 | Ensure CloudTrail trails are integrated with CloudWatch | 1 | `aws_cloudtrail` | Require `cloud_watch_logs_group_arn` |
| 3.7 | Ensure CloudTrail logs are encrypted with KMS | 1 | `aws_cloudtrail` | Require `kms_key_id` |

### Section 4: Networking

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 4.1 | Ensure no SG allows ingress from 0.0.0.0/0 to port 22 | 1 | `aws_security_group` | Deny `0.0.0.0/0` on port 22 |
| 4.2 | Ensure no SG allows ingress from 0.0.0.0/0 to port 3389 | 1 | `aws_security_group` | Deny `0.0.0.0/0` on port 3389 |
| 4.3 | Ensure default SG restricts all traffic | 1 | `aws_default_security_group` | Deny any ingress/egress rules |

### Section 5: Monitoring

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 5.1 | Ensure VPC flow logging is enabled | 2 | `aws_flow_log` | Require for all VPCs |

---

## CIS Azure Foundations Benchmark v2.1

### Section 3: Storage Accounts

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 3.1 | Ensure secure transfer required | 1 | `azurerm_storage_account` | Require `enable_https_traffic_only: true` |
| 3.2 | Ensure storage account access keys are rotated | 1 | N/A | Audit check |
| 3.7 | Ensure public access is disabled | 1 | `azurerm_storage_account` | Require `allow_blob_public_access: false` |
| 3.9 | Ensure minimum TLS version is set to 1.2 | 1 | `azurerm_storage_account` | Require `min_tls_version: "TLS1_2"` |

### Section 4: Database Services

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 4.1.1 | Ensure SQL auditing is enabled | 1 | `azurerm_mssql_server` | Require audit policy |
| 4.1.2 | Ensure SQL threat detection is enabled | 1 | `azurerm_mssql_server` | Require threat detection |
| 4.3.1 | Ensure TLS version is 1.2+ | 1 | `azurerm_mssql_server` | Require `minimum_tls_version: "1.2"` |

### Section 7: Virtual Machines

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 7.1 | Ensure VM disks are encrypted | 1 | `azurerm_managed_disk` | Require `encryption_settings` |
| 7.4 | Ensure only approved extensions are installed | 1 | `azurerm_virtual_machine_extension` | Allowlist extensions |

### Section 8: Key Vault

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 8.1 | Ensure Key Vault is recoverable | 1 | `azurerm_key_vault` | Require `purge_protection_enabled: true` |
| 8.2 | Ensure private endpoint is configured | 2 | `azurerm_key_vault` | Require private endpoint |

---

## CIS GCP Foundations Benchmark v2.0

### Section 3: Networking

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 3.1 | Ensure default network does not exist | 2 | `google_compute_network` | Deny name "default" |
| 3.6 | Ensure SSH is restricted from internet | 2 | `google_compute_firewall` | Deny `0.0.0.0/0` on port 22 |
| 3.7 | Ensure RDP is restricted from internet | 2 | `google_compute_firewall` | Deny `0.0.0.0/0` on port 3389 |

### Section 4: Database

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 4.1 | Ensure Cloud SQL requires SSL | 1 | `google_sql_database_instance` | Require `require_ssl: true` |
| 4.4 | Ensure Cloud SQL is not public | 1 | `google_sql_database_instance` | Deny `0.0.0.0/0` in authorized networks |

### Section 5: Storage

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 5.1 | Ensure uniform bucket-level access | 2 | `google_storage_bucket` | Require `uniform_bucket_level_access: true` |
| 5.2 | Ensure Cloud Storage is not anonymously accessible | 1 | `google_storage_bucket_iam_member` | Deny `allUsers`/`allAuthenticatedUsers` |

### Section 6: Compute

| CIS ID | Title | Level | Resource | Rego Check |
|--------|-------|-------|----------|-----------|
| 6.1.1 | Ensure VM disks are encrypted with CSEK | 2 | `google_compute_instance` | Require `disk.disk_encryption_key` |
| 6.2.1 | Ensure Cloud SQL automated backups | 1 | `google_sql_database_instance` | Require `backup_configuration.enabled: true` |
| 6.3.1 | Ensure Compute instances do not use default service account | 1 | `google_compute_instance` | Deny `default` service account |
