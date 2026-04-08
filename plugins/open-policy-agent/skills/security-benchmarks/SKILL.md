---
name: security-benchmarks
description: This skill should be used when the user asks about "cis benchmark", "cis kubernetes", "cis docker", "cis aws", "cis azure", "cis gcp", "soc2 rego", "soc2 policy", "hipaa compliance", "pci-dss", "nist 800-53", "iso 27001", "compliance rego", "security controls", "benchmark alignment", or mentions mapping OPA policies to compliance frameworks. Provides CIS benchmark control mappings and compliance framework references for OPA/Rego policies.
---

# Security Benchmarks

Reference for mapping OPA/Rego policies to CIS benchmarks, SOC 2, HIPAA, PCI-DSS, NIST 800-53, and other compliance frameworks. Use when writing benchmark-aligned policies or creating policy specs.

**CRITICAL: Benchmark ID Accuracy**
- **ONLY cite control IDs that appear in this skill's tables or in `references/compliance-matrix.md`.** Do not generate plausible-looking IDs from general knowledge.
- If a user requests controls for a platform/framework not covered in these references, explicitly state: "The following IDs are from general knowledge and have not been verified against the authoritative benchmark document."
- **Never fabricate CIS IDs.** This skill covers a subset of each benchmark. If controls beyond this subset are needed, recommend consulting the full CIS benchmark document.
- **HIPAA and ISO 27001 coverage is partial.** Do not claim comprehensive coverage. State limitations transparently.

## Benchmark Ecosystem Overview

| Framework | Type | Rego Coverage | Primary Tools |
|-----------|------|---------------|---------------|
| CIS Benchmarks | Technical controls | Strong | Terrascan, Trivy, Kubescape, Regula |
| SOC 2 Type II | Trust principles | Partial | Kubescape, Terrascan |
| HIPAA | Healthcare data | Partial | Cloud IaC rules, custom Rego |
| PCI-DSS 4.0 | Payment card data | Partial | Terrascan |
| NIST 800-53 | Federal security | Growing | OSCAL C2P, Terrascan |
| ISO 27001 | InfoSec management | Minimal | Custom Rego required |

---

## CIS Kubernetes Benchmark

### Key Controls for OPA/Gatekeeper

| CIS ID | Title | Rego Enforcement |
|--------|-------|-----------------|
| 5.2.1 | Minimize admission of privileged containers | Deny `securityContext.privileged: true` |
| 5.2.2 | Minimize admission of containers wishing to share host PID | Deny `hostPID: true` |
| 5.2.3 | Minimize admission of containers wishing to share host IPC | Deny `hostIPC: true` |
| 5.2.4 | Minimize admission of containers wishing to share host network | Deny `hostNetwork: true` |
| 5.2.5 | Minimize admission of containers with allowPrivilegeEscalation | Deny unless `allowPrivilegeEscalation: false` |
| 5.2.6 | Minimize admission of root containers | Require `runAsNonRoot: true` |
| 5.2.7 | Minimize admission with NET_RAW capability | Require `drop: ["ALL"]` or `drop: ["NET_RAW"]` |
| 5.2.8 | Minimize admission with added capabilities | Deny capabilities beyond allowed list |
| 5.2.9 | Minimize admission of containers with assigned SELinux | Restrict SELinux options |
| 5.4.1 | Prefer using secrets as files over env vars | Warn on `envFrom.secretRef` |
| 5.7.1 | Create administrative boundaries between resources | Require namespace labels |
| 5.7.2 | Ensure that the seccomp profile is set | Require seccomp annotation/field |
| 5.7.3 | Apply security context to pods and containers | Require securityContext on all pods |

### Pod Security Standards Mapping

| PSS Level | CIS Controls | Rego Focus |
|-----------|-------------|------------|
| **Privileged** | None | No restrictions |
| **Baseline** | 5.2.1-5.2.4, 5.2.8 | Deny dangerous capabilities |
| **Restricted** | 5.2.1-5.2.9, 5.7.2-5.7.3 | Full security context enforcement |

