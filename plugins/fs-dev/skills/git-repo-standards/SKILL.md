---
name: git-repo-standards
description: Use when creating new repositories, reviewing existing repos for compliance, or enforcing repository naming, structure, documentation, and security standards. Applies to all fyrsmithlabs projects.
---

# Git Repository Standards

Enforce consistent repository naming, structure, documentation, and security standards across all fyrsmithlabs projects.

## Modes of Operation

| Mode | Trigger | Action |
|------|---------|--------|
| **Review** | "review repo standards", "audit repository" | Analyze repo against standards, produce compliance report |
| **Generate** | "create new repo", "scaffold repository" | Create new repo with correct structure from scratch |
| **Enforce** | Automatic via hooks | Block critical violations, warn on style issues |

## Enforcement Tiers

| Tier | Action | Violations |
|------|--------|------------|
| **Critical** | Block | Secrets detected, missing LICENSE/README/CHANGELOG/.gitignore, gitleaks not configured, agent artifacts in repo root, invalid repo naming, missing SECURITY.md (public repos) |
| **Required** | Block | `.env` not gitignored, `docs/.claude/` not gitignored, service repo missing AGPL-3.0, missing CODEOWNERS, no branch protection on main |
| **Style** | Warn | Incomplete README sections, non-conventional commits, missing badges, suboptimal structure, outdated copyright year, missing CONTRIBUTING.md, no OpenSSF badge |

---

## Repository Naming

**Format:** `lowercase-kebab-case`

**Pattern:** `[domain]-[type]`

| Component | Required | Examples |
|-----------|----------|----------|
| `domain` | Required | `marketplace`, `auth`, `billing`, `plugin-registry` |
| `type` | Optional | `-api`, `-cli`, `-lib`, `-service`, `-worker` |

**Valid Examples:**
- `marketplace`
- `auth-service`
- `plugin-registry-api`
- `git-workflow-lib`
- `temporal-worker`

**Blocked Patterns:**

| Pattern | Reason |
|---------|--------|
| `CamelCase`, `snake_case` | Inconsistent, URL issues |
| `my-project-v2` | No versions in names |
| `johns-cool-thing` | No personal names |
| `backend`, `service` | Too generic |
| Spaces, special chars | URL/CLI incompatible |

**Validation Rules:**
- Max 50 characters
- Must start with letter
- Only `a-z`, `0-9`, `-`
- Hyphen cannot start/end name or be consecutive

---

## Directory Structure

### Go Projects

```
repo-name/
├── cmd/                    # Application entrypoints
│   └── app-name/
│       └── main.go
├── internal/               # Private packages (compiler-enforced)
│   ├── domain/             # Business logic by feature
│   └── platform/           # Infrastructure (db, cache, etc.)
├── pkg/                    # Public reusable libraries (optional)
├── api/                    # OpenAPI specs, protobuf definitions
├── configs/                # Config templates
├── scripts/                # Build, CI, dev scripts
├── deployments/            # Docker, k8s, terraform
├── docs/
│   ├── .claude/            # Agent artifacts (MUST be gitignored)
│   │   ├── tasks/
│   │   ├── plans/
│   │   └── orchestration/
│   └── adr/                # Architecture decision records
├── .github/
│   ├── workflows/          # GitHub Actions workflows
│   │   ├── ci.yml
│   │   ├── security.yml
│   │   └── release.yml
│   ├── dependabot.yml      # Dependency updates
│   ├── ISSUE_TEMPLATE/     # Issue templates
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODEOWNERS
├── .gitignore
├── .gitleaks.toml
├── .pre-commit-config.yaml # Pre-commit hooks (recommended)
├── CHANGELOG.md
├── CONTRIBUTING.md         # Contributor guide (public repos)
├── LICENSE
├── README.md
├── SECURITY.md             # Security policy (public repos)
└── go.mod
```

### Generic/Non-Go Projects

