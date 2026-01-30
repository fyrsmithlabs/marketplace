---
name: standup
description: Run a daily standup report for the current project. Queries GitHub for PRs/issues and contextd memory for yesterday's state. For automated org-wide standups, see the daily-standup.yml workflow.
arguments:
  - name: brief
    description: "Output brief summary (for scripting or aggregation)"
    required: false
  - name: since
    description: "Look back period for activity (default: 24h)"
    required: false
---

# /standup

Daily standup command that synthesizes GitHub state and contextd memory into an actionable priority list.

## Execution Modes

| Mode | Description |
|------|-------------|
| **CLI** (`/standup`) | Terminal output for current repo |
| **GHA Workflow** | Automated org-wide standup → GitHub Discussions |

## CLI Usage

```bash
# Standard project standup (terminal output)
/standup

# Brief mode for scripting
/standup --brief

# Custom lookback period
/standup --since 48h
```

## Automated Workflow

For org-wide standups posted to GitHub Discussions, use the GHA workflow:

```bash
# Manual trigger (dry run)
gh workflow run daily-standup.yml -f dry_run=true

# Manual trigger (creates Discussion)
gh workflow run daily-standup.yml
```

Runs automatically at 9:00 AM UTC, Monday-Friday.

## Execution

**Skill:** `product-owner`
**Context Folding:** If contextd available
**Output:** Prioritized work list with recommendations

## Contextd Integration (Optional)

If contextd MCP is available:
- Load previous checkpoint for "yesterday" context
- Search memories for blockers and carried-over items
- Save checkpoint after standup

If contextd is NOT available:
- Query GitHub only (no cross-session history)
- No checkpoint persistence
- Standup still functional, just stateless

## Workflow

### Phase 1: Load Context

```
1. Derive project_id from git remote:
   project_id = git remote get-url origin | extract "owner/repo"

2. Check contextd availability:
   - Look for mcp__contextd__* tools
   - Set contextd_available = true/false

3. If contextd_available:
   - Load yesterday's checkpoint:
     mcp__contextd__checkpoint_list(project_path: ".", limit: 1)
   - If checkpoint exists, resume at summary level
   - Search memories for blockers/priorities

4. If NOT contextd_available:
   - Skip to Phase 2 (GitHub queries only)
   - Note: "No cross-session context (contextd unavailable)"
```

### Phase 2: Query GitHub State

**If contextd_available:** Create isolated branch
```
mcp__contextd__branch_create(
  session_id: "<session>",
  description: "Query GitHub state for standup",
  budget: 4096
)
```

**If NOT contextd_available:** Run directly without isolation.

Query via GitHub MCP (or gh CLI):

```
1. Open PRs:
   mcp__MCP_DOCKER__list_pull_requests(
     owner: "<owner>",
     repo: "<repo>",
     state: "open"
   )
   -> Capture: count, ages, review states

2. Issues by priority:
   mcp__MCP_DOCKER__list_issues(
     owner: "<owner>",
     repo: "<repo>",
     state: "OPEN",
     labels: ["priority:critical", "priority:high"]
   )
   -> Capture: critical/high priority items

3. Recent commits on main:
   mcp__MCP_DOCKER__list_commits(
     owner: "<owner>",
     repo: "<repo>",
     sha: "main",
     perPage: 10
   )
   -> Capture: what shipped recently

4. Branches (detect stale):
   mcp__MCP_DOCKER__list_branches(
     owner: "<owner>",
     repo: "<repo>"
   )
   -> Flag branches with no recent activity (>24h no PR)
```

**If contextd_available:**
```
mcp__contextd__branch_return(
  branch_id: "<branch>",
  message: "GitHub: <n> PRs, <m> critical issues, <k> stale branches"
)
```

### Phase 3: Detect Cross-Project Dependencies

When references to other repos are found in issue/PR content:

