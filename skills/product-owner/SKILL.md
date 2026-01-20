---
name: product-owner
description: Use when running daily standups, prioritizing work, tracking cross-project dependencies, or managing development flow. Synthesizes GitHub state with contextd memory to provide actionable recommendations. Say "/standup", "what should I work on?", or "show project status".
---

# Product Owner Skill

A Claude-native product owner that provides daily standups, priority recommendations, and cross-project awareness without artificial sprint boundaries.

## Philosophy

- **Recommend, don't dictate**: Present priorities; user decides what to act on
- **Continuous flow**: No sprints or ceremonies - priorities adjust daily
- **Cross-project awareness**: Dependencies across repos get flagged and prioritized
- **Memory persistence**: Cross-session context via contextd

## When to Use

| Trigger | Use Case |
|---------|----------|
| `/standup` | Daily standup report |
| "what should I work on?" | Priority recommendations |
| "project status" | Current state summary |
| "what's blocking?" | Blocker analysis |
| `/standup --platform` | Cross-project view |

## Data Sources

### GitHub (via MCP)

| Query | Purpose |
|-------|---------|
| `list_pull_requests` | Open PRs, review states, ages |
| `list_issues` | Priority-labeled issues |
| `list_commits` | Recent activity on main |
| `list_branches` | Detect stale branches |

### contextd (Cross-Session Memory)

| Query | Purpose |
|-------|---------|
| `checkpoint_list/resume` | Yesterday's state |
| `memory_search` | Recurring patterns, blockers |
| `remediation_search` | Known issues and fixes |

## Priority Classification

### CRITICAL (Immediate Attention)

Items requiring immediate attention. Stop current work if needed.

**Criteria:**
- Security vulnerabilities (label: `security`, `vulnerability`)
- Failing CI on main/production branches
- PRs blocked >24h with no activity
- Production incidents or outages
- Data integrity issues

**Action:** Address before anything else.

### HIGH (Today's Focus)

Primary work items for the current session.

**Criteria:**
- PRs approved and ready to merge
- Issues with `priority:high` or `priority:critical` label
- Items explicitly marked for today in last checkpoint
- Carried over items from previous standup
- Time-sensitive deliverables

**Action:** Complete these during current session.

### DEPENDENCY ALERT (Cross-Project)

Items with cross-repository dependencies.

**Detection patterns in issue/PR bodies:**
```
- "blocked by <repo>#<number>"
- "depends on <repo>"
- "waiting for <repo>"
- "upstream: <repo>"
- References to other fyrsmithlabs repos
```

**Action:** Flag prominently, include in cross-project view.

### MEDIUM (This Week)

Important but not urgent items.

**Criteria:**
- PRs in active review
- Issues with `priority:medium` or no priority label
- Planned work mentioned in checkpoints
- Technical debt items

**Action:** Work on after HIGH items complete.

### CARRIED OVER (Tracking)

Items from previous sessions not yet completed.

**Detection:**
- Compare current checkpoint to previous
- Items mentioned but not closed
- Stale branches (>24h without PR)

**Action:** Review whether still relevant, re-prioritize or close.

## Standup Report Format

### Standard Report

```
┌─────────────────────────────────────────────────────────────┐
│ Daily Standup: <owner>/<repo>                               │
│ <date> at <time>                                            │
└─────────────────────────────────────────────────────────────┘

Yesterday:
  - <accomplishments from last checkpoint>
  - <velocity: n issues closed, m PRs merged>

CRITICAL (<count>):
  • <item> - <status/reason>

HIGH (<count>):
  • <item> - <status>

DEPENDENCY ALERT:
  ⚠ <description of cross-project dependency>

MEDIUM (<count>):
  • <item> - <status>

CARRIED OVER from yesterday:
  • <item> - <reason still open>

Recommendations:
  1. <actionable next step>
  2. <actionable next step>
  3. <actionable next step>

───────────────────────────────────────────────────────────────
```

### Brief Report (for scripting)

```
[<repo>] CRIT:<n> HIGH:<m> MED:<k> | PRs:<open>,<ready> | Blocked: <description>
```

### Platform Report (cross-project)

