---
name: project-onboarding
description: Use when initializing new projects or onboarding existing repos to fyrsmithlabs workflow standards - validates compliance, generates missing artifacts, and configures git-repo-standards + git-workflows
---

# Project Onboarding

Initialize new projects or onboard existing repos to fyrsmithlabs standards. Validates compliance with `git-repo-standards` and configures `git-workflows` consensus review.

## Modes

| Mode | Trigger | Purpose |
|------|---------|---------|
| **Init** | New empty repo | Scaffold from scratch with all standards |
| **Onboard** | Existing repo | Audit, fix gaps, add missing pieces |
| **Validate** | Any repo | Check compliance without modifications |

---

## Pre-Flight (contextd)

**MANDATORY before onboarding:**

```
1. mcp__contextd__memory_search(
     project_id: "<project>",
     query: "onboarding patterns project setup"
   )
   → Check for past onboarding learnings

2. mcp__contextd__semantic_search(
     query: "project configuration setup",
     project_path: "."
   )
   → Understand existing structure

3. mcp__contextd__remediation_search(
     query: "onboarding setup errors",
     tenant_id: "<tenant>",
     include_hierarchy: true
   )
   → Pre-load known setup pitfalls
```

---

## Compliance Checklist

### Repository Standards (git-repo-standards)

