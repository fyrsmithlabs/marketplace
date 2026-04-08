# Policy Spec Examples

Complete example specs for common OPA policies.

---

## Example: Kubernetes Pod Security

```markdown
# SPEC: Pod Security Baseline

**Platform:** kubernetes
**Component:** pod-security
**Version:** 0.1.0
**Status:** approved
**Author:** fyrsmithlabs
**Date:** 2026-04-08

---

## Purpose

Enforce Kubernetes Pod Security Standards at the Baseline level, preventing the most dangerous container configurations that could lead to container escape or host compromise.

## Scope

**Applies to:**
- All Pods created via Deployments, StatefulSets, DaemonSets, Jobs, CronJobs
- All namespaces except kube-system

**Excludes:**
- kube-system namespace (system components may require privileged access)
- Pods with annotation `policy.fyrsmithlabs.com/exempt: "true"` (requires justification)

---

## Benchmark Alignment

### CIS Controls

| CIS ID | Title | Level | Enforcement |
|--------|-------|-------|-------------|
| 5.2.1 | Minimize admission of privileged containers | 1 | deny |
| 5.2.2 | Minimize admission of hostPID containers | 1 | deny |
| 5.2.3 | Minimize admission of hostIPC containers | 1 | deny |
| 5.2.4 | Minimize admission of hostNetwork containers | 1 | deny |
| 5.2.5 | Minimize allowPrivilegeEscalation | 1 | deny |
| 5.2.6 | Minimize admission of root containers | 1 | deny |
| 5.2.7 | Minimize NET_RAW capability | 1 | deny |
| 5.2.8 | Minimize added capabilities | 1 | deny |

### Compliance Frameworks

| Framework | Control | Description |
|-----------|---------|-------------|
| SOC2 | CC6.6 | Security against threats outside system boundaries |
| NIST 800-53 | AC-6 | Least privilege |
| NIST 800-53 | CM-7 | Least functionality |
| PCI-DSS | 2.2 | Configure system components securely |

@include controls.md

---

## Policy Rules

### DENY Rules

1. **deny-privileged**: Containers must not run in privileged mode
   - Input path: `input.review.object.spec.containers[_].securityContext.privileged`
   - Condition: `privileged == true`
   - Message: "container '%s' must not be privileged (CIS-5.2.1)"

2. **deny-host-pid**: Pods must not share host PID namespace
   - Input path: `input.review.object.spec.hostPID`
   - Condition: `hostPID == true`
   - Message: "pod must not use hostPID (CIS-5.2.2)"

3. **deny-host-ipc**: Pods must not share host IPC namespace
   - Input path: `input.review.object.spec.hostIPC`
   - Condition: `hostIPC == true`
   - Message: "pod must not use hostIPC (CIS-5.2.3)"

4. **deny-host-network**: Pods must not use host network
   - Input path: `input.review.object.spec.hostNetwork`
   - Condition: `hostNetwork == true`
   - Message: "pod must not use hostNetwork (CIS-5.2.4)"

5. **deny-privilege-escalation**: Containers must not allow privilege escalation
   - Input path: `input.review.object.spec.containers[_].securityContext.allowPrivilegeEscalation`
   - Condition: `allowPrivilegeEscalation != false` (must explicitly set to false)
   - Message: "container '%s' must set allowPrivilegeEscalation to false (CIS-5.2.5)"

6. **deny-run-as-root**: Containers must not run as root
   - Input path: `input.review.object.spec.securityContext.runAsNonRoot`
   - Condition: `runAsNonRoot != true`
   - Message: "pod must set runAsNonRoot to true (CIS-5.2.6)"

7. **deny-net-raw**: Containers must drop NET_RAW capability
   - Input path: `input.review.object.spec.containers[_].securityContext.capabilities`
   - Condition: Does not drop ALL or NET_RAW
   - Message: "container '%s' must drop NET_RAW capability (CIS-5.2.7)"

8. **deny-added-capabilities**: Containers must not add dangerous capabilities
   - Input path: `input.review.object.spec.containers[_].securityContext.capabilities.add`
   - Condition: Adds capabilities beyond allowed list (NET_BIND_SERVICE only)
   - Message: "container '%s' adds disallowed capability '%s' (CIS-5.2.8)"

### EXEMPT Conditions

1. **kube-system namespace**: System components exempt
   - Justification: Core K8s components require host access
2. **Exempt annotation**: Pods with `policy.fyrsmithlabs.com/exempt: "true"`
   - Justification: Documented exceptions for special workloads

---

## Input Schema

Gatekeeper AdmissionReview:
```json
{
  "review": {
    "object": {
      "metadata": {
        "namespace": "default",
        "annotations": {}
      },
      "spec": {
        "hostPID": false,
        "hostIPC": false,
        "hostNetwork": false,
        "securityContext": {
          "runAsNonRoot": true
        },
        "containers": [{
          "name": "app",
          "securityContext": {
            "privileged": false,
            "allowPrivilegeEscalation": false,
            "capabilities": {
              "drop": ["ALL"]
            }
          }
        }]
      }
    }
  }
}
```

---

## Test Cases

### Positive Tests (should pass)

| Test | Input Description | Expected |
|------|-------------------|----------|
| valid-pod | All security fields correctly set | 0 violations |
| valid-minimal | Only required fields, all secure | 0 violations |
| exempt-namespace | Pod in kube-system | 0 violations |
| exempt-annotation | Pod with exempt annotation | 0 violations |

### Negative Tests (should deny)

| Test | Input Description | Expected |
|------|-------------------|----------|
| privileged | Container with privileged: true | 1 violation containing "privileged" |
| host-pid | Pod with hostPID: true | 1 violation containing "hostPID" |
| host-ipc | Pod with hostIPC: true | 1 violation containing "hostIPC" |
| host-network | Pod with hostNetwork: true | 1 violation containing "hostNetwork" |
| priv-escalation | allowPrivilegeEscalation not false | 1 violation containing "allowPrivilegeEscalation" |
| run-as-root | runAsNonRoot not true | 1 violation containing "runAsNonRoot" |
| net-raw | Missing DROP NET_RAW | 1 violation containing "NET_RAW" |
| added-caps | Adds SYS_ADMIN capability | 1 violation containing "SYS_ADMIN" |
| multiple-violations | Multiple issues in one pod | 3+ violations |

### Edge Cases

| Test | Input Description | Expected |
|------|-------------------|----------|
| empty-containers | Pod with no containers | 0 violations |
| no-security-context | Container missing securityContext entirely | 1+ violations |
| init-containers | Init container with violations | 1+ violations |
| multiple-containers | Mix of valid and invalid containers | violations only for invalid |
```

