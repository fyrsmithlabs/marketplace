---
name: github-planning
description: Use when creating GitHub Issues, making an epic, creating sub-issues, setting up a project board, or converting plans into GitHub artifacts. Creates tier-appropriate structures - SIMPLE (single issue with checklist), STANDARD (epic + native sub-issues), COMPLEX (epic + native sub-issues + Projects v2 board with automation).
---

# GitHub Planning

Create GitHub Issues and Projects instead of local markdown files for planning artifacts.

## Modern GitHub Features (2024+)

This skill leverages modern GitHub capabilities:

| Feature | Description | When Used |
|---------|-------------|-----------|
| Native Sub-Issues | GitHub's built-in parent/child relationship | STANDARD, COMPLEX |
| YAML Issue Forms | Structured input templates | All tiers |
| Projects v2 API | GraphQL-based project management | COMPLEX |
| Milestones | Time-boxed release tracking | STANDARD, COMPLEX |
| Label Taxonomy | Structured labeling (type:*, priority:*, status:*) | All tiers |

## Contextd Integration (Optional)

If contextd MCP is available:
- `memory_record` for planning decisions

If contextd is NOT available:
- GitHub artifact creation works normally
- No cross-session memory of planning decisions

## When to Use

Called by `/brainstorm` Phase 6 after design is complete to create:
- **SIMPLE:** Single Issue with checklist
- **STANDARD:** Epic Issue + native sub-Issues + Milestone
- **COMPLEX:** Epic + native sub-Issues + Projects v2 board + Automation

## Prerequisites

- `gh` CLI authenticated (`gh auth status`)
- Repository has GitHub remote configured
- Complexity tier determined (from complexity-assessment)
- For Projects v2: GitHub GraphQL API access (`gh api graphql`)

---

## Label Taxonomy (Required)

**Create these labels in your repository if they don't exist:**

### Type Labels
```bash
gh label create "type:epic" --color "8B5CF6" --description "Epic/parent issue"
gh label create "type:feature" --color "10B981" --description "New feature"
gh label create "type:bug" --color "EF4444" --description "Bug report"
gh label create "type:task" --color "3B82F6" --description "Implementation task"
gh label create "type:chore" --color "6B7280" --description "Maintenance/housekeeping"
gh label create "type:docs" --color "F59E0B" --description "Documentation"
```

### Priority Labels
```bash
gh label create "priority:critical" --color "DC2626" --description "P0 - Drop everything"
gh label create "priority:high" --color "F97316" --description "P1 - This sprint"
gh label create "priority:medium" --color "EAB308" --description "P2 - Next sprint"
gh label create "priority:low" --color "84CC16" --description "P3 - Backlog"
```

### Status Labels
```bash
gh label create "status:blocked" --color "FEE2E2" --description "Blocked by dependency"
gh label create "status:needs-review" --color "DBEAFE" --description "Ready for review"
gh label create "status:in-progress" --color "FEF3C7" --description "Currently being worked"
```

---

## Tier-Based Output

### SIMPLE Tier

Create single Issue with checkbox checklist:

```bash
gh issue create \
  --title "<feature-name>" \
  --label "type:task,priority:medium" \
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

## Definition of Done
- [ ] All tasks checked off
- [ ] Verification criteria pass
- [ ] No regressions introduced

## Context
- Complexity: SIMPLE
- Created by: /brainstorm
EOF
)"
```

### STANDARD Tier

Create Epic Issue + native sub-Issues + Milestone:

**1. Create Milestone (if needed):**
```bash
gh api repos/{owner}/{repo}/milestones \
  --method POST \
  -f title="<milestone-name>" \
  -f description="<milestone-description>" \
  -f due_on="<YYYY-MM-DDTHH:MM:SSZ>"
```

**2. Create Epic:**
```bash
gh issue create \
  --title "[EPIC] <feature-name>" \
  --label "type:epic,priority:high" \
  --milestone "<milestone-name>" \
  --body "$(cat <<'EOF'
## Overview
<description>

## Sub-Issues
<!-- Native sub-issues will be linked automatically -->

## Success Criteria
<what done looks like>

## Definition of Done
- [ ] All sub-issues closed
- [ ] Integration tests pass
- [ ] Documentation updated
- [ ] No P0/P1 bugs outstanding

## Context
- Complexity: STANDARD
- Created by: /brainstorm
EOF
)"
```