| Item | Required | Check |
|------|----------|-------|
| **Naming** | Yes | Repo name follows `[domain]-[type]` pattern |
| **README.md** | Yes | Exists with required sections + badges |
| **CHANGELOG.md** | Yes | Exists with `[Unreleased]` section |
| **LICENSE** | Yes (public) | Exists, matches project type (Apache-2.0 or AGPL-3.0) |
| **.gitignore** | Yes | Exists with `docs/.claude/` ignored |
| **.gitleaks.toml** | Yes | Exists or gitleaks configured in workflows |
| **docs/.claude/** | Yes | Directory exists and is gitignored |
| **No root artifacts** | Yes | No TODO.md, PLAN.md, *.task in repo root |

### Go-Specific (if Go project)

| Item | Required | Check |
|------|----------|-------|
| **go.mod** | Yes | Exists with valid module path |
| **cmd/** | If service | Entry points for executables |
| **internal/** | Recommended | Private packages |
| **No /src** | Yes | Avoid Java-style src directory |

### Workflow Standards (git-workflows)

| Item | Required | Check |
|------|----------|-------|
| **.github/fyrsmith-workflow.yml** | Yes | Consensus review config exists |
| **Branch protection** | Yes | Main branch protected |
| **PR template** | Recommended | `.github/pull_request_template.md` exists |
| **Gitleaks configured** | Yes | Security scanning enabled |

---

## Init Mode (New Project)

For brand new repositories:

### Step 1: Gather Project Info

```
Ask user:
1. Project name (will validate against naming rules)
2. Project type: library | service | cli | tool
3. Language: go | typescript | python | other
4. Description (one sentence)
5. Is this public? (determines license requirement)
```

### Step 2: Validate Name

```
Check against git-repo-standards naming rules:
- Lowercase kebab-case
- Max 50 characters
- Starts with letter
- Only a-z, 0-9, -
- No consecutive hyphens
- Descriptive (not generic like "backend")
```

### Step 3: Generate Structure

**For Go service:**
```
repo-name/
├── cmd/
│   └── repo-name/
│       └── main.go
├── internal/
│   └── .gitkeep
├── pkg/
│   └── .gitkeep
├── api/
│   └── .gitkeep
├── docs/
│   ├── .claude/
│   │   └── .gitkeep
│   └── adr/
│       └── .gitkeep
├── configs/
│   └── .gitkeep
├── scripts/
│   └── .gitkeep
├── temporal/
│   └── .gitkeep
├── .github/
│   ├── pull_request_template.md
│   └── fyrsmith-workflow.yml
├── .gitignore
├── .gitleaks.toml
├── CHANGELOG.md
├── LICENSE
├── README.md
└── go.mod
```

**For Go library:**
```
repo-name/
├── internal/
│   └── .gitkeep
├── docs/
│   ├── .claude/
│   │   └── .gitkeep
│   └── adr/
│       └── .gitkeep
├── .github/
│   ├── pull_request_template.md
│   └── fyrsmith-workflow.yml
├── .gitignore
├── .gitleaks.toml
├── CHANGELOG.md
├── LICENSE
├── README.md
└── go.mod
```

### Step 4: Generate Files

Use templates from `git-repo-standards/templates/`:
- README.md.tmpl → README.md
- CHANGELOG.md.tmpl → CHANGELOG.md
- gitignore-go.tmpl → .gitignore (or gitignore-generic.tmpl)
- gitleaks.toml.tmpl → .gitleaks.toml

Use templates from `git-workflows/templates/`:
- fyrsmith-workflow.yml.tmpl → .github/fyrsmith-workflow.yml
- pr-template.md.tmpl → .github/pull_request_template.md

### Step 5: Determine License

```
IF project_type in [library, cli, tool]:
  license = Apache-2.0
ELSE IF project_type in [service, api, platform]:
  license = AGPL-3.0

Fetch license from authoritative source (see LICENSE-SOURCES.md)
Add copyright: "Copyright <year> fyrsmithlabs"
```

### Step 6: Initial Commit

```bash
git init
git add .
git commit -m "chore: initial repository setup

- Add fyrsmithlabs project structure
- Configure git-repo-standards compliance
- Configure git-workflows consensus review
- Add gitleaks security scanning

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Step 7: Record Memory

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Project initialized with fyrsmithlabs standards",
  content: "Type: [type], Language: [lang], License: [license].
            Structure: [summary]. Workflows configured.",
  outcome: "success",
  tags: ["onboarding", "init", "<project-type>", "<language>"]
)
```

---

## Onboard Mode (Existing Project)

For existing repositories that need to adopt standards:

### Step 1: Audit Current State

Run validation checklist and produce gap report:

```markdown
## Onboarding Audit: [repo-name]

### Repository Standards
| Check | Status | Action |
|-------|--------|--------|
| Naming convention | ✅ Pass | - |
| README.md | ⚠️ Missing badges | Add badges |
| CHANGELOG.md | ❌ Missing | Create |
| LICENSE | ✅ Pass | - |
| .gitignore | ⚠️ Missing docs/.claude/ | Update |
| .gitleaks.toml | ❌ Missing | Create |
| docs/.claude/ | ❌ Missing | Create |
| Root artifacts | ✅ Clean | - |

### Workflow Standards
| Check | Status | Action |
|-------|--------|--------|
| fyrsmith-workflow.yml | ❌ Missing | Create |
| PR template | ❌ Missing | Create |
| Gitleaks configured | ❌ Missing | Add config |

### Summary
- **Critical gaps:** 4
- **Warnings:** 2
- **Passing:** 5
```

### Step 2: Prioritize Fixes

```
Priority order:
1. Security (gitleaks, secrets)
2. Required files (README, LICENSE, CHANGELOG)
3. Workflow config (fyrsmith-workflow.yml)
4. Structure (docs/.claude/, .gitignore updates)
5. Enhancements (badges, PR template)
```

### Step 3: Apply Fixes

For each gap:
1. Generate missing file from template
2. Update existing file if needed
3. Create commit for each logical change

### Step 4: Verify (MANDATORY - No Partial Completion)

Re-run validation checklist. **ALL items MUST pass.**

**Partial onboarding is NOT acceptable:**
- Fixing only Critical gaps and leaving Warnings = NOT COMPLIANT
- "I'll fix the rest later" = NOT COMPLIANT
- "Good enough for now" = NOT COMPLIANT
- "Critical is different from Warnings" = NOT COMPLIANT
- "I can schedule a separate session for warnings" = NOT COMPLIANT

**There is NO distinction between "partial compliance" and "onboarding in progress."**
If you stop before 100% completion, you have failed the onboarding.

**Onboarding is complete when:**
- 0 Critical gaps remaining
- 0 Warnings remaining
- 100% compliance score

**If time-constrained:**
- Do NOT "fix what you can" - this creates tech debt
- Do NOT commit partial work
- Do NOT schedule "follow-up sessions" for warnings
- STOP and reschedule the ENTIRE onboarding for when you have enough time

The meeting can wait. Partial compliance cannot be committed.

### Step 5: Record Memory

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Project onboarded to fyrsmithlabs standards",
  content: "Gaps fixed: [list]. Changes: [summary].
            Now compliant with git-repo-standards and git-workflows.",
  outcome: "success",
  tags: ["onboarding", "existing-project", "<gaps-fixed>"]
)
```

---

## Validate Mode (Audit Only)

Check compliance without making changes:

```
1. Run full checklist
2. Produce compliance report
3. Score: X/Y checks passing
4. List actionable recommendations
5. Do NOT modify any files
```

Output format:

```markdown
## Compliance Report: [repo-name]

**Score:** 8/12 (67%)
**Status:** NOT COMPLIANT

### Critical (Must Fix)
- [ ] .gitleaks.toml missing
- [ ] docs/.claude/ not gitignored

### Required (Should Fix)
- [ ] CHANGELOG.md missing
- [ ] fyrsmith-workflow.yml missing

### Recommended (Nice to Have)
- [ ] Add badges to README
- [ ] Add PR template

### Passing
- [x] Repository naming
- [x] README.md exists
- [x] LICENSE exists
- [x] .gitignore exists
- [x] Go structure (cmd/, internal/)
- [x] No root artifacts
- [x] Branch protection enabled
```

---

## Quick Reference

| Command | Mode | Purpose |
|---------|------|---------|
| `/onboard init` | Init | New project from scratch |
| `/onboard` | Onboard | Add standards to existing project |
| `/onboard validate` | Validate | Audit without changes |

---

## Post-Flight

**After any onboarding operation:**

```
1. memory_record with outcome and details
2. If errors encountered:
   - remediation_record for novel issues
   - troubleshoot_diagnose for diagnosis
3. checkpoint_save if significant work done
```

---

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Fix critical only, warnings can wait" | Partial compliance is NOT compliance. Fix everything. |
| "I'll schedule a follow-up for warnings" | No. Either complete 100% now or don't start. |
| "Critical and warnings are different" | No. Both must be 0 for compliance. No distinction. |
| "I know the codebase, skip validation" | Validation catches what memory misses. Always validate first. |
| "I've done this before, skip pre-flight" | Each project is unique. Pre-flight is MANDATORY. |
| "Recording is just paperwork" | Memory recording enables future 20-minute onboardings. Do it fully. |
| "PR template is blocking us, do that first" | Follow priority order. Security before convenience. |
| "It's basically a new repo, use Init" | If ANY content exists, use Onboard. Init overwrites. |

---

## Red Flags - STOP and Reconsider

If you're thinking any of these, you're about to violate the skill:

- "Good enough for now"
- "I'll fix the rest later"
- "Warnings aren't critical"
- "I already know what's missing"
- "Pre-flight is just ceremony"
- "The work is done, skip recording"

**All of these mean: You're rationalizing. Follow the skill exactly.**

---

## Integration

This skill orchestrates:
- `git-repo-standards` - Structure, naming, files
- `git-workflows` - Review process, PR requirements

Both skills must be available for full onboarding.