```
repo-name/
├── src/                    # Source code
├── lib/                    # Shared libraries
├── tests/                  # Test files
├── docs/
│   ├── .claude/            # Agent artifacts (MUST be gitignored)
│   │   ├── tasks/
│   │   ├── plans/
│   │   └── orchestration/
│   └── adr/                # Architecture decision records
├── scripts/                # Build, CI, dev scripts
├── configs/                # Configuration templates
├── deployments/            # Infrastructure as code
├── .github/
│   ├── workflows/          # GitHub Actions workflows
│   ├── ISSUE_TEMPLATE/     # Issue templates
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODEOWNERS
├── .gitignore
├── .gitleaks.toml
├── .pre-commit-config.yaml # Pre-commit hooks (recommended)
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── SECURITY.md             # Security policy (public repos)
```

### Monorepo Structure

For projects using monorepo patterns (nx, turborepo, lerna):

```
monorepo-name/
├── apps/                   # Application packages
│   ├── api/
│   ├── web/
│   └── cli/
├── packages/               # Shared libraries
│   ├── core/
│   ├── ui/
│   └── utils/
├── tools/                  # Build tools, generators
├── docs/
│   ├── .claude/            # Agent artifacts (MUST be gitignored)
│   └── adr/
├── .github/
│   ├── workflows/
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODEOWNERS
├── .gitignore
├── .gitleaks.toml
├── .pre-commit-config.yaml
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── SECURITY.md
├── nx.json / turbo.json / lerna.json
└── package.json / go.work
```

**Monorepo Tool Support:**

| Tool | Config File | Language | Best For |
|------|-------------|----------|----------|
| Nx | `nx.json` | JS/TS, Go, Rust | Large teams, enterprise |
| Turborepo | `turbo.json` | JS/TS | Frontend-heavy projects |
| Lerna | `lerna.json` | JS/TS | Publishing multiple packages |
| Go Workspaces | `go.work` | Go | Multi-module Go projects |

### Multi-Language (Polyglot) Structure

For repositories containing multiple languages:

```
polyglot-service/
├── backend/                # Go, Rust, or Python
│   ├── cmd/
│   ├── internal/
│   └── go.mod
├── frontend/               # TypeScript/JavaScript
│   ├── src/
│   └── package.json
├── scripts/                # Shared build scripts
│   └── build.sh
├── docker/                 # Container definitions
│   ├── backend.Dockerfile
│   └── frontend.Dockerfile
├── docs/
│   ├── .claude/
│   └── adr/
├── .github/
│   ├── workflows/
│   └── CODEOWNERS
├── docker-compose.yml
├── Makefile               # Unified build commands
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── SECURITY.md
```

### Anti-Patterns

| Pattern | Action | Reason |
|---------|--------|--------|
| `/src` in Go project | Warn | Java convention, not Go |
| `TODO.md`, `PLAN.md` in root | Block | Agent artifacts must go to `docs/.claude/` |
| `*.task`, `*.orchestration` in root | Block | Agent artifacts must go to `docs/.claude/` |
| Missing `internal/` for 3+ packages | Warn | Exposes private APIs |
| Deep nesting (>3 levels) | Warn | Go prefers shallow hierarchies |
| Mixing app code with infra | Warn | Separate concerns (apps/, packages/, deployments/) |
| No workspace file in monorepo | Warn | Use go.work, nx.json, or turbo.json |
| Language-specific files in root of polyglot | Warn | Group by language in subdirectories |

---

## README Requirements

### Required Sections (Block if missing)

| Section | Purpose |
|---------|---------|
| Title + Description | One-line summary of what this repo does |
| Installation | How to install/build |
| Usage | Basic usage examples |
| License | License type (link to LICENSE file) |

### Required Badges

| Badge | Purpose |
|-------|---------|
| Build/CI Status | Shows pipeline health |
| Go Version | Min Go version (Go projects only) |
| License | License type |
| Gitleaks | Security scanning enabled |
| OpenSSF Best Practices | Security posture (recommended for public repos) |
| Dependency Status | Shows if dependencies are up-to-date |