---

## Example: AWS S3 Encryption (Terraform)

```markdown
# SPEC: S3 Bucket Encryption

**Platform:** terraform/aws
**Component:** s3-encryption
**Version:** 0.1.0
**Status:** draft
**Author:** fyrsmithlabs
**Date:** 2026-04-08

---

## Purpose

Ensure all AWS S3 buckets have server-side encryption enabled, public access blocked, and access logging configured.

## Scope

**Applies to:**
- `aws_s3_bucket` resources in Terraform plans
- `aws_s3_bucket_server_side_encryption_configuration` resources
- `aws_s3_bucket_public_access_block` resources

---

## Benchmark Alignment

### CIS Controls

| CIS ID | Title | Level | Enforcement |
|--------|-------|-------|-------------|
| 2.1.1 | Ensure S3 bucket encryption is enabled | 1 | deny |
| 2.1.2 | Ensure S3 bucket policy denies HTTP requests | 1 | deny |
| 2.1.5 | Ensure S3 bucket access logging is enabled | 1 | warn |

### Compliance Frameworks

| Framework | Control | Description |
|-----------|---------|-------------|
| SOC2 | CC6.1 | Logical access security |
| SOC2 | CC6.7 | Restrict data transmission |
| NIST 800-53 | SC-28 | Protection of information at rest |
| NIST 800-53 | SC-8 | Transmission confidentiality |
| PCI-DSS | 3.4 | Render PAN unreadable |
| HIPAA | 164.312(a)(2)(iv) | Encryption and decryption |

---

## Policy Rules

### DENY Rules

1. **deny-no-encryption**: S3 buckets must have SSE configured
   - Resource: `aws_s3_bucket`
   - Condition: Missing `server_side_encryption_configuration`
   - Message: "S3 bucket '%s' must have encryption enabled (CIS-2.1.1)"

2. **deny-public-acl**: S3 buckets must not be public
   - Resource: `aws_s3_bucket`
   - Condition: `acl` in ["public-read", "public-read-write"]
   - Message: "S3 bucket '%s' must not be public (CIS-2.1.2)"

### WARN Rules

1. **warn-no-logging**: S3 buckets should have access logging
   - Resource: `aws_s3_bucket`
   - Condition: No corresponding `aws_s3_bucket_logging` resource
   - Message: "S3 bucket '%s' should have access logging enabled (CIS-2.1.5)"

---

## Test Cases

### Positive Tests

| Test | Input Description | Expected |
|------|-------------------|----------|
| encrypted-bucket | Bucket with SSE-S3 encryption | 0 deny violations |
| kms-encrypted | Bucket with SSE-KMS encryption | 0 deny violations |
| private-bucket | Bucket with private ACL | 0 deny violations |

### Negative Tests

| Test | Input Description | Expected |
|------|-------------------|----------|
| no-encryption | Bucket without SSE config | 1 deny containing "encryption" |
| public-read | Bucket with public-read ACL | 1 deny containing "public" |
| public-read-write | Bucket with public-read-write | 1 deny containing "public" |

### Edge Cases

| Test | Input Description | Expected |
|------|-------------------|----------|
| bucket-update | Existing bucket being modified | Check after state |
| bucket-delete | Bucket being deleted | 0 violations (no enforcement on delete) |
```
