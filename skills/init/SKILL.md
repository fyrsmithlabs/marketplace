---
name: init
description: Use when setting up a project to follow fyrsmithlabs standards - validates compliance, generates missing artifacts, configures git-repo-standards + git-workflows. Works for new or existing repos.
---

# Init

Set up any project to follow fyrsmithlabs standards. Detects whether repo is new or existing and handles accordingly.

## Command

```
/init                 # Set up project
/init --check         # Audit only, no modifications
```

## Pre-Flight (contextd)

**MANDATORY before init:**

```
1. mcp__contextd__memory_search(project_id, "init setup patterns")
2. mcp__contextd__semantic_search(query: "project configuration", project_path: ".")
3. mcp__contextd__remediation_search(query: "setup errors", include_hierarchy: true)
```

---

## Compliance Checklist

### Repository Standards (git-repo-standards)

| Item | Required | Check |
|------|----------|-------|
| **Naming** | Yes | Repo name follows `[domain]-[type]` pattern |
| **README.md** | Yes | Exists with required sections + badges |
| **CHANGELOG.md** | Yes | Exists with `[Unreleased]` section |
| **LICENSE** | Yes | Exists, matches project type |
| **.gitignore** | Yes | Exists with `docs/.claude/` ignored |
| **.gitleaks.toml** | Yes | Exists |
| **docs/.claude/** | Yes | Directory exists and gitignored |

### Go-Specific (if detected)

| Item | Required | Check |
|------|----------|-------|
| **go.mod** | Yes | Exists with valid module path |
| **cmd/** | If service | Entry points for executables |
| **internal/** | Recommended | Private packages |
| **No /src** | Yes | Avoid Java-style src directory |

### Workflow Standards (git-workflows)

| Item | Required | Check |
|------|----------|-------|
| **fyrsmith-workflow.yml** | Yes | Consensus review config exists |
| **PR template** | Recommended | `.github/pull_request_template.md` |

---

## Process

### Step 1: Detect & Audit

1. Detect project state (new empty repo vs existing codebase)
2. Run validation checklist
3. Produce gap report

### Step 2: Show Gap Report

```markdown
## Init Audit: [repo-name]

| Check | Status | Action |
|-------|--------|--------|
| README.md | ⚠️ Missing badges | Add badges |
| CHANGELOG.md | ❌ Missing | Create |
| .gitleaks.toml | ❌ Missing | Create |
| docs/.claude/ | ❌ Missing | Create |

**Gaps:** 3 critical, 1 warning
```

### Step 3: Fix Gaps (with confirmation)

For each gap:
1. Generate missing file from template
2. Update existing file if needed
3. Create commit for logical changes

### Step 4: Verify

Re-run checklist. **ALL items MUST pass.**

### Step 5: Record Memory

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Project initialized with fyrsmithlabs standards",
  content: "Gaps fixed: [list]. Now compliant.",
  outcome: "success",
  tags: ["init", "<project-type>"]
)
```

---

## Templates Used

From `git-repo-standards/templates/`:
- README.md.tmpl
- CHANGELOG.md.tmpl
- gitignore-go.tmpl / gitignore-generic.tmpl
- gitleaks.toml.tmpl

From `git-workflows/templates/`:
- fyrsmith-workflow.yml.tmpl
- pr-template.md.tmpl

---

## License Selection

```
IF project_type in [library, cli, tool]:
  license = Apache-2.0
ELSE IF project_type in [service, api, platform]:
  license = AGPL-3.0
```

---

## Red Flags - STOP

If you're thinking:
- "Good enough for now"
- "I'll fix the rest later"
- "Warnings aren't critical"
- "I already know what's missing"

**You're rationalizing. Follow the skill exactly.**

---

## Integration

This skill orchestrates:
- `git-repo-standards` - Structure, naming, files
- `git-workflows` - Review process, PR requirements