**3. Create Native Sub-Issues (GitHub 2024+ feature):**
```bash
# Get Epic node ID first
EPIC_ID=$(gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $number) {
        id
      }
    }
  }
' -f owner="<owner>" -f repo="<repo>" -F number=<epic-number> --jq '.data.repository.issue.id')

# Create sub-issue with native parent relationship
gh api graphql -f query='
  mutation($repositoryId: ID!, $title: String!, $body: String!, $parentId: ID!) {
    createIssue(input: {
      repositoryId: $repositoryId
      title: $title
      body: $body
      parentIssueId: $parentId
    }) {
      issue {
        number
        url
      }
    }
  }
' -f repositoryId="<repo-id>" \
  -f title="<task-name>" \
  -f body="<task-body>" \
  -f parentId="$EPIC_ID"
```

**Alternative: REST API for sub-issues (if GraphQL unavailable):**
```bash
gh issue create \
  --title "<task-name>" \
  --label "type:task" \
  --milestone "<milestone-name>" \
  --body "$(cat <<'EOF'
## Description
<task description>

## Verification
| Type | Details | Expected |
|------|---------|----------|
| <type> | <command/steps> | <expected outcome> |

## Definition of Done
- [ ] Implementation complete
- [ ] Tests written and passing
- [ ] Verification criteria met

## Parent
Contributes to #<epic-number>
EOF
)"

# Then link via API:
gh api repos/{owner}/{repo}/issues/<sub-issue>/sub_issues \
  --method POST \
  -f parent_issue_id=<epic-id>
```

### COMPLEX Tier

Create Epic + native sub-Issues + Projects v2 board with automation:

**1. Create Epic and Sub-Issues** (same as STANDARD)

**2. Create Projects v2 board with GraphQL:**
```bash
# Get owner ID
OWNER_ID=$(gh api graphql -f query='
  query($login: String!) {
    user(login: $login) { id }
  }
' -f login="<owner>" --jq '.data.user.id')

# Create Project v2
PROJECT_ID=$(gh api graphql -f query='
  mutation($ownerId: ID!, $title: String!) {
    createProjectV2(input: {
      ownerId: $ownerId
      title: $title
    }) {
      projectV2 {
        id
        number
      }
    }
  }
' -f ownerId="$OWNER_ID" -f title="<feature-name>" --jq '.data.createProjectV2.projectV2.id')
```

**3. Configure Projects v2 Fields:**
```bash
# Add Status field (single select)
gh api graphql -f query='
  mutation($projectId: ID!, $name: String!) {
    createProjectV2Field(input: {
      projectId: $projectId
      dataType: SINGLE_SELECT
      name: $name
      singleSelectOptions: [
        {name: "Backlog", color: GRAY}
        {name: "Ready", color: BLUE}
        {name: "In Progress", color: YELLOW}
        {name: "In Review", color: PURPLE}
        {name: "Done", color: GREEN}
      ]
    }) {
      projectV2Field { id }
    }
  }
' -f projectId="$PROJECT_ID" -f name="Status"

# Add Priority field
gh api graphql -f query='
  mutation($projectId: ID!, $name: String!) {
    createProjectV2Field(input: {
      projectId: $projectId
      dataType: SINGLE_SELECT
      name: $name
      singleSelectOptions: [
        {name: "P0 Critical", color: RED}
        {name: "P1 High", color: ORANGE}
        {name: "P2 Medium", color: YELLOW}
        {name: "P3 Low", color: GREEN}
      ]
    }) {
      projectV2Field { id }
    }
  }
' -f projectId="$PROJECT_ID" -f name="Priority"

# Add Sprint/Iteration field
gh api graphql -f query='
  mutation($projectId: ID!, $name: String!) {
    createProjectV2Field(input: {
      projectId: $projectId
      dataType: ITERATION
      name: $name
    }) {
      projectV2Field { id }
    }
  }
' -f projectId="$PROJECT_ID" -f name="Sprint"
```

