---
name: opa-toolchain
description: This skill should be used when the user asks about "opa cli", "opa eval", "opa build", "opa check", "opa fmt", "regal lint", "opa bundle", "opa bench", "opa run", or mentions OPA tooling, CI/CD pipeline integration for OPA, or Rego linting. Provides OPA CLI and ecosystem tooling reference.
---

# OPA Toolchain

Reference for the OPA CLI, Regal linter, and ecosystem tooling. Covers the complete policy development lifecycle from authoring through deployment.

## OPA CLI Reference

### Core Commands

| Command | Purpose | Common Flags |
|---------|---------|-------------|
| `opa eval` | Evaluate a Rego query | `-d`, `-i`, `--format`, `--explain`, `--partial` |
| `opa test` | Run unit tests | `-v`, `--coverage`, `--threshold`, `--run`, `--bench` |
| `opa check` | Validate syntax | `--strict`, `--schema`, `-b` |
| `opa fmt` | Format Rego files | `-w` (write), `--rego-v1` (migrate) |
| `opa build` | Create bundles | `-b`, `-o`, `--optimize`, `--target` |
| `opa run` | REPL or server | `--server`, `--addr`, `-b` |
| `opa bench` | Benchmark queries | `--benchmem`, `-d`, `-i` |
| `opa inspect` | Analyze bundles | (bundle path) |
| `opa sign` | Sign bundles | `--signing-key`, `--signing-alg` |
| `opa exec` | Batch evaluate | `-b`, `--decision` |
| `opa deps` | Show dependencies | `-d` |
| `opa parse` | Show AST | `--format json` |

### Evaluation

```bash
# Evaluate a query against policy and input
opa eval -d policy.rego -i input.json "data.authz.allow"

# Pretty-print result
opa eval -d policy.rego -i input.json "data.authz.allow" --format pretty

# Trace evaluation (debugging)
opa eval -d policy.rego -i input.json "data.authz.allow" --explain=notes

# Full trace
opa eval -d policy.rego -i input.json "data.authz.allow" --explain=full

# Profiling
opa eval -d policy.rego -i input.json "data.authz.allow" --profile

# Partial evaluation (optimize)
opa eval -d policy.rego --partial -i input.json "data.authz.allow"

# With bundle
opa eval -b bundle/ -i input.json "data.authz.allow"
```

### Syntax Checking

```bash
# Basic check
opa check policy.rego

# Strict mode (catches more issues)
opa check --strict policy.rego

# With JSON schema validation
opa check --schema schema/ policy.rego

# Check all files in directory
opa check ./policies/

# Check bundle
opa check -b bundle/
```

### Formatting

```bash
# Preview formatting changes
opa fmt policy.rego

# Write changes in-place
opa fmt -w policy.rego

# Format all Rego files
opa fmt -w ./policies/

# Migrate to Rego v1 syntax
opa fmt --rego-v1 -w policy.rego

# List files that would change
opa fmt -l ./policies/
```

---

## Bundle Management

Bundles package policies and data for distribution.

### Build

```bash
# Build from directory
opa build -b ./policies/ -o bundle.tar.gz

# With optimization (removes dead code)
opa build -b ./policies/ -o bundle.tar.gz --optimize=1

# Optimization levels:
#   0 = no optimization (default)
#   1 = inline partial rules
#   2 = more aggressive inlining

# Set entrypoints for optimization
opa build -b ./policies/ --entrypoint authz/allow -o bundle.tar.gz

# Build Wasm bundle
opa build -b ./policies/ --target wasm --entrypoint authz/allow -o policy.wasm
```

### Sign and Verify

```bash
# Generate signing key
openssl genrsa -out key.pem 2048
openssl rsa -in key.pem -pubout -out pubkey.pem

# Sign bundle
opa sign --signing-key key.pem --bundle bundle.tar.gz

# OPA verifies signatures on bundle download automatically
# Configure in OPA config:
# bundles:
#   authz:
#     signing:
#       keyid: my_key
```

### Inspect

```bash
# View bundle contents
opa inspect bundle.tar.gz

# Output: namespaces, entrypoints, revision, metadata
```

### Bundle Structure

```
bundle.tar.gz
├── data.json          # Static data
├── policies/
│   ├── authz.rego
│   └── helpers.rego
├── .manifest           # Bundle metadata
└── .signatures.json    # Cryptographic signatures
```

---

## Regal Linter

Regal is the official Rego linter with 60+ rules.

### Installation

```bash
# macOS
brew install styrainc/packages/regal

# Go install
go install github.com/styrainc/regal@latest

# GitHub Actions
- uses: styrainc/setup-regal@v2
```

### Usage

```bash
# Lint all Rego files
regal lint ./policies/

# Lint specific file
regal lint policy.rego

# Output as JSON
regal lint --format json ./policies/

# Fix auto-fixable issues
regal fix ./policies/
```

### Configuration

Create `.regal/config.yaml`:

```yaml
rules:
  style:
    opa-fmt:
      level: error
    prefer-some-in-iteration:
      level: error
    use-assignment-operator:
      level: error
  bugs:
    constant-condition:
      level: error
    unused-return-value:
      level: error
  testing:
    test-outside-test-package:
      level: warning
  imports:
    prefer-package-imports:
      level: warning
  custom:
    naming-convention:
      level: warning
      conventions:
        - pattern: "^[a-z_][a-z0-9_]*$"
          targets:
            - rule
            - function
```

### Key Rule Categories

| Category | Focus |
|----------|-------|
| `bugs` | Logic errors, constant conditions, unused values |
| `style` | Formatting, naming, operator usage |
| `imports` | Import organization, redundancy |
| `testing` | Test file conventions, coverage |
| `performance` | Inefficient patterns |
| `custom` | User-defined naming and style rules |

---

## Regal Language Server

Regal provides LSP support for IDE integration:

| Feature | Description |
|---------|-------------|
| Diagnostics | Real-time linting warnings/errors |
| Completion | Rule names, built-ins, packages |
| Hover | Documentation for built-in functions |
| Go to definition | Navigate to rule/function definitions |
| Code actions | Quick fixes for linting issues |
| Formatting | `opa fmt` integration |

---

## Benchmarking

```bash
# Benchmark a query
opa bench -d policy.rego -i input.json "data.authz.allow"

# With memory stats
opa bench -d policy.rego -i input.json "data.authz.allow" --benchmem

# Output:
# BenchmarkEval     5000    234567 ns/op    12345 B/op    123 allocs/op
```

---

## Environment Variables

OPA CLI commands support env var overrides:

```bash
# Pattern: OPA_<COMMAND>_<FLAG>
export OPA_EVAL_STRICT=true
export OPA_CHECK_STRICT=true
export OPA_FMT_REGO_V1=true
```

---

## CI/CD Pipeline Integration

```yaml
# GitHub Actions
- name: Setup OPA
  uses: open-policy-agent/setup-opa@v2
  with:
    version: latest

- name: Setup Regal
  uses: styrainc/setup-regal@v2

- name: Check Syntax
  run: opa check --strict ./policies/

- name: Lint
  run: regal lint ./policies/

- name: Test with Coverage
  run: opa test ./policies/ -v --coverage --threshold 80

- name: Build Bundle
  run: opa build -b ./policies/ -o bundle.tar.gz
```

---

## Additional Resources

### Reference Files

- **`references/opa-server.md`** - OPA server mode, REST API, management APIs (bundles, decision logs, status)
- **`references/ci-cd-patterns.md`** - Detailed CI/CD integration patterns for GitHub Actions, GitLab CI, Jenkins, ArgoCD
