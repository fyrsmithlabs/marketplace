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

## Severity Tiers

All checklist items have a severity tier that determines action:

| Tier | Action | Description |
|------|--------|-------------|
| **Critical** | Block | Cannot proceed until fixed. Init cannot complete. |
| **Required** | Block | Must be fixed before init completes. |
| **Style** | Fix | Must be fixed. Lower priority but still required. |

**Critical Rule:** Init MUST achieve 100% pass rate on ALL checklist items. No exceptions - Critical, Required, AND Style items must all pass before init completes.

**Why Style Items Are Required:**
- Style items (badges, README sections, PR templates) affect discoverability and usability
- "Good enough" mindset leads to debt accumulation
- It's easier to fix now than create issues to fix later
- Projects should start fully compliant, not partially compliant

---

## Compliance Checklist

### Repository Standards (git-repo-standards)

| Item | Tier | Check |
|------|------|-------|
| **Naming** | Critical | Repo name follows `[domain]-[type]` pattern |
| **README.md** | Critical | Exists with required sections + badges |
| **CHANGELOG.md** | Critical | Exists with `[Unreleased]` section |
| **LICENSE** | Critical | Exists, matches project type |
| **.gitignore** | Critical | Exists with `docs/.claude/` ignored |
| **.gitleaks.toml** | Critical | Exists |
| **docs/.claude/** | Required | Directory exists and gitignored |

### Go-Specific (if detected)

| Item | Tier | Check |
|------|------|-------|
| **go.mod** | Critical | Exists with valid module path |
| **cmd/** | Required | Entry points for executables (services only) |
| **internal/** | Style | Private packages recommended |
| **No /src** | Required | Avoid Java-style src directory |

### Workflow Standards (git-workflows)

| Item | Tier | Check |
|------|------|-------|
| **fyrsmith-workflow.yml** | Required | Consensus review config exists |
| **PR template** | Style | `.github/pull_request_template.md` |

---

## Remediation Guidance

### Missing Files

For missing files, generate from templates:

| Missing | Action |
|---------|--------|
| README.md | Generate from `README.md.tmpl` |
| CHANGELOG.md | Generate from `CHANGELOG.md.tmpl` |
| LICENSE | Generate based on project type |
| .gitignore | Generate from language-specific template |
| .gitleaks.toml | Generate from `gitleaks.toml.tmpl` |

### Existing Incorrect Files

For files that exist but are incorrect:

| Issue | Remediation |
|-------|-------------|
| README missing sections | **Add** missing sections, preserve existing content |
| README missing badges | **Add** badges at top, keep existing badges |
| CHANGELOG wrong format | **Convert** to Keep a Changelog format, preserve entries |
| LICENSE wrong type | **Warn and recommend** change with migration guidance |
| .gitignore missing patterns | **Append** required patterns, keep existing |
| .gitleaks.toml incomplete | **Merge** required config, keep custom allowlist |

**License Change Protocol:**
When LICENSE type is incorrect (e.g., MIT for a service):
1. Warn with specific recommendation
2. Explain why the change matters
3. Note: changing license may require contributor consent
4. Create issue to track license migration
5. Do NOT auto-change license files

**Key Principle:** Init prefers **additive** changes over **destructive** ones. Existing content is preserved where possible.

---

## Process

### Step 1: Detect & Audit

1. Detect project state (new empty repo vs existing codebase)
2. Run validation checklist
3. Produce gap report

### Step 2: Show Gap Report

```markdown
## Init Audit: [repo-name]

| Check | Tier | Status | Action |
|-------|------|--------|--------|
| README.md | Style | ⚠️ Missing badges | Add badges |
| CHANGELOG.md | Critical | ❌ Missing | Create |
| .gitleaks.toml | Critical | ❌ Missing | Create |
| docs/.claude/ | Required | ❌ Missing | Create |

**Gaps:** 2 Critical, 1 Required, 1 Style - ALL must be fixed
```

### Step 3: Fix Gaps (with confirmation)

For each gap:
1. Generate missing file from template
2. Update existing file if needed
3. Create commit for logical changes

**Do NOT skip any gaps.** Even Style-tier items must be fixed.

### Step 4: Verify

Re-run checklist. **ALL items MUST pass.**

If ANY item fails (Critical, Required, OR Style):
- Init CANNOT complete
- Return to Step 3 and fix the failing item
- Do NOT proceed with "good enough" mindset

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
- "Style items don't really matter"
- "Only Critical items block"
- "I'll create an issue for the warnings"
- "I already know what's missing"
- "Most things are done"

**You're rationalizing. Follow the skill exactly.**

ALL items must pass - Critical, Required, AND Style. There are no "optional" checklist items.

---

## Integration

This skill orchestrates:
- `git-repo-standards` - Structure, naming, files
- `git-workflows` - Review process, PR requirements