**4. Create Project Views:**
```bash
# Create Board View
gh api graphql -f query='
  mutation($projectId: ID!, $name: String!) {
    createProjectV2View(input: {
      projectId: $projectId
      name: $name
      layout: BOARD_LAYOUT
    }) {
      projectV2View { id }
    }
  }
' -f projectId="$PROJECT_ID" -f name="Board"

# Create Table View
gh api graphql -f query='
  mutation($projectId: ID!, $name: String!) {
    createProjectV2View(input: {
      projectId: $projectId
      name: $name
      layout: TABLE_LAYOUT
    }) {
      projectV2View { id }
    }
  }
' -f projectId="$PROJECT_ID" -f name="Table"

# Create Roadmap View
gh api graphql -f query='
  mutation($projectId: ID!, $name: String!) {
    createProjectV2View(input: {
      projectId: $projectId
      name: $name
      layout: ROADMAP_LAYOUT
    }) {
      projectV2View { id }
    }
  }
' -f projectId="$PROJECT_ID" -f name="Roadmap"
```

**5. Add Issues to Project (batch operation):**
```bash
# Batch add multiple issues
for ISSUE_URL in "<epic-url>" "<sub-issue-1-url>" "<sub-issue-2-url>"; do
  gh project item-add <project-number> --owner <owner> --url "$ISSUE_URL"
done

# Or via GraphQL for more control:
gh api graphql -f query='
  mutation($projectId: ID!, $contentId: ID!) {
    addProjectV2ItemById(input: {
      projectId: $projectId
      contentId: $contentId
    }) {
      item { id }
    }
  }
' -f projectId="$PROJECT_ID" -f contentId="<issue-node-id>"
```

**6. Configure Automation Rules:**
```bash
# Auto-move to "In Progress" when assigned
gh api graphql -f query='
  mutation($projectId: ID!) {
    createProjectV2Workflow(input: {
      projectId: $projectId
      name: "Auto-move on assign"
      enabled: true
      triggers: [ISSUE_ASSIGNED]
    }) {
      projectV2Workflow { id }
    }
  }
' -f projectId="$PROJECT_ID"

# Auto-move to "Done" when closed
gh api graphql -f query='
  mutation($projectId: ID!) {
    createProjectV2Workflow(input: {
      projectId: $projectId
      name: "Auto-close on done"
      enabled: true
      triggers: [ISSUE_CLOSED]
    }) {
      projectV2Workflow { id }
    }
  }
' -f projectId="$PROJECT_ID"
```

---

## YAML Issue Form Templates

Store these in `.github/ISSUE_TEMPLATE/` for structured issue creation.

### Feature Request Form (`feature.yml`)
```yaml
name: Feature Request
description: Propose a new feature
labels: ["type:feature"]
body:
  - type: markdown
    attributes:
      value: "## Feature Request"
  - type: textarea
    id: description
    attributes:
      label: Description
      description: What feature do you want?
      placeholder: As a user, I want...
    validations:
      required: true
  - type: dropdown
    id: priority
    attributes:
      label: Priority
      options:
        - P0 - Critical
        - P1 - High
        - P2 - Medium
        - P3 - Low
    validations:
      required: true
  - type: textarea
    id: acceptance
    attributes:
      label: Acceptance Criteria
      description: How do we know this is done?
      placeholder: |
        - [ ] Criterion 1
        - [ ] Criterion 2
    validations:
      required: true
  - type: textarea
    id: verification
    attributes:
      label: Verification Steps
      description: How to verify this works
      placeholder: |
        | Type | Details | Expected |
        |------|---------|----------|
        | command | npm test | All pass |
```

### Bug Report Form (`bug.yml`)
```yaml
name: Bug Report
description: Report a bug
labels: ["type:bug"]
body:
  - type: markdown
    attributes:
      value: "## Bug Report"
  - type: textarea
    id: description
    attributes:
      label: Bug Description
      description: What happened?
    validations:
      required: true
  - type: textarea
    id: reproduction
    attributes:
      label: Steps to Reproduce
      description: How can we reproduce this?
      placeholder: |
        1. Go to...
        2. Click on...
        3. See error
    validations:
      required: true
  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
      description: What should happen?
    validations:
      required: true
  - type: dropdown
    id: severity
    attributes:
      label: Severity
      options:
        - Critical - System down
        - High - Major feature broken
        - Medium - Feature degraded
        - Low - Minor annoyance
    validations:
      required: true
  - type: textarea
    id: environment
    attributes:
      label: Environment
      placeholder: |
        - OS:
        - Browser/Runtime:
        - Version:
```

