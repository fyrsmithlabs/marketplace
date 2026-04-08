---
name: write
description: Guided OPA policy creation workflow. Selects platform, researches benchmarks, generates spec, writes Rego policy and tests. Say "write an opa policy", "create a rego policy", "opa write", or "new policy for <platform>".
argument-hint: "<platform> <component> [--skip-spec]"
arguments:
  - name: platform
    description: "Target platform (kubernetes, terraform/aws, terraform/azure, terraform/gcp, docker, envoy)"
    required: true
  - name: component
    description: "Policy component name (e.g., pod-security, s3-encryption, image-security)"
    required: true
  - name: skip-spec
    description: "Skip spec generation if one already exists"
    required: false
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - WebSearch
  - WebFetch
  - TaskCreate
  - TaskUpdate
---

# /opa:write

End-to-end guided policy creation from spec to tested Rego implementation.

## Workflow

### Step 1: Validate Arguments

Parse the platform and component from arguments. Normalize platform names:
- `k8s`, `kube`, `kubernetes` -> `kubernetes`
- `tf`, `terraform` -> `terraform` (requires sub-platform: aws, azure, gcp)
- `docker`, `dockerfile` -> `docker`
- `envoy`, `mesh`, `service-mesh` -> `envoy`

If component is missing, ask the user what specific policy they want to create.

### Step 2: Check for Existing Spec

Look for `docs/specs/rego/<platform>/<component>/SPEC.md`:
- If exists and `--skip-spec` not set: Show spec summary and ask if it should be used as-is or updated
- If exists and `--skip-spec` set: Use existing spec directly
- If not found: Proceed to spec generation

### Step 3: Generate Spec (if needed)

Use the `spec-generator` agent to:
1. Research applicable CIS benchmarks for the platform+component
2. Map SOC2/NIST/PCI-DSS controls
3. Generate SPEC.md, controls.md, and example inputs
4. Present spec summary for user approval

**Do not proceed to implementation until the spec is approved.**

### Step 4: Create Policy Directory

Create the policy file structure:
```
policies/<platform>/<component>.rego
policies/<platform>/<component>_test.rego
```

Or for Conftest:
```
policy/<platform>/<component>.rego
policy/<platform>/<component>_test.rego
```

Ask the user which directory structure they prefer, or detect from existing project structure.

### Step 5: Write Rego Policy

Generate the Rego policy file based on the spec:
- Package name derived from platform and component
- One rule per DENY/WARN entry in the spec
- `# METADATA` annotations with benchmark references
- Rego v1 syntax (mandatory `if`, `contains`)
- Helper functions for reusable logic
- Import shared libraries if they exist

### Step 6: Generate Tests

Use the `test-generator` agent to generate `_test.rego`:
- One test per spec test case row
- Positive, negative, and edge case categories
- Fixtures matching platform input schema
- Verify violation messages match spec templates

### Step 7: Validate

Run the `policy-validator` agent:
- `opa check --strict`
- `regal lint` (if available)
- `opa test -v --coverage`
- Benchmark annotation check

### Step 8: Report

Present summary:
- Files created (with paths)
- Policy rules: [N] deny, [N] warn
- Test cases: [N] positive, [N] negative, [N] edge
- Coverage: [X]%
- Benchmark controls addressed
- Next steps (CI/CD integration, bundle building)
