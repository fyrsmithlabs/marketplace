# OPA Server Mode & REST API

## Running OPA as a Server

```bash
# Start OPA with policies loaded
opa run --server --addr :8181 ./policies/

# With bundle
opa run --server -b bundle.tar.gz

# With configuration file
opa run --server -c config.yaml
```

## REST API Endpoints

### Policy Evaluation

```bash
# Evaluate a policy
curl -X POST http://localhost:8181/v1/data/authz/allow \
  -H "Content-Type: application/json" \
  -d '{"input": {"user": "alice", "action": "read"}}'

# Response:
# {"result": true}
```

### Policy Management

```bash
# Create/update a policy
curl -X PUT http://localhost:8181/v1/policies/authz \
  -H "Content-Type: text/plain" \
  --data-binary @policy.rego

# List policies
curl http://localhost:8181/v1/policies

# Delete a policy
curl -X DELETE http://localhost:8181/v1/policies/authz
```

### Data Management

```bash
# Create/update data
curl -X PUT http://localhost:8181/v1/data/roles \
  -H "Content-Type: application/json" \
  -d '{"admin": ["alice"], "viewer": ["bob"]}'

# Read data
curl http://localhost:8181/v1/data/roles

# Patch data (JSON Patch)
curl -X PATCH http://localhost:8181/v1/data/roles \
  -H "Content-Type: application/json-patch+json" \
  -d '[{"op": "add", "path": "/editor", "value": ["charlie"]}]'
```

## Management APIs

### Bundle Configuration

```yaml
# config.yaml
services:
  acmecorp:
    url: https://bundles.example.com
    credentials:
      bearer:
        token: "${BUNDLE_TOKEN}"

bundles:
  authz:
    service: acmecorp
    resource: bundles/authz/bundle.tar.gz
    polling:
      min_delay_seconds: 30
      max_delay_seconds: 120
    signing:
      keyid: global_key
      scope: read
```

### Decision Logs

```yaml
decision_logs:
  service: acmecorp
  resource: /logs
  reporting:
    min_delay_seconds: 60
    max_delay_seconds: 300
  partition_name: authz
  mask_decision: /system/log/mask
```

Decision log entry structure:
```json
{
  "decision_id": "abc-123",
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "authz/allow",
  "input": {"user": "alice"},
  "result": true,
  "metrics": {
    "timer_rego_query_eval_ns": 123456
  }
}
```

### Status API

```yaml
status:
  service: acmecorp
  resource: /status
```

```bash
# Check OPA health
curl http://localhost:8181/health

# Detailed health with bundles and plugins
curl http://localhost:8181/health?bundles=true&plugins=true
```

### Discovery

```yaml
discovery:
  service: acmecorp
  resource: /configuration/default
  decision: /default/config
```

Discovery allows centrally managing OPA configuration. OPA downloads a discovery bundle that contains a policy producing the runtime configuration.

## Bundle Distribution

### Supported backends:
- **HTTP** - Any HTTP server (Nginx, S3, GCS, Azure Blob)
- **OCI** - OCI-compatible registries (Docker Hub, GHCR, ECR, GCR)
- **S3** - Native S3 support with credentials
- **GCS** - Native Google Cloud Storage support

### S3 Example

```yaml
services:
  s3:
    url: https://my-bucket.s3.amazonaws.com
    credentials:
      s3_signing:
        environment_credentials: {}

bundles:
  authz:
    service: s3
    resource: bundles/authz.tar.gz
```

### OCI Example

```bash
# Push bundle to OCI registry
oras push ghcr.io/org/policy:v1.0 bundle.tar.gz:application/vnd.oci.image.layer.v1.tar+gzip

# OPA config
services:
  ghcr:
    url: https://ghcr.io
    type: oci
bundles:
  authz:
    service: ghcr
    resource: org/policy:v1.0
```