```
┌─────────────────────────────────────────────────────────────┐
│ Platform Standup: fyrsmithlabs                              │
│ <date> at <time>                                            │
└─────────────────────────────────────────────────────────────┘

Cross-Project Dependencies:
  ⚠ <repo> → <repo>: <description>
  ✓ <repo> → <repo>: No blockers

Project Summaries:
  [<repo>] CRIT:<n> HIGH:<m> MED:<k> | Focus: <summary>

Recommended Focus Order:
  1. <repo> - <reason>
  2. <repo> - <reason>

───────────────────────────────────────────────────────────────
```

## Cross-Project Discovery

### Finding fyrsmithlabs Repos

Priority order for discovering repos:

1. **Config file** (if exists):
   ```
   ~/.fyrsmithlabs/repos.json
   {
     "repos": [
       "fyrsmithlabs/contextd",
       "fyrsmithlabs/marketplace"
     ]
   }
   ```

2. **Local directory scan:**
   ```bash
   ls ~/projects/fyrsmithlabs/
   ```

3. **GitHub org query:**
   ```
   mcp__MCP_DOCKER__search_repositories(
     query: "org:fyrsmithlabs"
   )
   ```

### Dependency Detection

Scan issue/PR content for patterns:

```regex
# Cross-repo references
fyrsmithlabs/\w+#\d+
blocked by .+#\d+
depends on .+
waiting for .+
upstream: .+
```

## contextd Integration

### Checkpoint Schema

Store standup state for next session:

```yaml
checkpoint:
  name: "standup-YYYY-MM-DD"
  summary: "CRIT:0 HIGH:2 MED:5. Focus: Complete auth PR"
  context: |
    PRs: #42 (auth, ready), #38 (hooks, in review)
    Issues: #15 (high), #20 (medium), #22 (medium)
    Blockers: contextd v1.3 release
  full_state: |
    <complete standup output for comparison>
```

### Memory Recording

Record notable events:

**Persistent blockers:**
```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Persistent blocker: <description>",
  content: "Blocked on <item> for <n> days. First seen: <date>",
  outcome: "failure",
  tags: ["standup", "blocker", "persistent"]
)
```

**Velocity patterns:**
```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Velocity trend: <direction>",
  content: "Closed <n> issues this week vs <m> last week",
  outcome: "success",
  tags: ["standup", "velocity"]
)
```

## Stale Work Detection

### Stale PRs

**Criteria:**
- Open >48h with no review activity
- Approved but not merged >24h
- Changes requested but no updates >48h

**Action:** Flag in CARRIED OVER, suggest follow-up.

### Stale Branches

**Criteria:**
- Branch exists with commits not on main
- No open PR associated
- Last commit >24h ago

**Action:** Prompt to create PR or delete branch.

### Stale Issues

**Criteria:**
- Assigned but no activity >7 days
- In progress label but no linked PR

**Action:** Flag in MEDIUM, suggest status update.

## Error Handling

| Scenario | Handling |
|----------|----------|
| GitHub API unavailable | Use cached data from last checkpoint |
| No Git remote | Skip GitHub, show contextd-only standup |
| First standup (no checkpoint) | Show current state, note "first standup" |
| Empty repo (no issues/PRs) | Prompt "Clean slate - what's the first task?" |
| Rate limited | Graceful degradation with warning |

## Future Enhancements (Not Yet Implemented)

Phase 2+:
- Velocity tracking over time
- Automated stale detection alerts
- Integration with calendar for time-boxing
- YAGNI integration for scope creep detection
- Autonomous PR merge recommendations

## Mandatory Checklist

Every standup MUST complete:

- [ ] Load contextd checkpoint (or note first standup)
- [ ] Query GitHub PRs and issues
- [ ] Detect cross-project dependencies
- [ ] Classify items by priority
- [ ] Generate recommendations
- [ ] Save checkpoint for next standup
- [ ] Record blockers to memory (if any)

## Red Flags - STOP and Reconsider

| Thought | Reality |
|---------|---------|
| "Skip checkpoint - not important" | Checkpoint enables tomorrow's comparison |
| "No need to check dependencies" | Cross-project blockers are often invisible |
| "Just show raw GitHub data" | Synthesis and prioritization is the value |
| "CRITICAL for everything" | Overuse dilutes urgency |
| "Skip contextd - just use GitHub" | Memory provides continuity across sessions |

## Attribution

Original research synthesized from:
- Digital Scrum Master patterns (episodic memory)
- CrewAI role-based agents (structured autonomy)
- GitHub Copilot Agent (native integration)
- fyrsmithlabs contextd (cross-session memory)

See CREDITS.md for full attribution.
