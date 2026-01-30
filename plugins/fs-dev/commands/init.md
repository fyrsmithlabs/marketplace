---
name: init
description: Use when setting up a project to follow fyrsmithlabs standards. Works for new or existing repos - detects state automatically. Validates against git-repo-standards, generates CLAUDE.md based on project type, and configures git-workflows. Say "init this repo", "initialize project", "set up standards", or "make this follow fyrsmithlabs standards".
arguments:
  - name: check
    description: "Audit only, no modifications (--check)"
    required: false
  - name: quick
    description: "Skip wizard, use auto-detection (--quick)"
    required: false
  - name: validate
    description: "Validate existing setup, check for staleness (--validate)"
    required: false
---

# /init Command

Set up any project to follow fyrsmithlabs standards with interactive configuration.

## Usage

```
/init                 # Full interactive setup wizard
/init --check         # Audit only, don't modify files
/init --quick         # Skip wizard, use auto-detection
/init --validate      # Validate existing setup, check for staleness
```

## What It Does

### Full Init (default)

1. **Pre-Flight Detection** - Auto-detect project type, language, framework
2. **Interactive Wizard** - Confirm detection, configure tooling, set CLAUDE.md focus
3. **Language Bootstrap** - Configure language-specific tooling (linters, formatters)
4. **CLAUDE.md Generation** - Create project-specific documentation
5. **Compliance Check** - Validate against git-repo-standards
6. **Gap Remediation** - Fix missing/incorrect files from templates
7. **Validation Checksum** - Store configuration state for staleness detection
8. **Memory Recording** - Record outcome in contextd (if available)

### Audit Only (--check)

Run compliance checks without making changes. Produces gap report only.

### Quick Mode (--quick)

Skip interactive wizard, use auto-detected values for everything.
Good for CI/automation or when you trust auto-detection.

### Validate Mode (--validate)

Check if configuration has drifted since init:
- Compare current files against stored checksum
- Run integration health checks (CI, hooks, gitleaks)
- Report staleness and recommend re-running init

## What Gets Checked

**Repository Standards:**
- Naming convention (`[domain]-[type]` kebab-case)
- README.md with badges and required sections
- CHANGELOG.md with `[Unreleased]`
- LICENSE (Apache-2.0 for libs/tools, AGPL-3.0 for services)
- CLAUDE.md with project-specific content
- .gitignore with `docs/.claude/`
- .gitleaks.toml

**Language-Specific (auto-detected):**

| Language | Checks |
|----------|--------|
| Go | go.mod, cmd/, internal/, .golangci.yml |
| Node.js/TS | package.json, tsconfig.json, linter config, lockfile |
| Python | pyproject.toml, linter config, .python-version |
| Rust | Cargo.toml, rustfmt.toml |

**Workflow Standards:**
- .github/workflows/*.yml (CI configured)
- .github/fyrsmith-workflow.yml (consensus review)
- .github/pull_request_template.md

**Integration Health:**
- CI configured and passing
- Pre-commit hooks installed
- Gitleaks active
- Tests runnable
- Lint passing

## Interactive Wizard Steps

When running without --quick:

1. **Project Type Confirmation** - Verify auto-detected type (API/CLI/Library/WebApp/Monorepo)
2. **Language/Framework Confirmation** - Verify detected tech stack
3. **Tooling Selection** - Choose what to configure (linting, testing, CI, hooks, Docker)
4. **CLAUDE.md Focus** - Select emphasis (Standard/Security/Performance/API/TDD)

## Templates Used

From `git-repo-standards`:
- README.md.tmpl
- CHANGELOG.md.tmpl
- gitignore-go.tmpl / gitignore-generic.tmpl
- gitleaks.toml.tmpl

From `git-workflows`:
- fyrsmith-workflow.yml.tmpl
- pr-template.md.tmpl

From `init/templates` (CLAUDE.md by project type):
- claude-md-service.tmpl
- claude-md-cli.tmpl
- claude-md-library.tmpl
- claude-md-webapp.tmpl
- claude-md-monorepo.tmpl

## contextd Integration (Optional)

If contextd MCP is available:
- `memory_search` - Past init patterns for this project type
- `semantic_search` - Understand existing structure
- `remediation_search` - Known setup pitfalls
- `memory_record` - Record outcome for future reference

If contextd is NOT available:
- Init still works fully (file-based fallback)
- No cross-session pattern learning

## Examples

### Full Interactive Init

```
/init

Detecting project...
  Type: API/Service
  Language: Go
  Framework: Standard library

Detected: Go API/Service. Is this correct?
  > Yes, Go API/Service
    CLI Tool
    Library
    ...

What tooling should be configured?
  [x] Linting & Formatting
  [x] Testing Framework
  [x] CI/CD Pipeline
  [ ] Pre-commit Hooks
  [ ] Docker

What should CLAUDE.md emphasize?
  > Standard
    Security-focused
    ...

Running compliance check...

Gap Report:
  OK README.md (has badges)
  MISSING CHANGELOG.md
  MISSING .gitleaks.toml
  OK LICENSE (Apache-2.0)
  MISSING CLAUDE.md
  MISSING .gitignore docs/.claude/

Found 4 gaps to fix. Proceed? [Fix all / Review each / Abort]
```

### Validate Existing Setup

```
/init --validate

Validation Report:
  Checksum: STALE (configuration changed)
  README.md: Valid
  CLAUDE.md: Modified (manual changes detected)
  .gitignore: Valid
  CI: Configured
  Gitleaks: Active
  Tests: Passing
  Lint: Passing

Recommendation: Run `/init` to update configuration
```
