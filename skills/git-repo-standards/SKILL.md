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
| **Critical** | Block | Secrets detected, missing LICENSE/README/CHANGELOG/.gitignore, gitleaks not configured, agent artifacts in repo root, invalid repo naming |
| **Required** | Block | `.env` not gitignored, `docs/.claude/` not gitignored, service repo missing AGPL-3.0 |
| **Style** | Warn | Incomplete README sections, non-conventional commits, missing badges, suboptimal structure, outdated copyright year |

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
├── .gitignore
├── .gitleaks.toml
├── CHANGELOG.md
├── LICENSE
├── README.md
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
├── .gitignore
├── .gitleaks.toml
├── CHANGELOG.md
├── LICENSE
└── README.md
```

### Anti-Patterns

| Pattern | Action | Reason |
|---------|--------|--------|
| `/src` in Go project | Warn | Java convention, not Go |
| `TODO.md`, `PLAN.md` in root | Block | Agent artifacts must go to `docs/.claude/` |
| `*.task`, `*.orchestration` in root | Block | Agent artifacts must go to `docs/.claude/` |
| Missing `internal/` for 3+ packages | Warn | Exposes private APIs |
| Deep nesting (>3 levels) | Warn | Go prefers shallow hierarchies |

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

**Badge Placement:**
```markdown
# repo-name

![Build](...)  ![Go](...)  ![License](...)  ![Gitleaks](...)

One-line description of what this repo does.
```

### Recommended Sections (Warn if missing)

| Section | Purpose |
|---------|---------|
| Prerequisites | Required tools, versions, dependencies |
| Configuration | Environment variables, config files |
| Development | How to set up local dev environment |
| Testing | How to run tests |
| Contributing | Link to CONTRIBUTING.md or inline guidelines |

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

**Enforcement Rules:**

| Rule | Action |
|------|--------|
| LICENSE missing (public repo) | Block |
| Service repo with Apache-2.0 | Warn - suggest AGPL-3.0 |
| Library repo with AGPL-3.0 | Warn - may limit adoption |

**AGPL-3.0 Additional Requirements:**
- Include notice in README: "This software is licensed under AGPL-3.0. Network use constitutes distribution."
- Add AGPL badge: `![License](https://img.shields.io/badge/license-AGPL--3.0-blue)`

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

- [ ] Repository name follows `[domain]-[type]` pattern
- [ ] Directory structure matches language conventions
- [ ] No agent artifacts in repo root
- [ ] README.md exists with required sections and badges
- [ ] CHANGELOG.md exists with proper format
- [ ] LICENSE file exists and matches project type
- [ ] .gitignore exists with required patterns
- [ ] .gitleaks.toml or CI gitleaks configured
- [ ] `docs/.claude/` is gitignored
- [ ] No secrets in codebase or git history
- [ ] Branch naming follows conventions
- [ ] Main branch is protected

---

## Generate Mode

When creating a new repository:

1. Validate repository name against naming rules
2. Determine project type (Go service, Go lib, generic)
3. Determine license (Apache-2.0 for libs, AGPL-3.0 for services)
4. Create directory structure from templates
5. Generate README.md with badges
6. Generate CHANGELOG.md with Unreleased section
7. Generate appropriate LICENSE file
8. Generate .gitignore for language
9. Generate .gitleaks.toml
10. Initialize git with main branch
11. Create initial commit: `chore: initial repository setup`

Use templates from `${CLAUDE_PLUGIN_ROOT}/skills/git-repo-standards/templates/`
