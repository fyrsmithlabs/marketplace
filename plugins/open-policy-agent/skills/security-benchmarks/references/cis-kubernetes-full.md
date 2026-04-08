# CIS Kubernetes Benchmark - Full Control Mappings

Comprehensive CIS Kubernetes Benchmark v1.8+ control mappings with Rego enforcement examples.

## Section 5.2: Pod Security Standards

### 5.2.1 Minimize admission of privileged containers (Level 1)

**Description:** Do not generally permit containers to be run with the `privileged` flag set to true.
**Rationale:** Privileged containers have almost all capabilities of the host machine. Running in privileged mode disables most security mechanisms and grants access to host devices.
**Audit:** Check for `securityContext.privileged: true` on all containers.

```rego
# METADATA
# title: CIS-5.2.1 Deny privileged containers
# custom:
#   severity: critical
#   benchmarks:
#     cis_kubernetes: ["5.2.1"]
violation contains {"msg": msg} if {
    some c in input.review.object.spec.containers
    sc := object.get(c, "securityContext", {})
    object.get(sc, "privileged", false) == true
    msg := sprintf("CIS-5.2.1: container '%s' must not be privileged", [c.name])
}
```

### 5.2.2 Minimize admission of containers wishing to share host PID (Level 1)

**Description:** Do not generally permit containers to share the host process ID namespace.
**Rationale:** A container running in the host PID namespace can inspect processes on the host and could potentially use `ptrace` on other host processes.

```rego
violation contains {"msg": msg} if {
    input.review.object.spec.hostPID == true
    msg := "CIS-5.2.2: pod must not use hostPID"
}
```

### 5.2.3 Minimize admission of containers wishing to share host IPC (Level 1)

**Description:** Do not generally permit containers to share the host IPC namespace.
**Rationale:** Shared IPC namespace allows processes in the pod to communicate with host processes using IPC.

```rego
violation contains {"msg": msg} if {
    input.review.object.spec.hostIPC == true
    msg := "CIS-5.2.3: pod must not use hostIPC"
}
```

### 5.2.4 Minimize admission of containers wishing to share host network (Level 1)

**Description:** Do not generally permit containers to share the host network namespace.
**Rationale:** A pod running with `hostNetwork: true` can see all network traffic on the host.

```rego
violation contains {"msg": msg} if {
    input.review.object.spec.hostNetwork == true
    msg := "CIS-5.2.4: pod must not use hostNetwork"
}
```

### 5.2.5 Minimize admission of containers with allowPrivilegeEscalation (Level 1)

**Description:** Do not generally permit containers to be run with `allowPrivilegeEscalation` set to true.
**Rationale:** A process with `allowPrivilegeEscalation` can gain more privileges than its parent process.

```rego
violation contains {"msg": msg} if {
    some c in input.review.object.spec.containers
    sc := object.get(c, "securityContext", {})
    object.get(sc, "allowPrivilegeEscalation", true) != false
    msg := sprintf("CIS-5.2.5: container '%s' must set allowPrivilegeEscalation to false", [c.name])
}
```

### 5.2.6 Minimize admission of root containers (Level 1)

**Description:** Do not generally permit containers to be run as the root user.
**Rationale:** Containers running as root have full privileges to the container's filesystem and any mounted volumes.

```rego
violation contains {"msg": msg} if {
    psc := object.get(input.review.object.spec, "securityContext", {})
    object.get(psc, "runAsNonRoot", false) != true
    msg := "CIS-5.2.6: pod must set runAsNonRoot to true"
}
```

### 5.2.7 Minimize admission of containers with NET_RAW capability (Level 1)

**Description:** Do not generally permit containers with the NET_RAW capability.
**Rationale:** NET_RAW allows ARP spoofing and other network-level attacks.

```rego
violation contains {"msg": msg} if {
    some c in input.review.object.spec.containers
    sc := object.get(c, "securityContext", {})
    caps := object.get(sc, "capabilities", {})
    dropped := object.get(caps, "drop", [])
    not _drops_all_or_net_raw(dropped)
    msg := sprintf("CIS-5.2.7: container '%s' must drop NET_RAW capability", [c.name])
}

_drops_all_or_net_raw(dropped) if { "ALL" in dropped }
_drops_all_or_net_raw(dropped) if { "NET_RAW" in dropped }
```

### 5.2.8 Minimize admission of containers with added capabilities (Level 1)

**Description:** Do not generally permit containers with capabilities beyond the default set.
**Rationale:** Linux capabilities provide fine-grained privilege control beyond simple root/non-root.

```rego
allowed_capabilities := {"NET_BIND_SERVICE"}

violation contains {"msg": msg} if {
    some c in input.review.object.spec.containers
    sc := object.get(c, "securityContext", {})
    caps := object.get(sc, "capabilities", {})
    some cap in object.get(caps, "add", [])
    not cap in allowed_capabilities
    msg := sprintf("CIS-5.2.8: container '%s' adds disallowed capability '%s'", [c.name, cap])
}
```

## Section 5.4: Secrets

### 5.4.1 Prefer using secrets as files over environment variables (Level 2)

**Description:** Kubernetes secrets should be mounted as files rather than exposed as environment variables.

```rego
warn contains msg if {
    some c in input.review.object.spec.containers
    some env in object.get(c, "envFrom", [])
    env.secretRef
    msg := sprintf("CIS-5.4.1: container '%s' uses secret via envFrom, prefer volume mount", [c.name])
}
```

## Section 5.7: General Policies

### 5.7.1 Create administrative boundaries between resources (Level 2)

```rego
violation contains {"msg": msg} if {
    not input.review.object.metadata.namespace
    msg := "CIS-5.7.1: resource must specify a namespace"
}
```

### 5.7.2 Ensure that the seccomp profile is set (Level 2)

```rego
violation contains {"msg": msg} if {
    psc := object.get(input.review.object.spec, "securityContext", {})
    not psc.seccompProfile
    msg := "CIS-5.7.2: pod must set a seccomp profile"
}
```

### 5.7.3 Apply security context to pods and containers (Level 2)

```rego
violation contains {"msg": msg} if {
    some c in input.review.object.spec.containers
    not c.securityContext
    msg := sprintf("CIS-5.7.3: container '%s' must have a securityContext", [c.name])
}
```