---

## CIS Docker Benchmark (Section 4: Container Images)

| CIS ID | Title | Rego Check |
|--------|-------|-----------|
| 4.1 | Ensure a user for the container has been created | Require `USER` instruction |
| 4.2 | Ensure containers use trusted base images | Allowlist registries |
| 4.3 | Ensure unnecessary packages are not installed | Warn on `apt-get install` without `--no-install-recommends` |
| 4.6 | Ensure HEALTHCHECK instructions have been added | Require `HEALTHCHECK` |
| 4.7 | Ensure update instructions are not used alone | Deny `apt-get update` without `apt-get install` in same RUN |
| 4.9 | Ensure COPY is used instead of ADD | Deny `ADD` except for archives |
| 4.10 | Ensure secrets are not stored in Dockerfiles | Deny ENV with secret-like patterns |

---

## CIS AWS Foundations Benchmark

### Key Controls for Terraform Policies

| CIS ID | Title | Resource Type | Rego Check |
|--------|-------|--------------|-----------|
| 1.4 | Ensure no root account access key | `aws_iam_access_key` | Deny root access keys |
| 1.16 | Ensure IAM policies not attached to users | `aws_iam_user_policy` | Deny direct user policies |
| 2.1.1 | Ensure S3 bucket encryption | `aws_s3_bucket` | Require SSE configuration |
| 2.1.2 | Ensure S3 bucket policy denies HTTP | `aws_s3_bucket_policy` | Require `aws:SecureTransport` |
| 2.1.5 | Ensure S3 bucket access logging | `aws_s3_bucket_logging` | Require logging config |
| 2.2.1 | Ensure EBS encryption by default | `aws_ebs_volume` | Require `encrypted: true` |
| 2.3.1 | Ensure RDS encryption | `aws_rds_instance` | Require `storage_encrypted: true` |
| 3.1 | Ensure CloudTrail enabled all regions | `aws_cloudtrail` | Require `is_multi_region_trail` |
| 4.1 | Ensure no SG allows ingress 0.0.0.0/0 to port 22 | `aws_security_group` | Deny `0.0.0.0/0` on port 22 |
| 4.2 | Ensure no SG allows ingress 0.0.0.0/0 to port 3389 | `aws_security_group` | Deny `0.0.0.0/0` on port 3389 |
| 5.1 | Ensure VPC flow logging | `aws_flow_log` | Require for all VPCs |

---

## CIS Azure Foundations Benchmark

| CIS ID | Title | Rego Check |
|--------|-------|-----------|
| 3.1 | Ensure secure transfer required for storage | Require `enable_https_traffic_only` |
| 3.9 | Ensure storage account access keys rotated | Warn on long-lived keys |
| 4.1.1 | Ensure SQL auditing is enabled | Require audit policy |
| 4.3.1 | Ensure TLS 1.2+ for SQL | Require `minimum_tls_version: "1.2"` |
| 6.1 | Ensure Network Watcher is enabled | Require per region |
| 7.1 | Ensure VM disks are encrypted | Require disk encryption |
| 8.1 | Ensure Key Vault is recoverable | Require `purge_protection_enabled` |

---

## CIS GCP Foundations Benchmark

| CIS ID | Title | Rego Check |
|--------|-------|-----------|
| 1.1 | Ensure MFA/2SV is enforced | Organization policy check |
| 3.1 | Ensure default network does not exist | Deny `google_compute_network` named "default" |
| 4.1 | Ensure Cloud SQL requires SSL | Require `require_ssl: true` |
| 5.1 | Ensure Cloud Storage uniform access | Require `uniform_bucket_level_access` |
| 6.1.1 | Ensure VM disks are encrypted with CSEK | Require `disk_encryption_key` |
| 6.2.1 | Ensure Cloud SQL automated backups | Require `backup_configuration.enabled` |

