# Cross-Framework Compliance Matrix

Maps CIS benchmark controls to SOC 2, NIST 800-53, PCI-DSS, and HIPAA for common infrastructure security requirements.

## Encryption at Rest

| CIS Control | SOC 2 | NIST 800-53 | PCI-DSS 4.0 | HIPAA |
|-------------|-------|-------------|-------------|-------|
| CIS-AWS-2.1.1 (S3 SSE) | CC6.1, CC6.7 | SC-28 | 3.4 | 164.312(a)(2)(iv) |
| CIS-AWS-2.2.1 (EBS encryption) | CC6.1 | SC-28 | 3.4 | 164.312(a)(2)(iv) |
| CIS-AWS-2.3.1 (RDS encryption) | CC6.1 | SC-28 | 3.4 | 164.312(a)(2)(iv) |
| CIS-Azure-7.1 (VM disk encryption) | CC6.1 | SC-28 | 3.4 | 164.312(a)(2)(iv) |
| CIS-GCP-6.1.1 (VM disk CSEK) | CC6.1 | SC-28 | 3.4 | 164.312(a)(2)(iv) |

## Encryption in Transit

| CIS Control | SOC 2 | NIST 800-53 | PCI-DSS 4.0 | HIPAA |
|-------------|-------|-------------|-------------|-------|
| CIS-AWS-2.1.2 (S3 deny HTTP) | CC6.7 | SC-8 | 4.1 | 164.312(e)(1) |
| CIS-Azure-3.1 (storage HTTPS) | CC6.7 | SC-8 | 4.1 | 164.312(e)(1) |
| CIS-Azure-4.3.1 (SQL TLS 1.2) | CC6.7 | SC-8 | 4.1 | 164.312(e)(1) |
| CIS-GCP-4.1 (Cloud SQL SSL) | CC6.7 | SC-8 | 4.1 | 164.312(e)(1) |

## Network Security

| CIS Control | SOC 2 | NIST 800-53 | PCI-DSS 4.0 | HIPAA |
|-------------|-------|-------------|-------------|-------|
| CIS-AWS-4.1 (no SSH 0.0.0.0/0) | CC6.1, CC6.6 | SC-7 | 1.3 | 164.312(e)(1) |
| CIS-AWS-4.2 (no RDP 0.0.0.0/0) | CC6.1, CC6.6 | SC-7 | 1.3 | 164.312(e)(1) |
| CIS-AWS-5.1 (VPC flow logs) | CC7.1, CC7.2 | AU-2 | 10.2 | 164.312(b) |
| CIS-GCP-3.1 (no default network) | CC6.1 | SC-7 | 1.3 | 164.312(e)(1) |

## Identity and Access Management

| CIS Control | SOC 2 | NIST 800-53 | PCI-DSS 4.0 | HIPAA |
|-------------|-------|-------------|-------------|-------|
| CIS-AWS-1.4 (no root access key) | CC6.1, CC6.2 | AC-2, AC-6 | 7.1, 8.3 | 164.312(a)(1) |
| CIS-AWS-1.16 (no user policies) | CC6.3 | AC-6 | 7.1 | 164.312(a)(1) |
| CIS-K8s-5.2.6 (runAsNonRoot) | CC6.1, CC6.6 | AC-6 | 7.1 | 164.312(a)(1) |

## Container Security

| CIS Control | SOC 2 | NIST 800-53 | PCI-DSS 4.0 | HIPAA |
|-------------|-------|-------------|-------------|-------|
| CIS-K8s-5.2.1 (no privileged) | CC6.6 | CM-7 | 2.2 | 164.312(a)(1) |
| CIS-K8s-5.2.5 (no privEscalation) | CC6.6 | AC-6 | 2.2 | 164.312(a)(1) |
| CIS-K8s-5.2.7 (drop NET_RAW) | CC6.6 | CM-7 | 2.2 | 164.312(a)(1) |
| CIS-K8s-5.2.8 (restrict caps) | CC6.6 | CM-7 | 2.2 | 164.312(a)(1) |
| CIS-K8s-5.7.2 (seccomp profile) | CC6.6 | CM-7 | 2.2 | 164.312(a)(1) |
| CIS-Docker-4.1 (USER instruction) | CC6.6 | AC-6 | 2.2 | 164.312(a)(1) |
| CIS-Docker-4.2 (trusted base) | CC6.8 | CM-7 | 6.3 | 164.312(a)(1) |