### Epic Form (`epic.yml`)
```yaml
name: Epic
description: Create an epic with sub-issues
labels: ["type:epic"]
body:
  - type: markdown
    attributes:
      value: "## Epic Definition"
  - type: input
    id: title
    attributes:
      label: Epic Title
      placeholder: "[EPIC] Feature Name"
    validations:
      required: true
  - type: textarea
    id: overview
    attributes:
      label: Overview
      description: High-level description of this epic
    validations:
      required: true
  - type: textarea
    id: success_criteria
    attributes:
      label: Success Criteria
      description: What does done look like?
      placeholder: |
        - [ ] Criterion 1
        - [ ] Criterion 2
    validations:
      required: true
  - type: textarea
    id: sub_issues
    attributes:
      label: Planned Sub-Issues
      description: List the work items (will be converted to sub-issues)
      placeholder: |
        - [ ] Task 1: Description
        - [ ] Task 2: Description
  - type: dropdown
    id: complexity
    attributes:
      label: Complexity Tier
      options:
        - SIMPLE
        - STANDARD
        - COMPLEX
    validations:
      required: true
```

---

## PR Template with Verification

Create `.github/pull_request_template.md`:

```markdown
## Summary
<!-- Brief description of changes -->

## Related Issues
<!-- Link to issues: Fixes #123, Closes #456 -->

## Changes Made
-

## Verification Checklist
<!-- Check all that apply -->

### Automated Verification
- [ ] All CI checks pass
- [ ] Test coverage maintained/improved
- [ ] No new linting errors

### Manual Verification
| Verification | Status | Notes |
|--------------|--------|-------|
| Unit tests | [ ] Pass | |
| Integration tests | [ ] Pass | |
| Manual testing | [ ] Done | |

### Definition of Done
- [ ] Code follows project conventions
- [ ] Tests written for new functionality
- [ ] Documentation updated (if applicable)
- [ ] No breaking changes (or documented)
- [ ] Reviewed by at least one team member

## Screenshots/Recordings
<!-- If applicable -->

## Deployment Notes
<!-- Any special deployment considerations -->
```

---

## Automated Verification Criteria Generation

**For EVERY task, generate verification criteria automatically based on task type:**

### Detection Rules

| Task Pattern | Verification Type | Auto-Generated Command |
|--------------|------------------|------------------------|
| `*test*`, `*spec*` | command | `npm test -- --grep "<pattern>"` |
| `*API*`, `*endpoint*` | api | `curl -X <method> <endpoint> \| jq '.'` |
| `*UI*`, `*component*`, `*page*` | browser | "Navigate to <path>, verify <element>" |
| `*config*`, `*setting*` | manual | "Verify in settings dashboard" |
| `*CLI*`, `*command*` | command | `<command> --help && <command> <args>` |
| `*integration*` | e2e | `npm run test:e2e -- --grep "<feature>"` |
| `*migration*`, `*database*` | command | `npm run migrate && npm run db:verify` |

### CI Check Integration

Link verification to CI checks:
```markdown
## Verification
| Type | Details | Expected | CI Check |
|------|---------|----------|----------|
| command | `npm test` | All pass | [![Tests](badge-url)](check-url) |
| lint | `npm run lint` | No errors | [![Lint](badge-url)](check-url) |
| build | `npm run build` | Success | [![Build](badge-url)](check-url) |
```

### Definition of Done Checklist

Every issue should include a DoD section:
```markdown
## Definition of Done
- [ ] Implementation complete
- [ ] Unit tests written and passing
- [ ] Integration tests passing (if applicable)
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] No new technical debt introduced
- [ ] Accessibility requirements met (if UI)
- [ ] Performance benchmarks met (if applicable)
```

---

## contextd Integration

Record created artifacts:

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "GitHub planning: <feature-name>",
  content: "Created: <issue-type>. URLs: <list>.
            Tier: <tier>. Tasks: <count>.
            Project: <project-url> (if COMPLEX).
            Milestone: <milestone-name> (if STANDARD+).",
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

### GraphQL API errors
```
Error: GraphQL query failed
Action: Check API permissions, verify node IDs are correct
Fallback: Use REST API alternatives where available
```

### Native sub-issues not available
```
Error: parentIssueId not supported
Action: Repository may not have sub-issues enabled
Fallback: Use manual linking with "Contributes to #X" pattern
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

4. Check for existing labels:
   gh label list --json name --jq '.[].name' | grep "type:"
   → If missing: Create label taxonomy (see Label Taxonomy section)

5. mcp__contextd__memory_search(
     project_id: "<project>",
     query: "github planning <feature-name>"
   )
   → Check if Issues already exist for this feature

6. Verify GraphQL API access (for COMPLEX tier):
   gh api graphql -f query='{ viewer { login } }'
   → If fails: Fall back to REST API patterns
```