---

## SOC 2 Type II Control Mapping

SOC 2 maps to Trust Service Criteria (TSC). Rego enforcement focuses on the technical controls that support each category.

| TSC Category | Control Area | Rego Enforcement Examples |
|-------------|-------------|--------------------------|
| **CC6.1** | Logical access security | RBAC policies, network segmentation, auth requirements |
| **CC6.2** | System credentials | Deny hardcoded secrets, require rotation |
| **CC6.3** | Access authorization | Role-based deny rules, least privilege enforcement |
| **CC6.6** | Security against threats | Pod security, container isolation, network policies |
| **CC6.7** | Restrict data transmission | Require TLS, deny unencrypted protocols |
| **CC6.8** | Prevent/detect unauthorized software | Image allowlists, signed images |
| **CC7.1** | Detect configuration changes | Audit logging requirements |
| **CC7.2** | Monitor for anomalies | Logging and monitoring enforcement |
| **CC8.1** | Manage change process | Immutable infrastructure, deployment gates |

---

## NIST 800-53 Control Families

| Family | ID | Rego Enforcement Focus |
|--------|----|----------------------|
| **Access Control** | AC-2, AC-6 | RBAC, least privilege, no wildcard perms |
| **Audit** | AU-2, AU-3 | Logging enabled, audit trails |
| **Config Management** | CM-2, CM-7 | Baseline configs, minimize functionality |
| **Identification** | IA-2, IA-5 | MFA, credential management |
| **System Protection** | SC-7, SC-8, SC-28 | Network boundaries, encryption in transit/at rest |
| **System Integrity** | SI-2, SI-3 | Patch management, malware protection |

### OSCAL to OPA Pipeline

The NIST OSCAL Compass C2P (Compliance-to-Policy) project generates OPA bundles from OSCAL assessment plans:

```
OSCAL Assessment Plan -> C2P -> OPA Rego Bundle -> Policy Evaluation -> OSCAL Assessment Results
```

---

## PCI-DSS 4.0 Key Controls

| Requirement | Rego Enforcement |
|-------------|-----------------|
| 1.3 | Network access restricted (security group rules) |
| 2.2 | System components configured securely (baseline enforcement) |
| 3.4 | PAN data encrypted at rest (storage encryption) |
| 4.1 | Strong cryptography for transmission (TLS requirements) |
| 6.3 | Security vulnerabilities identified and managed (image scanning) |
| 7.1 | Access limited by need to know (RBAC, least privilege) |
| 8.3 | Authentication mechanisms (MFA, credential policies) |
| 10.2 | Audit log coverage (logging requirements) |

---

## Using Benchmarks in Policy Specs

When creating a policy spec, include benchmark alignment:

```markdown
## Benchmark Alignment

### CIS Controls
- **CIS-K8s-5.2.1**: Minimize admission of privileged containers (Level 1)
- **CIS-K8s-5.2.6**: Minimize admission of root containers (Level 1)

### Compliance Frameworks
- **SOC2 CC6.6**: Security against threats outside system boundaries
- **NIST AC-6**: Least privilege
- **PCI-DSS 2.2**: Configure system components securely
```

Use the `# METADATA` annotation in Rego to embed benchmark references:

```rego
# METADATA
# title: Deny privileged containers
# custom:
#   benchmarks:
#     cis_kubernetes: ["5.2.1"]
#     soc2: ["CC6.6"]
#     nist_800_53: ["AC-6"]
#     pci_dss: ["2.2"]
#   severity: high
```

---

## Additional Resources

### Reference Files

- **`references/cis-kubernetes-full.md`** - Complete CIS Kubernetes Benchmark control mappings with Rego examples
- **`references/cis-cloud-foundations.md`** - AWS, Azure, GCP CIS Foundations with resource-level detail
- **`references/compliance-matrix.md`** - Cross-framework mapping: CIS -> SOC2 -> NIST -> PCI-DSS -> HIPAA
