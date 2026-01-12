---
name: github-planning
description: Use when creating GitHub Issues, making an epic, creating sub-issues, setting up a project board, or converting plans into GitHub artifacts. Creates tier-appropriate structures - SIMPLE (single issue with checklist), STANDARD (epic + sub-issues), COMPLEX (epic + sub-issues + project board).
---

# GitHub Planning

Create GitHub Issues and Projects instead of local markdown files for planning artifacts.

## When to Use

Called by `/brainstorm` Phase 6 after design is complete to create:
- **SIMPLE:** Single Issue with checklist
- **STANDARD:** Epic Issue + linked sub-Issues
- **COMPLEX:** Epic + sub-Issues + Project board

## Prerequisites

- `gh` CLI authenticated (`gh auth status`)
- Repository has GitHub remote configured
- Complexity tier determined (from complexity-assessment)

## Tier-Based Output

### SIMPLE Tier

Create single Issue with checkbox checklist:

```bash
gh issue create \
  --title "<feature-name>" \
  --label "task" \
  --body "$(cat <<'EOF'
## Overview
<1-2 sentence description>

## Tasks
- [ ] <task 1>
- [ ] <task 2>
- [ ] <task 3>

## Verification
| Type | Details | Expected |
|------|---------|----------|
| <type> | <command/steps> | <expected outcome> |

## Context
- Complexity: SIMPLE
- Created by: /brainstorm
EOF
)"
```

### STANDARD Tier

Create Epic Issue + sub-Issues:

**1. Create Epic:**
```bash
gh issue create \
  --title "[EPIC] <feature-name>" \
  --label "epic" \
  --body "$(cat <<'EOF'
## Overview
<description>

## Sub-Issues
<!-- Links will be added as sub-issues are created -->

## Success Criteria
<what done looks like>

## Context
- Complexity: STANDARD
- Created by: /brainstorm
EOF
)"
```

**2. Create Sub-Issues:**
```bash
# For each task:
gh issue create \
  --title "<task-name>" \
  --label "task" \
  --body "$(cat <<'EOF'
## Description
<task description>

## Verification
| Type | Details | Expected |
|------|---------|----------|
| <type> | <command/steps> | <expected outcome> |

## Parent
Contributes to #<epic-number>
EOF
)"
```

**3. Update Epic with sub-issue links**

### COMPLEX Tier

Create Epic + sub-Issues + Project board:

**1. Create Epic and Sub-Issues** (same as STANDARD)

**2. Create or use existing Project:**
```bash
# Check for existing project
gh project list --owner <owner> --format json | jq '.[] | select(.title == "<project-name>")'

# Create if needed
gh project create --owner <owner> --title "<feature-name>" --format json
```

**3. Add Issues to Project:**
```bash
# Add epic
gh project item-add <project-number> --owner <owner> --url <epic-url>

# Add sub-issues
gh project item-add <project-number> --owner <owner> --url <sub-issue-url>
```

## contextd Integration

Record created artifacts:

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "GitHub planning: <feature-name>",
  content: "Created: <issue-type>. URLs: <list>.
            Tier: <tier>. Tasks: <count>.",
  outcome: "success",
  tags: ["github-planning", "<tier>"]
)
```

## Error Handling

### gh CLI not authenticated
```
Error: gh auth status failed
Action: Run `gh auth login` to authenticate
```

### No GitHub remote
```
Error: No GitHub remote found
Action: Ensure repo has origin pointing to GitHub
```

### Rate limiting
```
Error: API rate limit exceeded
Action: Wait and retry, or use authenticated requests
```

## Cleanup

If planning is abandoned:
- Close draft issues
- Remove from project board
- Record cancellation in contextd

## Attribution

Adapted from Auto-Claude planning concepts. See CREDITS.md.

---

## Pre-Flight (MANDATORY)

**BEFORE creating ANY GitHub artifacts:**

```
1. Verify gh CLI authentication:
   gh auth status
   → If fails: STOP. User must run `gh auth login`

2. Verify GitHub remote:
   git remote get-url origin
   → Must be a GitHub URL (github.com)

3. Get tier from calling context:
   → If no tier provided: STOP. Complexity assessment required first.

4. mcp__contextd__memory_search(
     project_id: "<project>",
     query: "github planning <feature-name>"
   )
   → Check if Issues already exist for this feature