**Do NOT proceed to Issue creation without completing all pre-flight checks.**

---

## Mandatory Checklist

**EVERY github-planning invocation MUST complete ALL steps:**

### For ALL Tiers:
- [ ] Run pre-flight checks (gh auth, remote, tier, labels)
- [ ] Generate verification criteria for EACH task (see Verification Criteria section)
- [ ] Include verification table in EVERY Issue body
- [ ] Include Definition of Done checklist in EVERY Issue
- [ ] Apply appropriate label taxonomy (type:*, priority:*)
- [ ] Record created artifacts in contextd

### For SIMPLE Tier:
- [ ] Create single Issue with checklist
- [ ] Include all tasks as checkboxes
- [ ] Add verification criteria table
- [ ] Add Definition of Done checklist
- [ ] Add complexity and source metadata

### For STANDARD Tier:
- [ ] Create Milestone (if feature is time-boxed)
- [ ] Create Epic Issue FIRST with type:epic label
- [ ] Create each sub-Issue with native parent relationship (GraphQL)
- [ ] If native sub-issues unavailable: use REST fallback with manual linking
- [ ] Verify bidirectional linking (epic ↔ sub-issues) visible in GitHub UI
- [ ] Add all issues to milestone

### For COMPLEX Tier:
- [ ] Complete ALL STANDARD tier steps
- [ ] Create Projects v2 board via GraphQL
- [ ] Configure Project fields (Status, Priority, Sprint)
- [ ] Create Project views (Board, Table, Roadmap)
- [ ] Add Epic and ALL sub-Issues to Project
- [ ] Configure automation rules (auto-move on assign/close)
- [ ] Verify all Issues appear in Project with correct field values

### Post-Creation:
- [ ] Output Issue URLs to user
- [ ] Output Project URL (if COMPLEX)
- [ ] Record in contextd with all URLs and project details
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
| "COMPLEX doesn't need a Project board" | COMPLEX REQUIRES Projects v2 board. No exceptions. |
| "contextd recording can wait" | Recording is the LAST mandatory step. Don't skip. |
| "One Issue is enough for STANDARD" | STANDARD = Epic + native sub-Issues. Always. |
| "I'll just create Issues without verification" | Every Issue needs verification criteria AND DoD. |
| "The user didn't ask for a Project board" | Tier determines artifacts. COMPLEX = Project. |
| "Labels aren't important" | Label taxonomy enables filtering and automation. |
| "Skip GraphQL, REST is enough" | GraphQL enables native sub-issues and Projects v2. |
| "Automation rules are optional" | COMPLEX tier requires automation configuration. |

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|------------------|
| Creating sub-Issues without native parent link | Use GraphQL parentIssueId or REST sub_issues API |
| Creating Epic without updating links | Native sub-issues auto-link; verify in GitHub UI |
| Skipping verification criteria | Use Verification Criteria section to generate for each task type |
| COMPLEX without Project board | Create Projects v2 via GraphQL with fields and views |
| Not recording in contextd | memory_record with ALL Issue/Project URLs is mandatory |
| Using wrong tier artifacts | SIMPLE = single Issue, STANDARD = Epic+subs+Milestone, COMPLEX = Epic+subs+Projects v2 |
| Orphaned Issues on failure | If error mid-creation, cleanup with gh issue close |
| Missing label taxonomy | Create type:*, priority:*, status:* labels before issue creation |
| Not including Definition of Done | Every issue needs DoD checklist for completion criteria |
| Skipping Project automation | COMPLEX tier requires workflow automation rules |

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

### Native Sub-Issues (Preferred - GitHub 2024+)

When using GraphQL `parentIssueId`:
- Sub-issues automatically appear in Epic's "Sub-issues" section
- No manual linking required
- GitHub UI shows full hierarchy

### Manual Linking (Fallback)

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

# Or delete entire project if nothing was added
gh api graphql -f query='
  mutation($projectId: ID!) {
    deleteProjectV2(input: { projectId: $projectId }) {
      projectV2 { id }
    }
  }
' -f projectId="$PROJECT_ID"
```

**Record in contextd:**
```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "GitHub planning abandoned: <feature-name>",
  content: "Reason: <reason>. Closed: #<numbers>.
            Project deleted: <yes/no>.",
  outcome: "failure",
  tags: ["github-planning", "abandoned"]
)
```