```
1. Search issue/PR bodies for cross-repo references:
   - "fyrsmithlabs/contextd"
   - "blocked by"
   - "depends on"
   - "waiting for"

2. For each referenced repo:
   - Query its open PRs/issues
   - Check if blocking items are resolved

3. Flag dependency alerts in output
```

### Phase 4: Synthesize Priority List

Apply prioritization logic:

```
CRITICAL (immediate attention):
- Security vulnerabilities (from labels or content)
- Failing CI on main branch
- PRs blocked >24h
- Explicit blockers from contextd memory

HIGH (today's focus):
- PRs ready for merge (approved, passing)
- Issues with priority:high label
- Items carried over from yesterday's standup

DEPENDENCY ALERT (cross-project):
- Items blocked on other repos
- Items blocking other repos

MEDIUM (this week):
- PRs in review
- Issues with priority:medium or no priority
- Planned work from last checkpoint

CARRIED OVER (tracking):
- Items from yesterday not completed
- Stale branches needing attention
```

### Phase 5: Output Report

**Standard mode:**

```
┌─────────────────────────────────────────────────────────────┐
│ Daily Standup: <owner>/<repo>                               │
│ <date> at <time>                                            │
└─────────────────────────────────────────────────────────────┘

Yesterday:
  - <summary from last checkpoint>
  - <n> issues closed, <m> PRs merged

CRITICAL (0):
  (none - great!)

HIGH (2):
  • PR #42: "Add user auth" - approved, ready to merge
  • Issue #15: "Memory consolidation bug" - priority:high

DEPENDENCY ALERT:
  ⚠ [marketplace] Blocked on contextd v1.3 for new MCP tools

MEDIUM (3):
  • PR #38: "Refactor hooks" - in review
  • Issue #20: "Add retry logic"
  • Issue #22: "Update docs"

CARRIED OVER from yesterday:
  • Review PR #38 (still in progress)

Recommendations:
  1. Merge PR #42 first (approved, no blockers)
  2. Focus on Issue #15 (high priority)
  3. Follow up on PR #38 review

───────────────────────────────────────────────────────────────
```

**Brief mode (`--brief`):**

```
[<repo>] CRIT:0 HIGH:2 MED:3 | PRs:3 open, 1 ready | Blocked: contextd v1.3
```

**Org-wide mode (via GHA workflow):**

See `.github/workflows/daily-standup.yml` for automated org-wide standups posted to GitHub Discussions. This replaces the CLI `--platform` flag with a proper scheduled workflow.

### Phase 6: Persist State (Optional)

**If contextd_available:**
```
mcp__contextd__checkpoint_save(
  session_id: "<session>",
  project_path: ".",
  name: "standup-<date>",
  description: "Daily standup for <date>",
  summary: "CRIT:<n> HIGH:<m> MED:<k>. Focus: <top priority>",
  ...
)
```

**If blockers detected and contextd_available:**
```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Standup blocker: <description>",
  ...
)
```

**If NOT contextd_available:**
- Skip checkpoint/memory (standup is stateless)
- Terminal output is the only record

## Org-Wide Standup (GitHub Actions)

For org-wide standups, use the GitHub Actions workflow instead of CLI:

```bash
# Located at: .github/workflows/daily-standup.yml
# Schedule: 9:00 AM UTC, Monday-Friday
# Output: GitHub Discussion in "Standups" category
```

The workflow:
1. Queries all fyrsmithlabs repos via Claude Code Action
2. Synthesizes into org-wide priority list
3. Posts to GitHub Discussions (org-level if enabled)

## Edge Cases

| Scenario | Handling |
|----------|----------|
| No GitHub remote | Skip GitHub queries, use contextd only |
| No checkpoint | First standup - just show current state |
| GitHub API limit | Graceful degradation with warning |
| No issues/PRs | "Clean slate - what's next?" prompt |

## Attribution

Part of fyrsmithlabs product-owner skill.
See CREDITS.md for full attribution.
