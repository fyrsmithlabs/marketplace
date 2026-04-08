---
name: spec
description: Create or update a policy specification at docs/specs/rego/<platform>/<name>/SPEC.md with benchmark research. Say "create a policy spec", "opa spec", "write spec for", or "policy specification".
argument-hint: "<platform> <component> [--update]"
arguments:
  - name: platform
    description: "Target platform (kubernetes, terraform/aws, terraform/azure, terraform/gcp, docker, envoy)"
    required: true
  - name: component
    description: "Policy component name (e.g., pod-security, s3-encryption)"
    required: true
  - name: update
    description: "Update an existing spec rather than creating new"
    required: false
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Agent
  - WebSearch
  - WebFetch
---

# /opa:spec

Create or update policy specification documents with benchmark research.

## Workflow

### Step 1: Normalize Arguments

Parse platform and component. Normalize platform aliases:
- `k8s` -> `kubernetes`
- `tf/aws`, `terraform-aws` -> `terraform/aws`
- etc.

### Step 2: Check Existing Spec

Look for `docs/specs/rego/<platform>/<component>/SPEC.md`:
- If exists and `--update` not set: Warn that spec exists, ask to update or create with different name
- If exists and `--update` set: Read existing spec for modification
- If not found: Proceed to creation

### Step 3: Research Benchmarks

Use the `spec-generator` agent to research:
1. CIS benchmark controls applicable to this platform+component
2. SOC 2 Type II trust criteria mappings
3. NIST 800-53 control families
4. PCI-DSS requirements (if relevant)
5. Existing open-source Rego implementations as references

### Step 4: Generate Spec

Create directory and files:
```
docs/specs/rego/<platform>/<component>/
├── SPEC.md        # Policy specification
├── controls.md    # Detailed benchmark control descriptions
└── examples/
    ├── valid.json   # Example passing input
    └── invalid.json # Example failing input
```

Follow the template from the `spec-driven-policy` skill.

### Step 5: Present for Approval

Display:
- Spec summary (purpose, scope)
- Benchmark controls covered (count by framework)
- Policy rules (deny count, warn count)
- Test cases (positive, negative, edge case counts)
- Any exemptions

Ask: "Approve this spec to proceed, or suggest changes?"

### Step 6: Finalize

On approval:
- Mark spec status as "approved" in SPEC.md frontmatter
- Report file paths created
- Suggest next step: `/opa:write <platform> <component>` to implement
