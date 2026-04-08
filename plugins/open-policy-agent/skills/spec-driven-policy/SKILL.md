---
name: spec-driven-policy
description: This skill should be used when the user asks to "create a policy spec", "write a spec", "spec-first policy", "docs/specs/rego", "SPEC.md", "policy specification", "spec template", or mentions creating specification documents for OPA policies before writing Rego. Provides the spec-driven policy development workflow with benchmark research and approval gates.
---

# Spec-Driven Policy Development

A spec-first workflow for OPA policy development. Write a specification document before writing Rego code, ensuring benchmark alignment, stakeholder approval, and complete test coverage from the start.

## Workflow Overview

```
1. Research    -> Find relevant CIS/SOC2/NIST controls for the target
2. Spec        -> Write SPEC.md with rules, benchmarks, test cases
3. Approve     -> Present spec for user review and approval
4. Implement   -> Write Rego policy matching the spec
5. Test        -> Generate tests covering all spec scenarios
6. Validate    -> Verify policy matches spec requirements
```

---

## Directory Structure

All policy specs live under `docs/specs/rego/` organized by platform and component:

```
docs/specs/rego/
├── kubernetes/
│   ├── pod-security/
│   │   ├── SPEC.md           # Policy specification
│   │   ├── controls.md       # Detailed benchmark control mappings
│   │   └── examples/
│   │       ├── valid.json    # Example passing input
│   │       └── invalid.json  # Example failing input
│   ├── network-policy/
│   │   └── SPEC.md
│   └── image-policy/
│       └── SPEC.md
├── terraform/
│   ├── aws/
│   │   ├── s3-encryption/
│   │   │   ├── SPEC.md
│   │   │   └── controls.md
│   │   └── iam-least-privilege/
│   │       └── SPEC.md
│   ├── azure/
│   │   └── storage-security/
│   │       └── SPEC.md
│   └── gcp/
│       └── compute-firewall/
│           └── SPEC.md
├── docker/
│   └── image-security/
│       └── SPEC.md
└── envoy/
    └── api-authorization/
        └── SPEC.md
```

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Platform dir | Lowercase | `kubernetes/`, `terraform/` |
| Cloud subdir | Lowercase provider | `terraform/aws/`, `terraform/gcp/` |
| Component dir | Kebab-case | `pod-security/`, `s3-encryption/` |
| Spec file | Always `SPEC.md` | `kubernetes/pod-security/SPEC.md` |
| Controls file | Always `controls.md` | `kubernetes/pod-security/controls.md` |
| Examples dir | Always `examples/` | Contains JSON input examples |

---

## SPEC.md Template

```markdown
# SPEC: [Policy Name]

**Platform:** [kubernetes | terraform/aws | terraform/azure | terraform/gcp | docker | envoy]
**Component:** [component-name]
**Version:** 0.1.0
**Status:** [draft | review | approved | implemented]
**Author:** [name]
**Date:** [YYYY-MM-DD]

---

## Purpose

[1-3 sentences: What this policy enforces and why it matters.]

## Scope

**Applies to:**
- [Resource type 1]
- [Resource type 2]

**Excludes:**
- [Exemption 1 with justification]

---

## Benchmark Alignment

### CIS Controls

| CIS ID | Title | Level | Enforcement |
|--------|-------|-------|-------------|
| [ID] | [title] | [1\|2] | [deny\|warn] |

### Compliance Frameworks

| Framework | Control | Description |
|-----------|---------|-------------|
| SOC2 | [CC-ID] | [description] |
| NIST 800-53 | [family-ID] | [description] |
| PCI-DSS | [req-ID] | [description] |

@include controls.md

---

## Policy Rules

### DENY Rules (must block)

1. **[Rule name]**: [Description of what triggers a deny]
   - Input path: `input.path.to.field`
   - Condition: [exact condition]
   - Message: "[violation message template]"

### WARN Rules (advisory)

1. **[Rule name]**: [Description of what triggers a warning]

### EXEMPT Conditions

1. **[Exemption]**: [When this rule does not apply]
   - Justification: [why]

---

## Input Schema

[Description of the input structure this policy evaluates]

```json
{
  "example": "input structure"
}
```

---

## Test Cases

### Positive Tests (should pass / no violations)

| Test | Input Description | Expected |
|------|-------------------|----------|
| [name] | [description] | 0 violations |

### Negative Tests (should deny / produce violations)

| Test | Input Description | Expected |
|------|-------------------|----------|
| [name] | [description] | 1+ violations containing "[msg]" |

### Edge Cases

| Test | Input Description | Expected |
|------|-------------------|----------|
| [name] | [description] | [expected behavior] |

---

## Implementation Notes

[Any implementation-specific guidance, performance considerations, or known limitations.]

## References

- [Link to CIS benchmark document]
- [Link to OPA documentation]
- [Link to platform documentation]
```

---

## Creating a Spec: Step-by-Step

### Step 1: Research Benchmarks

Before writing the spec, research applicable benchmarks for the target platform and component:

1. Load the `security-benchmarks` skill for control references
2. Identify relevant CIS benchmark controls
3. Map to SOC2/NIST/PCI-DSS where applicable
4. Check existing open-source policy libraries (Terrascan, Trivy, Kubescape) for reference implementations

### Step 2: Write the Spec

1. Create the directory: `docs/specs/rego/<platform>/<name>/`
2. Write `SPEC.md` using the template above
3. Create `controls.md` with detailed benchmark control descriptions
4. Create `examples/` with sample valid and invalid inputs

### Step 3: Present for Approval

Present the spec to the user with:
- Summary of what the policy will enforce
- Benchmark controls being addressed
- Number of deny rules, warn rules, and test cases
- Any exemptions or scope limitations

**Do not proceed to implementation until the spec is approved.**

### Step 4: Implement from Spec

Once approved, generate Rego that matches the spec exactly:
- One deny/warn rule per spec entry
- Metadata annotations referencing benchmark controls
- Package name derived from platform and component
- Helper functions in a shared lib package

### Step 5: Generate Tests from Spec

Generate `_test.rego` covering every test case in the spec:
- One test function per table row
- Use fixture data matching the example inputs
- Verify violation messages match spec templates

---

## controls.md Template

```markdown
# Benchmark Controls: [Policy Name]

## CIS [Platform] Benchmark v[X.Y]

### [CIS-ID]: [Control Title]

**Level:** [1 | 2]
**Description:** [Full description from CIS benchmark]
**Rationale:** [Why this control matters]
**Audit:** [How to verify compliance]
**Remediation:** [How to fix non-compliance]
**Enforcement:** [deny | warn] - [what the Rego rule checks]

---

## SOC 2 Type II

### [CC-ID]: [Control Description]

**Category:** [Security | Availability | Confidentiality | Privacy | Processing Integrity]
**Description:** [Full control description]
**OPA Implementation:** [How Rego enforces this]

---

## NIST 800-53

### [Family-ID]: [Control Name]

**Family:** [Access Control | Audit | Config Management | ...]
**Description:** [Control description]
**OPA Implementation:** [How Rego enforces this]
```

---

## Existing Spec Check

Before creating a new spec, always check for existing specs:

```
Check: docs/specs/rego/<platform>/<name>/SPEC.md
```

If a spec exists, offer to update it rather than creating a duplicate. If the spec is marked `approved` or `implemented`, warn the user about modifying an approved spec.

---

## Additional Resources

### Reference Files

- **`references/spec-examples.md`** - Complete example specs for common policies (K8s pod security, AWS S3 encryption, Docker image security)