## Audit and Logging

| CIS Control | SOC 2 | NIST 800-53 | PCI-DSS 4.0 | HIPAA |
|-------------|-------|-------------|-------------|-------|
| CIS-AWS-3.1 (CloudTrail all regions) | CC7.1, CC7.2 | AU-2, AU-3 | 10.2 | 164.312(b) |
| CIS-Azure-6.1 (Network Watcher) | CC7.1 | AU-2 | 10.2 | 164.312(b) |

## Key Management

| CIS Control | SOC 2 | NIST 800-53 | PCI-DSS 4.0 | HIPAA |
|-------------|-------|-------------|-------------|-------|
| CIS-Azure-8.1 (Key Vault recoverable) | CC6.1 | SC-12 | 3.5 | 164.312(a)(2)(iv) |

## Data Protection (HIPAA-Specific)

| HIPAA Safeguard | Description | OPA Enforcement |
|-----------------|-------------|-----------------|
| 164.312(a)(1) | Access control | RBAC, least privilege policies |
| 164.312(a)(2)(iv) | Encryption/decryption | Encryption at rest requirements |
| 164.312(b) | Audit controls | Logging and monitoring enforcement |
| 164.312(c)(1) | Integrity | Immutable infrastructure, signed images |
| 164.312(e)(1) | Transmission security | TLS requirements, deny HTTP |

---

## SOC 2 Trust Service Criteria Detail

### CC6: Logical and Physical Access Controls

| CC ID | Description | OPA Implementation |
|-------|-------------|-------------------|
| CC6.1 | Security over logical access | RBAC deny rules, network segmentation, authentication requirements |
| CC6.2 | System credential management | Deny hardcoded secrets, require credential rotation |
| CC6.3 | Access authorization | Role-based access, least privilege enforcement |
| CC6.6 | Security against threats | Pod security, container isolation, network policies |
| CC6.7 | Data transmission restrictions | Require TLS, deny unencrypted protocols |
| CC6.8 | Unauthorized software prevention | Image allowlists, signed image requirements |

### CC7: System Operations

| CC ID | Description | OPA Implementation |
|-------|-------------|-------------------|
| CC7.1 | Configuration change detection | Audit logging requirements, decision logs |
| CC7.2 | Anomaly monitoring | Logging enforcement, monitoring requirements |

### CC8: Change Management

| CC ID | Description | OPA Implementation |
|-------|-------------|-------------------|
| CC8.1 | Change management process | Immutable infrastructure, deployment gates, policy CI/CD |

---

## NIST 800-53 Control Families Detail

### AC - Access Control

| Control | Title | OPA Focus |
|---------|-------|-----------|
| AC-2 | Account Management | Service account restrictions, RBAC |
| AC-3 | Access Enforcement | Authorization policies, deny rules |
| AC-6 | Least Privilege | Minimal permissions, no wildcard actions |
| AC-17 | Remote Access | Network policies, VPN requirements |

### AU - Audit and Accountability

| Control | Title | OPA Focus |
|---------|-------|-----------|
| AU-2 | Event Logging | Require audit logging configurations |
| AU-3 | Content of Audit Records | Log format and detail requirements |
| AU-6 | Audit Review | Decision log configuration |

### CM - Configuration Management

| Control | Title | OPA Focus |
|---------|-------|-----------|
| CM-2 | Baseline Configuration | Enforce standard configurations |
| CM-7 | Least Functionality | Minimize capabilities, remove unnecessary services |
| CM-8 | Component Inventory | Resource tagging requirements |

### SC - System and Communications Protection

| Control | Title | OPA Focus |
|---------|-------|-----------|
| SC-7 | Boundary Protection | Network segmentation, firewall rules |
| SC-8 | Transmission Confidentiality | TLS requirements |
| SC-12 | Cryptographic Key Management | Key Vault/KMS requirements |
| SC-28 | Protection of Information at Rest | Encryption at rest |

### SI - System and Information Integrity

| Control | Title | OPA Focus |
|---------|-------|-----------|
| SI-2 | Flaw Remediation | Image scanning, patch requirements |
| SI-3 | Malicious Code Protection | Trusted image registries |
