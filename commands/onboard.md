---
name: onboard
description: Use when setting up a new project, bringing an existing repo into compliance, or checking if a repo meets fyrsmithlabs standards. Validates against git-repo-standards and configures git-workflows. Say "onboard this repo", "initialize project", "check compliance", or "set up standards".
arguments:
  - name: mode
    description: "Mode: init (new project), onboard (existing), validate (audit only)"
    required: false
    default: "onboard"
---

# /onboard Command

Initialize new projects or onboard existing repos to fyrsmithlabs standards.

## Usage

```
/onboard              # Onboard existing project (default)
/onboard init         # Initialize new project from scratch
/onboard validate     # Audit compliance without changes
```

## Modes

### Default: Onboard Existing Project

1. Audit current repo against fyrsmithlabs standards
2. Produce gap report showing missing/incomplete items
3. Offer to fix gaps (with user confirmation)
4. Generate missing files from templates
5. Record onboarding in contextd memory

### Init: New Project Setup

1. Gather project info (name, type, language, description)
2. Validate name against naming conventions
3. Generate complete project structure
4. Create all required files from templates
5. Determine license (Apache-2.0 for libs, AGPL-3.0 for services)
6. Create initial commit
7. Record in contextd memory

### Validate: Audit Only

1. Run full compliance checklist
2. Produce compliance report with score
3. List actionable recommendations
4. Do NOT modify any files

## What Gets Checked

**Repository Standards:**
- Naming convention (`[domain]-[type]`)
- README.md with badges
- CHANGELOG.md with `[Unreleased]`
- LICENSE (Apache-2.0 or AGPL-3.0)
- .gitignore with `docs/.claude/`
- .gitleaks.toml
- No agent artifacts in root

**Go-Specific:**
- go.mod
- cmd/ for services
- internal/ for private code
- No /src directory

**Workflow Standards:**
- .github/fyrsmith-workflow.yml
- PR template
- Gitleaks configured
- Branch protection

## Templates Used

From `git-repo-standards`:
- README.md.tmpl
- CHANGELOG.md.tmpl
- gitignore-go.tmpl / gitignore-generic.tmpl
- gitleaks.toml.tmpl

From `git-workflows`:
- fyrsmith-workflow.yml.tmpl
- pr-template.md.tmpl

## contextd Integration

This command uses contextd for:
- `memory_search` - Past onboarding patterns
- `semantic_search` - Understand existing structure
- `remediation_search` - Known setup pitfalls
- `memory_record` - Record onboarding outcome

## Examples

```
# Onboard this repo to fyrsmithlabs standards
/onboard

# Create a new Go service
/onboard init
> Project name: auth-service
> Type: service
> Language: go
> Description: Authentication and authorization service
> Public: yes

# Check compliance without changing anything
/onboard validate
```
