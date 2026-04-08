# open-policy-agent

Claude Code plugin for OPA/Rego policy authoring, validation, testing, and benchmark-aligned specification generation.

## Features

- **Rego Language Support** - Write idiomatic Rego v1 policies with built-in function reference
- **Spec-Driven Development** - Research CIS/SOC2/NIST benchmarks and generate policy specifications before writing code
- **Multi-Platform** - Kubernetes (Gatekeeper), Terraform, Docker, Envoy, AWS/Azure/GCP
- **Validation Pipeline** - Syntax checking, Regal linting, test execution, coverage, benchmark alignment
- **Test Generation** - Comprehensive `_test.rego` creation with positive, negative, and edge cases
- **Security Benchmarks** - CIS, SOC 2 Type II, NIST 800-53, PCI-DSS, HIPAA control mappings
- **Rego v1 Migration** - Automated v0 to v1 syntax migration

## Prerequisites

- [OPA CLI](https://www.openpolicyagent.org/docs/latest/#running-opa) (`brew install opa`)
- [Regal](https://github.com/StyraInc/regal) (`brew install styrainc/packages/regal`) - optional but recommended
- [Conftest](https://www.conftest.dev/) (`brew install conftest`) - for structured config testing

## Commands

| Command | Purpose |
|---------|---------|
| `/opa:write <platform> <component>` | Guided policy creation with spec and tests |
| `/opa:validate [path]` | Run full validation pipeline |
| `/opa:test [path]` | Generate and run test suites |
| `/opa:spec <platform> <component>` | Create benchmark-aligned policy spec |
| `/opa:review [path]` | Deep security review against benchmarks |
| `/opa:migrate [path]` | Migrate Rego v0 to v1 syntax |

## Skills (auto-activate)

| Skill | Triggers On |
|-------|------------|
| `rego-language` | Writing or reviewing `.rego` files |
| `opa-testing` | Testing OPA policies, `_test.rego` files |
| `opa-toolchain` | OPA CLI commands, Regal, bundle management |
| `policy-platforms` | Platform-specific policies (K8s, Terraform, Docker, Envoy) |
| `security-benchmarks` | CIS, SOC2, HIPAA, PCI-DSS, NIST compliance |
| `spec-driven-policy` | Creating policy specifications |
| `rego-v1-migration` | Migrating Rego v0 to v1 |

## Agents

| Agent | Purpose | Trigger |
|-------|---------|---------|
| `policy-validator` | Validate syntax, lint, tests, benchmarks | Proactive after `.rego` edits |
| `spec-generator` | Research benchmarks, generate SPEC.md | On request |
| `policy-reviewer` | Security gap analysis and review | PR review or on request |
| `test-generator` | Generate comprehensive test suites | On request |

## Spec-Driven Workflow

The plugin follows a spec-first approach for policy development:

1. `/opa:spec kubernetes pod-security` - Research benchmarks, generate SPEC.md
2. Review and approve the spec
3. `/opa:write kubernetes pod-security` - Implement policy from spec
4. `/opa:validate` - Run validation pipeline
5. `/opa:review` - Deep review against benchmarks

Specs are stored at `docs/specs/rego/<platform>/<component>/SPEC.md`.

## Installation

```bash
# As part of the fyrsmithlabs marketplace
claude --plugin-dir /path/to/marketplace/plugins/open-policy-agent

# Or install marketplace root
claude --plugin-dir /path/to/marketplace
```
