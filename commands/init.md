---
name: init
description: Use when setting up a project to follow fyrsmithlabs standards. Works for new or existing repos - detects state automatically. Validates against git-repo-standards and configures git-workflows. Say "init this repo", "initialize project", "set up standards", or "make this follow fyrsmithlabs standards".
---

# /init Command

Set up any project to follow fyrsmithlabs standards.

## Usage

```
/init                 # Initialize/setup current project
/init --check         # Audit only, don't modify files
```

## What It Does

1. **Detect project state** - New repo or existing codebase?
2. **Audit against standards** - Check git-repo-standards compliance
3. **Show gap report** - What's missing or incomplete
4. **Fix gaps** - Generate missing files from templates (with confirmation)
5. **Configure workflows** - Set up git-workflows integration
6. **Record in contextd** - Remember this project's setup

## What Gets Checked

**Repository Standards:**
- Naming convention (`[domain]-[type]` kebab-case)
- README.md with badges
- CHANGELOG.md with `[Unreleased]`
- LICENSE (Apache-2.0 for libs/tools, AGPL-3.0 for services)
- .gitignore with `docs/.claude/`
- .gitleaks.toml

**Go-Specific (if detected):**
- go.mod exists
- cmd/ for services
- internal/ for private code
- No /src directory

**Workflow Standards:**
- .github/fyrsmith-workflow.yml
- PR template
- Branch protection guidance

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

- `memory_search` - Past init patterns for this project type
- `semantic_search` - Understand existing structure
- `remediation_search` - Known setup pitfalls
- `memory_record` - Record outcome for future reference

## Example

```
/init

Analyzing project...

Gap Report:
  ✓ README.md exists
  ✗ Missing CHANGELOG.md
  ✗ Missing .gitleaks.toml
  ✓ LICENSE exists (Apache-2.0)
  ✗ .gitignore missing docs/.claude/

Create missing files? [Y/n]
```
