---
name: review
description: Deep review of OPA policies against benchmarks and best practices. Say "review my rego", "opa review", "check policy gaps", or "review opa policies".
argument-hint: "[path] [--benchmark cis-k8s|cis-aws|cis-docker|soc2|nist]"
arguments:
  - name: path
    description: "Path to policy files to review (defaults to all .rego files)"
    required: false
  - name: benchmark
    description: "Specific benchmark to check against (cis-k8s, cis-aws, cis-docker, soc2, nist)"
    required: false
allowed-tools:
  - Read
  - Glob
  - Grep
  - Agent
---

# /opa:review

Deep security review of OPA/Rego policies for completeness, correctness, and benchmark alignment.

## Workflow

### Step 1: Discover and Read Policies

Find all `.rego` files in the target path:
- Read each policy file
- Identify platform from package name or directory structure
- Collect all rules, helpers, and metadata annotations

### Step 2: Launch Policy Reviewer

Use the `policy-reviewer` agent with the discovered files. The agent performs:
- Security gap analysis
- Benchmark coverage check
- Common vulnerability pattern detection
- Code quality assessment
- Test coverage assessment

### Step 3: Benchmark-Specific Review

If `--benchmark` flag provided, focus the review on that specific framework:
- `cis-k8s`: Check against CIS Kubernetes Benchmark controls
- `cis-aws`: Check against CIS AWS Foundations Benchmark
- `cis-docker`: Check against CIS Docker Benchmark Section 4
- `soc2`: Check against SOC 2 Trust Service Criteria
- `nist`: Check against NIST 800-53 control families

Cross-reference with spec files in `docs/specs/rego/` if they exist.

### Step 4: Cross-Reference Specs

For each policy, check if a corresponding spec exists:
- `docs/specs/rego/<platform>/<component>/SPEC.md`
- If found, verify policy implements all rules defined in the spec
- Flag any spec rules not implemented
- Flag any policy rules not in the spec

### Step 5: Report

Present the policy-reviewer agent's structured output:
- Critical findings with severity, location, and recommendations
- Benchmark coverage matrix
- Code quality findings
- Test coverage assessment
- Overall verdict (PASS / NEEDS WORK / FAIL)

For each critical finding, provide a concrete code fix suggestion.