```

**Do NOT proceed to Issue creation without completing all pre-flight checks.**

---

## Mandatory Checklist

**EVERY github-planning invocation MUST complete ALL steps:**

### For ALL Tiers:
- [ ] Run pre-flight checks (gh auth, remote, tier)
- [ ] Generate verification criteria for EACH task (see Verification Criteria section)
- [ ] Include verification table in EVERY Issue body
- [ ] Record created artifacts in contextd

### For SIMPLE Tier:
- [ ] Create single Issue with checklist
- [ ] Include all tasks as checkboxes
- [ ] Add verification criteria table
- [ ] Add complexity and source metadata

### For STANDARD Tier:
- [ ] Create Epic Issue FIRST
- [ ] Create each sub-Issue with parent reference (`Contributes to #<epic>`)
- [ ] Update Epic body with sub-issue links (`- #<sub-issue>: <title>`)
- [ ] Verify bidirectional linking (epic ↔ sub-issues)

### For COMPLEX Tier:
- [ ] Complete ALL STANDARD tier steps
- [ ] Check for existing Project board OR create new one
- [ ] Add Epic to Project board
- [ ] Add ALL sub-Issues to Project board
- [ ] Verify all Issues appear in Project

### Post-Creation:
- [ ] Output Issue URLs to user
- [ ] Record in contextd with all URLs
- [ ] If ANY step fails, record failure and cleanup

**GitHub planning is NOT complete until contextd recording is done.**

---

## Red Flags - STOP and Reconsider

If you're thinking any of these, you're about to violate the skill:

| Thought | Reality |
|---------|---------|
| "Skip pre-flight, I know gh is working" | Pre-flight catches stale tokens. Always check. |
| "Verification is optional for simple tasks" | Verification is NEVER optional. Always include. |
| "I'll update the Epic links later" | Bidirectional linking is immediate. Do it now. |
| "COMPLEX doesn't need a Project board" | COMPLEX REQUIRES Project board. No exceptions. |
| "contextd recording can wait" | Recording is the LAST mandatory step. Don't skip. |
| "One Issue is enough for STANDARD" | STANDARD = Epic + sub-Issues. Always. |
| "I'll just create Issues without verification" | Every Issue needs verification criteria. |
| "The user didn't ask for a Project board" | Tier determines artifacts. COMPLEX = Project. |

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|------------------|
| Creating sub-Issues without Epic reference | Every sub-Issue body MUST contain `Contributes to #<epic>` |
| Creating Epic without updating links | After ALL sub-Issues created, update Epic with `- #<n>: <title>` list |
| Skipping verification criteria | Use Verification Criteria section to generate for each task type |
| COMPLEX without Project board | gh project create, then gh project item-add for each Issue |
| Not recording in contextd | memory_record with ALL Issue URLs is mandatory |
| Using wrong tier artifacts | SIMPLE = single Issue, STANDARD = Epic+subs, COMPLEX = Epic+subs+Project |
| Orphaned Issues on failure | If error mid-creation, cleanup with gh issue close |

---

## Verification Criteria Generation (Required)

**For EVERY task, determine verification type and generate criteria:**

| Task Type | Verification Type | Example |
|-----------|------------------|---------|
| CLI command | command | `<command> && echo "PASS"` |
| API endpoint | api | `curl -X POST /endpoint -d '{}' \| jq '.status'` |
| UI component | browser | "Click button, verify modal appears" |
| Integration | e2e | `npm run test:e2e -- --grep "feature"` |
| Config change | manual | "Verify setting appears in dashboard" |

**Include verification table in EVERY Issue:**

```markdown
## Verification
| Type | Details | Expected |
|------|---------|----------|
| command | `npm test -- --grep "feature"` | All tests pass |
| browser | Navigate to /settings, click Save | Success toast appears |
```

---

## Bidirectional Linking (Required for STANDARD/COMPLEX)

**Epic body MUST contain:**
```markdown
## Sub-Issues
- #43: Implement auth middleware
- #44: Add login component
- #45: Create user model
```

**Each sub-Issue body MUST contain:**
```markdown
## Parent
Contributes to #42
```

**Verification:** After creation, both Epic and sub-Issues should show cross-references in GitHub UI.

---

## Cleanup Protocol

**If planning fails or is abandoned:**

```bash
# Close all created Issues
gh issue close <epic-number> --comment "Planning abandoned"
gh issue close <sub-issue-1> --comment "Parent epic closed"
gh issue close <sub-issue-2> --comment "Parent epic closed"

# Remove from Project (if COMPLEX)
gh project item-delete <project-number> --owner <owner> --id <item-id>
```

**Record in contextd:**
```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "GitHub planning abandoned: <feature-name>",
  content: "Reason: <reason>. Closed: #<numbers>.",
  outcome: "failure",
  tags: ["github-planning", "abandoned"]
)
```