**Badge Placement:**
```markdown
# repo-name

![Build](...)  ![Go](...)  ![License](...)  ![Gitleaks](...)  ![OpenSSF](...)

One-line description of what this repo does.
```

**OpenSSF Best Practices Badge:**
```markdown
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/XXXXX/badge)](https://www.bestpractices.dev/projects/XXXXX)
```
Register at [bestpractices.dev](https://www.bestpractices.dev/) to obtain a project ID.

### Recommended Sections (Warn if missing)

| Section | Purpose |
|---------|---------|
| Prerequisites | Required tools, versions, dependencies |
| Configuration | Environment variables, config files |
| Development | How to set up local dev environment |
| Testing | How to run tests |
| Contributing | Link to CONTRIBUTING.md |
| Security | Link to SECURITY.md for reporting vulnerabilities |

---

## CHANGELOG Requirements

**Format:** [Keep a Changelog](https://keepachangelog.com/) style

```markdown
# Changelog

## [Unreleased]

## [1.2.0] - 2026-01-07
### Added
- New feature X

### Changed
- Updated behavior Y

### Fixed
- Bug Z
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| CHANGELOG.md missing | Block |
| No `[Unreleased]` section | Warn |
| Tagged release without CHANGELOG entry | Block |
| Entry missing category | Warn |

**Valid Categories:**
`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`

---

## Licensing

| Project Type | License | Indicators |
|--------------|---------|------------|
| Libraries, CLIs, tools | Apache-2.0 | `*-lib`, `*-cli`, `*-sdk`, pkg-only repos |
| Services, platforms, APIs | AGPL-3.0 | `*-service`, `*-api`, `*-server`, `*-worker`, has `cmd/` |
| Internal/proprietary | Proprietary | Private repos, no LICENSE file |

**Alternative Licenses (Supported but Flagged):**

| License | Acceptable For | Flag Level |
|---------|----------------|------------|
| MIT | Libraries, small utilities | Warn - prefer Apache-2.0 for patent protection |
| BSD-3-Clause | Libraries | Warn - prefer Apache-2.0 for patent protection |
| ISC | Minimal packages | Warn - prefer Apache-2.0 |
| GPL-3.0 | Libraries that must stay copyleft | Warn - consider AGPL-3.0 for network use |

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| LICENSE missing (public repo) | Block |
| Service repo with MIT/BSD/Apache-2.0 | Warn - services should use AGPL-3.0 to ensure network use triggers copyleft |
| Library repo with AGPL-3.0 | Warn - may limit adoption |
| MIT/BSD instead of Apache-2.0 | Warn - Apache-2.0 provides patent protection |

**AGPL-3.0 Additional Requirements:**
- Include notice in README: "This software is licensed under AGPL-3.0. Network use constitutes distribution."
- Add AGPL badge: `![License](https://img.shields.io/badge/license-AGPL--3.0-blue)`

**License Compliance Checking:**
- Use tools like `license-checker`, `go-licenses`, or `fossa` to audit dependencies
- Document third-party licenses in `THIRD_PARTY_LICENSES.md` for projects with many dependencies
- Block commits that introduce GPL-incompatible dependencies into Apache-2.0 projects

---

## SECURITY.md Requirements

**Required for:** All public repositories

**Template:**

```markdown
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

Please report security vulnerabilities via [security@fyrsmithlabs.com](mailto:security@fyrsmithlabs.com).

**Do NOT report security vulnerabilities through public GitHub issues.**

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Response Timeline

- **Acknowledgment:** Within 48 hours
- **Initial Assessment:** Within 7 days
- **Resolution Target:** Within 90 days (critical: 30 days)

## Security Measures

- All commits scanned with gitleaks
- Dependencies monitored via Dependabot/Renovate
- SBOM generated for releases

## Disclosure Policy

We follow coordinated disclosure. We request 90 days to address vulnerabilities before public disclosure.
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| SECURITY.md missing (public repo) | Block |
| No contact method for reporting | Warn |
| No supported versions table | Warn |

---

## CODEOWNERS Requirements

**Purpose:** Define code ownership for automated review assignment.

**Location:** `.github/CODEOWNERS` or `CODEOWNERS` (root)

**Template:**

```
# Default owners for everything
* @fyrsmithlabs/maintainers

# Specific ownership
/api/           @fyrsmithlabs/api-team
/internal/auth/ @fyrsmithlabs/security-team
/docs/          @fyrsmithlabs/docs-team

# Security-sensitive files require security team review
SECURITY.md     @fyrsmithlabs/security-team
.gitleaks.toml  @fyrsmithlabs/security-team
*.pem           @fyrsmithlabs/security-team
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| CODEOWNERS missing | Block |
| No default owner (`*`) | Warn |
| Security files without security team | Warn |

---

## CONTRIBUTING.md Requirements

**Purpose:** Guide external and internal contributors.

**Template:**

```markdown
# Contributing to [Project Name]

## Code of Conduct

This project follows our [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/repo-name`
3. Create a branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Run tests: `make test`
6. Commit using conventional commits: `git commit -m "feat: add feature"`
7. Push and create a PR

## Development Setup

[Include prerequisites, build instructions, test commands]

## Pull Request Process

1. Update README.md and CHANGELOG.md if needed
2. Ensure all tests pass
3. Request review from CODEOWNERS
4. Squash and merge after approval

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation only
- `chore:` maintenance

## Reporting Issues

Use GitHub Issues with the appropriate template.
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| CONTRIBUTING.md missing (public repo) | Warn |
| No development setup instructions | Warn |
| No commit message guidelines | Warn |

---

## Issue and PR Templates

### Issue Templates

**Location:** `.github/ISSUE_TEMPLATE/`

**Bug Report (`bug_report.md`):**

```markdown
---
name: Bug Report
about: Report a bug to help us improve
title: '[BUG] '
labels: bug, triage
assignees: ''
---

## Description
A clear description of the bug.

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. See error

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Environment
- OS: [e.g., macOS 14.0]
- Version: [e.g., v1.2.3]
- Go version: [e.g., 1.22]

## Additional Context
Any other context, logs, or screenshots.
```

**Feature Request (`feature_request.md`):**

```markdown
---
name: Feature Request
about: Suggest a new feature
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

## Problem Statement
What problem does this solve?

## Proposed Solution
How should this work?

## Alternatives Considered
What other approaches did you consider?

## Additional Context
Any other context or mockups.
```

### Pull Request Template

**Location:** `.github/PULL_REQUEST_TEMPLATE.md`

```markdown
## Summary
Brief description of changes.

## Type of Change
- [ ] Bug fix (non-breaking)
- [ ] New feature (non-breaking)
- [ ] Breaking change
- [ ] Documentation update

## Changes Made
- Change 1
- Change 2

## Testing
- [ ] Tests pass locally
- [ ] New tests added for changes
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-reviewed my code
- [ ] Updated documentation if needed
- [ ] Updated CHANGELOG.md
- [ ] No secrets or credentials committed

## Related Issues
Closes #XXX
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| No issue templates | Warn |
| No PR template | Warn |
| Missing required fields in templates | Warn |

---

## ADR (Architecture Decision Records)

**Location:** `docs/adr/`

**Purpose:** Document significant architectural decisions with context.

**Naming Convention:** `NNNN-title-in-kebab-case.md` (e.g., `0001-use-postgresql-for-persistence.md`)

**Template:**

```markdown
# ADR-NNNN: Title

**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-XXXX
**Date:** YYYY-MM-DD
**Authors:** @username

## Context

What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult to do because of this change?

### Positive
- Benefit 1
- Benefit 2

### Negative
- Drawback 1
- Drawback 2

### Neutral
- Trade-off 1

## Alternatives Considered

### Alternative 1
Description and why it was rejected.

### Alternative 2
Description and why it was rejected.
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| `docs/adr/` directory missing | Warn |
| ADR without status field | Warn |
| Major architectural change without ADR | Warn |

---

## Branching Strategy

**Model:** GitHub Flow (trunk-based)

```
main (protected)
  └── feature/short-description
  └── fix/issue-number-description
  └── chore/cleanup-description
```

**Branch Naming Pattern:** `[type]/[description]`

| Type | Purpose | Example |
|------|---------|---------|
| `feature/` | New functionality | `feature/plugin-search` |
| `fix/` | Bug fixes | `fix/123-auth-timeout` |
| `chore/` | Maintenance, deps | `chore/update-deps` |
| `docs/` | Documentation only | `docs/api-reference` |
| `refactor/` | Code restructuring | `refactor/auth-module` |
| `release/` | Release prep | `release/1.2.0` |

**Blocked Patterns:**

| Pattern | Reason |
|---------|--------|
| Direct push to `main` | Must use PR |
| `john/thing`, `wip/stuff` | No personal/vague names |
| `FEATURE/CAPS` | Lowercase only |
| `feature_underscore` | Use hyphens |
| Branch name > 50 chars | Too long |

**Protected Branch Rules (main):**
- Require PR with at least 1 approval
- Require CI passing
- Require gitleaks check passing
- No force push
- No deletion

---

## Branch Protection Configuration

**Required Settings (GitHub):**

```yaml
# Recommended branch protection rules for main
protection_rules:
  main:
    required_pull_request_reviews:
      required_approving_review_count: 1
      dismiss_stale_reviews: true
      require_code_owner_reviews: true
      require_last_push_approval: true
    required_status_checks:
      strict: true
      contexts:
        - "ci/test"
        - "ci/lint"
        - "security/gitleaks"
        - "security/dependency-review"
    enforce_admins: true
    required_linear_history: true
    allow_force_pushes: false
    allow_deletions: false
    required_conversation_resolution: true
```

**Enforcement Tiers:**

| Tier | Settings | Repos |
|------|----------|-------|
| **Standard** | 1 approval, CI required, gitleaks | All repos |
| **Enhanced** | 2 approvals, CODEOWNERS, linear history | Production services |
| **Critical** | 3 approvals, security team review, signed commits | Security-sensitive |

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| No branch protection on main | Block |
| Allows force push to main | Block |
| No required status checks | Warn |
| CODEOWNERS review not required | Warn |

---

## Commit Conventions

**Format:** [Conventional Commits](https://www.conventionalcommits.org/)

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Commit Types:**

| Type | Purpose | CHANGELOG Category |
|------|---------|-------------------|
| `feat` | New feature | Added |
| `fix` | Bug fix | Fixed |
| `docs` | Documentation only | - |
| `style` | Formatting, no code change | - |
| `refactor` | Code restructuring | Changed |
| `perf` | Performance improvement | Changed |
| `test` | Adding/updating tests | - |
| `chore` | Maintenance, deps, CI | - |
| `build` | Build system changes | - |
| `ci` | CI/CD changes | - |
| `revert` | Revert previous commit | Removed |

**Breaking Changes:**
```
feat(api)!: remove deprecated endpoints

BREAKING CHANGE: /v1/users endpoint removed, use /v2/users
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| No type prefix | Warn |
| Type not in allowed list | Warn |
| Description > 72 chars | Warn |
| Description starts with capital | Warn |
| Description ends with period | Warn |

**Scope:** Use package/module name (`auth`, `api`, `db`) or feature area (`search`, `billing`)

---

## Gitleaks & Security

**Required:** Every repo must have gitleaks enabled.

**Configuration Methods (any one):**

| Method | File |
|--------|------|
| Config file | `.gitleaks.toml` |
| CI workflow | `.github/workflows/*` with gitleaks action |
| Pre-commit hook | `.pre-commit-config.yaml` with gitleaks |

**Minimum `.gitleaks.toml`:**

```toml
[extend]
useDefault = true

[allowlist]
description = "Project-specific allowlist"
paths = [
    '''docs/.claude/''',
    '''vendor/''',
    '''testdata/''',
]
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| No gitleaks config or CI job | Block |
| Secrets detected in commit | Block |
| Secrets in git history | Block PR + require history rewrite |
| `.env` files not in .gitignore | Block |
| Hardcoded API keys/tokens | Block |

**Remediation on Detection:**
1. Remove secret from code
2. Rotate the exposed credential immediately
3. Use `git filter-branch` or BFG to purge from history
4. Add to `.gitleaks.toml` allowlist only if false positive

---

## GitHub Actions Workflow Templates

**Location:** `.github/workflows/`

### CI Workflow (`ci.yml`)

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version-file: 'go.mod'
      - name: Test
        run: go test -race -coverprofile=coverage.out ./...
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: coverage.out

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: golangci/golangci-lint-action@v6
        with:
          version: latest

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      - name: Dependency Review
        uses: actions/dependency-review-action@v4
        if: github.event_name == 'pull_request'
```

### Security Scanning (`security.yml`)

```yaml
name: Security

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday 6am

permissions:
  contents: read
  security-events: write

jobs:
  codeql:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: go
      - name: Build
        run: go build ./...
      - name: Analyze
        uses: github/codeql-action/analyze@v3

  trivy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Trivy vulnerability scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'
```

### Release with SBOM (`release.yml`)

```yaml
name: Release

on:
  push:
    tags: ['v*']

permissions:
  contents: write
  packages: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Setup Go
        uses: actions/setup-go@v5
        with:
          go-version-file: 'go.mod'
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          artifact-name: sbom.spdx.json
          output-file: sbom.spdx.json
      - name: Release
        uses: goreleaser/goreleaser-action@v6
        with:
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| No CI workflow | Block |
| No gitleaks in CI | Block |
| No dependency review | Warn |
| No CodeQL/security scanning | Warn |
| No SBOM generation for releases | Warn |

---

## Pre-commit Hooks

**Configuration:** `.pre-commit-config.yaml`

**Recommended Configuration:**

```yaml
repos:
  # General hooks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-merge-conflict
      - id: detect-private-key
      - id: no-commit-to-branch
        args: ['--branch', 'main']

  # Secrets detection
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.4
    hooks:
      - id: gitleaks

  # Conventional commits
  - repo: https://github.com/compilerla/conventional-pre-commit
    rev: v3.4.0
    hooks:
      - id: conventional-pre-commit
        stages: [commit-msg]

  # Go-specific
  - repo: https://github.com/golangci/golangci-lint
    rev: v1.61.0
    hooks:
      - id: golangci-lint

  # JavaScript/TypeScript (if applicable)
  - repo: https://github.com/pre-commit/mirrors-eslint
    rev: v9.11.1
    hooks:
      - id: eslint
        files: \.[jt]sx?$

  # Python (if applicable)
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.9
    hooks:
      - id: ruff
      - id: ruff-format
```

**Installation:**
```bash
# Install pre-commit
pip install pre-commit  # or: brew install pre-commit

# Install hooks in repo
pre-commit install
pre-commit install --hook-type commit-msg

# Run on all files (first time)
pre-commit run --all-files
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| No `.pre-commit-config.yaml` | Warn |
| Missing gitleaks hook | Warn |
| Missing conventional-pre-commit | Warn |
| Missing language-specific linter | Warn |

---

## Dependency Scanning

**Purpose:** Automatically detect and update vulnerable or outdated dependencies.

### Dependabot Configuration

**Location:** `.github/dependabot.yml`

```yaml
version: 2
updates:
  # Go dependencies
  - package-ecosystem: "gomod"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
    open-pull-requests-limit: 10
    commit-message:
      prefix: "chore(deps):"
    labels:
      - "dependencies"
      - "go"

  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    commit-message:
      prefix: "chore(ci):"
    labels:
      - "dependencies"
      - "ci"

  # Docker (if applicable)
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
    commit-message:
      prefix: "chore(docker):"
```

### Renovate Alternative

**Location:** `renovate.json`

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": [
    "config:recommended",
    ":semanticCommits",
    ":preserveSemverRanges",
    "group:allNonMajor"
  ],
  "labels": ["dependencies"],
  "vulnerabilityAlerts": {
    "enabled": true,
    "labels": ["security"]
  },
  "packageRules": [
    {
      "matchUpdateTypes": ["major"],
      "labels": ["major-update"]
    }
  ]
}
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| No Dependabot or Renovate config | Warn |
| Vulnerability alerts disabled | Block |
| Major updates not labeled | Warn |
| No GitHub Actions updates configured | Warn |

---

## SBOM (Software Bill of Materials)

**Purpose:** Document all dependencies for supply chain security and compliance.

**Required for:** All production services and public releases.

**Generation Methods:**

| Tool | Format | Best For |
|------|--------|----------|
| `syft` | SPDX, CycloneDX | General purpose, multi-language |
| `cyclonedx-gomod` | CycloneDX | Go projects |
| `trivy` | SPDX, CycloneDX | Container images |
| `anchore/sbom-action` | SPDX | GitHub Actions integration |

**SBOM in Release Process:**

```bash
# Generate SBOM with syft
syft . -o spdx-json=sbom.spdx.json

# Generate SBOM with cyclonedx-gomod
cyclonedx-gomod mod -output sbom.xml

# Include in release artifacts
gh release upload v1.2.3 sbom.spdx.json
```

**SBOM Requirements:**

| Requirement | Purpose |
|-------------|---------|
| Include in all releases | Supply chain transparency |
| Use standardized format (SPDX or CycloneDX) | Interoperability |
| Sign SBOM with release signing key | Integrity verification |
| Store in release artifacts | Accessibility |

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| Release without SBOM (production service) | Warn |
| Non-standard SBOM format | Warn |
| SBOM not included in release artifacts | Warn |

---

## OpenSSF Best Practices

**Purpose:** Demonstrate security posture through the [OpenSSF Best Practices](https://www.bestpractices.dev/) program.

**Badge Levels:**

| Level | Requirements | Recommended For |
|-------|--------------|-----------------|
| **Passing** | Basic security practices | All public repos |
| **Silver** | Enhanced security, signed releases | Production services |
| **Gold** | Comprehensive security program | Critical infrastructure |

**Key Criteria:**

| Category | Requirements |
|----------|--------------|
| Basics | README, LICENSE, CHANGELOG, issue tracker |
| Change Control | Version control, unique versioning, release notes |
| Reporting | Security contact, vulnerability process |
| Quality | Test suite, CI, static analysis |
| Security | Hardening, crypto, vulnerability response |

**Getting Started:**

1. Go to [bestpractices.dev](https://www.bestpractices.dev/)
2. Sign in with GitHub
3. Add your project
4. Complete the questionnaire
5. Add badge to README

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| Public repo without OpenSSF badge | Warn |
| OpenSSF score below passing | Warn |
| Production service without Silver level | Warn |

---

## .gitignore Requirements

**Universal (All Projects):**

```gitignore
# Agent artifacts
docs/.claude/

# Environment & secrets
.env
.env.*
!.env.example
*.pem
*.key

# IDE & editors
.idea/
.vscode/
*.swp
*.swo
*~

# OS artifacts
.DS_Store
Thumbs.db

# Build outputs
dist/
build/
out/
```

**Go-Specific:**

```gitignore
# Binaries
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test artifacts
*.test
*.out
coverage.html
coverage.txt

# Build
bin/
```

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| .gitignore missing | Block |
| `docs/.claude/` not ignored | Block |
| `.env` not ignored | Block |
| IDE folders not ignored | Warn |
| OS artifacts not ignored | Warn |

---

## Review Mode Checklist

When reviewing a repository, check:

### Critical (Block)
- [ ] Repository name follows `[domain]-[type]` pattern
- [ ] No secrets in codebase or git history
- [ ] LICENSE file exists and matches project type
- [ ] README.md exists with required sections
- [ ] CHANGELOG.md exists with proper format
- [ ] .gitignore exists with required patterns
- [ ] .gitleaks.toml or CI gitleaks configured
- [ ] `docs/.claude/` is gitignored
- [ ] No agent artifacts in repo root
- [ ] SECURITY.md exists (public repos)
- [ ] CODEOWNERS file exists
- [ ] Main branch has protection enabled

### Required (Block)
- [ ] `.env` patterns gitignored
- [ ] Service repos use AGPL-3.0
- [ ] CI workflow exists with tests
- [ ] Gitleaks enabled in CI
- [ ] Vulnerability alerts enabled

### Style (Warn)
- [ ] Directory structure matches language conventions
- [ ] Branch naming follows conventions
- [ ] README has all recommended sections
- [ ] Required badges present (Build, License, Gitleaks, OpenSSF)
- [ ] CONTRIBUTING.md exists (public repos)
- [ ] Issue and PR templates exist
- [ ] ADR directory exists (`docs/adr/`)
- [ ] Pre-commit hooks configured
- [ ] Dependabot or Renovate configured
- [ ] SBOM generation in release workflow
- [ ] OpenSSF Best Practices badge

---

## Generate Mode

When creating a new repository:

### Phase 1: Core Setup
1. Validate repository name against naming rules
2. Determine project type (Go service, Go lib, generic, monorepo, polyglot)
3. Determine license (Apache-2.0 for libs, AGPL-3.0 for services)
4. Create directory structure from templates
5. Generate README.md with badges (Build, License, Gitleaks, OpenSSF placeholder)
6. Generate CHANGELOG.md with Unreleased section
7. Generate appropriate LICENSE file
8. Generate .gitignore for language

### Phase 2: Security Configuration
9. Generate .gitleaks.toml
10. Generate SECURITY.md (public repos)
11. Generate CODEOWNERS file
12. Generate .pre-commit-config.yaml
13. Generate .github/dependabot.yml

### Phase 3: CI/CD Setup
14. Generate .github/workflows/ci.yml (test, lint, security)
15. Generate .github/workflows/security.yml (CodeQL, Trivy)
16. Generate .github/workflows/release.yml (with SBOM generation)

### Phase 4: Documentation
17. Generate CONTRIBUTING.md (public repos)
18. Generate .github/ISSUE_TEMPLATE/bug_report.md
19. Generate .github/ISSUE_TEMPLATE/feature_request.md
20. Generate .github/PULL_REQUEST_TEMPLATE.md
21. Create docs/adr/ directory

### Phase 5: Initialization
22. Initialize git with main branch
23. Create initial commit: `chore: initial repository setup`
24. Configure branch protection (if GitHub CLI available)
25. Output next steps for manual configuration (OpenSSF badge, etc.)

Use templates from `${CLAUDE_PLUGIN_ROOT}/skills/git-repo-standards/templates/`

### Monorepo-Specific Steps
For monorepo projects, additionally:
- Generate workspace configuration (nx.json, turbo.json, go.work, or lerna.json)
- Create apps/ and packages/ directories
- Generate per-package CHANGELOG files if using independent versioning
- Configure CI matrix for affected packages only

### Polyglot-Specific Steps
For multi-language projects, additionally:
- Create language-specific subdirectories (backend/, frontend/)
- Generate Makefile with unified commands
- Generate docker-compose.yml for local development
- Configure CI to run language-specific tests in parallel
