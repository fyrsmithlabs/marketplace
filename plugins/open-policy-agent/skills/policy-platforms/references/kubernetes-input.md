# Kubernetes AdmissionReview Input Schema

## Gatekeeper Input Structure

Gatekeeper provides the AdmissionReview wrapped in a `review` object with optional `parameters`:

```json
{
  "review": {
    "uid": "abc-123",
    "kind": {
      "group": "",
      "version": "v1",
      "kind": "Pod"
    },
    "resource": {
      "group": "",
      "version": "v1",
      "resource": "pods"
    },
    "requestKind": {
      "group": "",
      "version": "v1",
      "kind": "Pod"
    },
    "name": "my-pod",
    "namespace": "default",
    "operation": "CREATE",
    "userInfo": {
      "username": "system:serviceaccount:default:deployer",
      "groups": ["system:serviceaccounts", "system:authenticated"]
    },
    "object": {
      "apiVersion": "v1",
      "kind": "Pod",
      "metadata": {
        "name": "my-pod",
        "namespace": "default",
        "labels": {
          "app": "nginx",
          "team": "platform"
        },
        "annotations": {}
      },
      "spec": {
        "hostPID": false,
        "hostIPC": false,
        "hostNetwork": false,
        "securityContext": {
          "runAsNonRoot": true,
          "runAsUser": 1000,
          "fsGroup": 2000,
          "seccompProfile": {
            "type": "RuntimeDefault"
          }
        },
        "containers": [
          {
            "name": "app",
            "image": "nginx:1.25",
            "ports": [{"containerPort": 80}],
            "resources": {
              "limits": {"cpu": "500m", "memory": "128Mi"},
              "requests": {"cpu": "250m", "memory": "64Mi"}
            },
            "securityContext": {
              "privileged": false,
              "allowPrivilegeEscalation": false,
              "readOnlyRootFilesystem": true,
              "runAsNonRoot": true,
              "capabilities": {
                "drop": ["ALL"]
              }
            }
          }
        ],
        "initContainers": [],
        "volumes": []
      }
    },
    "oldObject": null,
    "dryRun": false
  },
  "parameters": {
    "labels": ["app", "team"],
    "allowedRegistries": ["gcr.io", "docker.io"]
  }
}
```

## Accessing Common Fields

```rego
# Pod metadata
input.review.object.metadata.name
input.review.object.metadata.namespace
input.review.object.metadata.labels
input.review.object.metadata.annotations

# Operation type
input.review.operation  # CREATE, UPDATE, DELETE, CONNECT

# User info
input.review.userInfo.username
input.review.userInfo.groups

# All containers (including init)
some container in input.review.object.spec.containers
some init_container in input.review.object.spec.initContainers

# Security context (pod level)
input.review.object.spec.securityContext.runAsNonRoot

# Security context (container level)
container.securityContext.privileged
container.securityContext.allowPrivilegeEscalation
container.securityContext.capabilities.drop
container.securityContext.capabilities.add

# Resources
container.resources.limits.cpu
container.resources.limits.memory
container.resources.requests.cpu

# Constraint parameters
input.parameters.labels
input.parameters.allowedRegistries
```

## ConstraintTemplate Authoring

### Template Structure

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
  annotations:
    metadata.gatekeeper.sh/title: "Required Labels"
    metadata.gatekeeper.sh/version: 1.0.0
    description: "Requires specified labels on all resources"
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        openAPIV3Schema:
          type: object
          properties:
            labels:
              type: array
              items:
                type: string
              description: "List of required labels"
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels

        import rego.v1

        violation contains {"msg": msg, "details": {"missing_labels": missing}} if {
            provided := {l | some l, _ in input.review.object.metadata.labels}
            required := {l | some l in input.parameters.labels}
            missing := required - provided
            count(missing) > 0
            msg := sprintf("resource missing required labels: %v", [missing])
        }
```

### Constraint (applies template)

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: require-team-label
spec:
  enforcementAction: deny  # or dryrun, warn
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
      - apiGroups: ["apps"]
        kinds: ["Deployment", "StatefulSet", "DaemonSet"]
    namespaces: ["default", "production"]
    excludedNamespaces: ["kube-system"]
  parameters:
    labels: ["team", "app"]
```

## Testing with Gator

```bash
# Install gator
go install github.com/open-policy-agent/gatekeeper/v3/cmd/gator@latest

# Test suite file
cat > suite.yaml <<EOF
kind: Suite
apiVersion: test.gatekeeper.sh/v1alpha1
tests:
  - name: "require-team-label"
    template: template.yaml
    constraint: constraint.yaml
    cases:
      - name: "pod-with-labels"
        object: test-valid-pod.yaml
        assertions:
          - violations: "no"
      - name: "pod-missing-labels"
        object: test-invalid-pod.yaml
        assertions:
          - violations: "yes"
            message: "missing required labels"
EOF

gator verify suite.yaml
```

## Common Resource Types

| Kind | API Group | Spec Path |
|------|-----------|-----------|
| Pod | "" (core) | `input.review.object.spec` |
| Deployment | apps | `input.review.object.spec.template.spec` |
| StatefulSet | apps | `input.review.object.spec.template.spec` |
| DaemonSet | apps | `input.review.object.spec.template.spec` |
| Job | batch | `input.review.object.spec.template.spec` |
| CronJob | batch | `input.review.object.spec.jobTemplate.spec.template.spec` |
| Service | "" (core) | `input.review.object.spec` |
| Ingress | networking.k8s.io | `input.review.object.spec` |
| NetworkPolicy | networking.k8s.io | `input.review.object.spec` |

Note: For workload controllers (Deployment, StatefulSet, etc.), the pod spec is nested under `.spec.template.spec`.
