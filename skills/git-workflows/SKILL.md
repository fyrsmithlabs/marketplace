---
name: git-workflows
description: Use when working with git operations, PRs, or code reviews - enforces modern agentic git workflows with multi-agent consensus review using contextd for memory, context folding, and learning capture
---

# Git Workflows

Modern agentic git workflow enforcement with multi-agent consensus review. Integrates deeply with contextd for cross-session learning, context folding, and remediation tracking.

---

## Parallel Development with Git Worktrees

### Why Worktrees for AI Agents

- Multiple agents can work simultaneously without file conflicts
- Each agent gets isolated working directory
- Shared .git folder = efficient storage
- Industry standard for parallel AI development (2024-2025)

### Directory Structure

```
~/projects/
├── my-project/              # Main worktree (main branch)
└── my-project-worktrees/    # All linked worktrees
    ├── feature-auth/        # Agent A
    ├── fix-database/        # Agent B
    └── refactor-api/        # Agent C
```

### Core Commands

| Task | Command |
|------|---------|
| Create worktree | `git worktree add -b <branch> <path>` |
| List all | `git worktree list` |
| Lock (portable storage) | `git worktree lock --reason "msg" <path>` |
| Unlock | `git worktree unlock <path>` |
| Remove properly | `git worktree remove <path>` |
| Cleanup stale | `git worktree prune -v` |
| Fix broken links | `git worktree repair [<path>...]` |

### Worktree Lifecycle for Agents

1. **Pre-work:** `git worktree add -b feature/task ../worktrees/task`
2. **During:** Agent works in isolated directory
3. **Completion:** `git worktree remove ../worktrees/task`
4. **Cleanup:** `git worktree prune -v`

### Worktree Quick Reference Card

```bash
# === SETUP ===
git worktree add -b <branch> ../worktrees/<name>  # Create
git worktree list                                   # List all
git worktree list --porcelain                       # Machine-readable

# === DURING WORK ===
cd ../worktrees/<name>                              # Enter worktree
git status                                          # Check state
git worktree lock --reason "active" <path>          # Prevent removal

# === COMPLETION ===
git worktree unlock <path>                          # Unlock first
git worktree remove <path>                          # Remove properly
git worktree prune -v                               # Clean stale refs

# === RECOVERY ===
git worktree repair                                 # Fix broken links
git worktree repair <path>...                       # Fix specific worktrees
```

### Dependency Management in Worktrees

| Scenario | Solution |
|----------|----------|
| Shared node_modules | Use workspace root: `npm install` from main |
| Go modules | `go work init` + `go work use <worktrees>` |
| Python venv | Create per-worktree: `python -m venv .venv` |
| Docker builds | Mount worktree as volume |

### Anti-Patterns

| Anti-Pattern | Why Bad | Correct Approach |
|--------------|---------|------------------|
| `rm -rf worktree` | Corrupts Git tracking | `git worktree remove` |
| Two agents, same files | Merge conflicts | Scope to non-overlapping files |
| Moving folder manually | Breaks gitdir link | `git worktree move` or `repair` |
| 20+ simultaneous worktrees | Unmanageable | Create, complete, remove |

### Official Git Warning

> "Multiple checkout in general is still experimental, and the support for submodules is incomplete. It is NOT recommended to make multiple checkouts of a superproject."

### File Overlap Prevention

- Scope agent work to non-overlapping modules/directories
- Two agents touching same files = guaranteed conflicts
- Plan task decomposition before spawning agents

### Worktree + Background Agent Pattern

Combine worktrees with Task tool for true parallel development:

```bash
# 1. Create worktrees for each agent
git worktree add -b feature/auth ../worktrees/auth
git worktree add -b feature/api ../worktrees/api
git worktree add -b feature/ui ../worktrees/ui

# 2. Launch agents in parallel (each in own worktree)
Task(
  subagent_type: "general-purpose",
  prompt: "cd ../worktrees/auth && implement auth module",
  run_in_background: true
)
Task(
  subagent_type: "general-purpose",
  prompt: "cd ../worktrees/api && implement API layer",
  run_in_background: true
)
Task(
  subagent_type: "general-purpose",
  prompt: "cd ../worktrees/ui && implement UI components",
  run_in_background: true
)

# 3. Collect and merge
TaskOutput(task_id: "auth-id", block: true)
TaskOutput(task_id: "api-id", block: true)
TaskOutput(task_id: "ui-id", block: true)

# 4. Merge branches
git merge feature/auth feature/api feature/ui

# 5. Cleanup
git worktree remove ../worktrees/auth
git worktree remove ../worktrees/api
git worktree remove ../worktrees/ui
```

### Worktree-Aware Consensus Review

When reviewing changes across worktrees:

```
1. Each worktree gets its own review cycle
2. Cross-worktree dependencies detected via git diff
3. Integration review after individual passes
4. Merge conflicts flagged before human review
```

---

## Core Principles

1. **Flexible Trigger, Full Traceability** - Any work trigger acceptable, all changes traceable via commit/PR metadata
2. **Agent-Assisted, Human-Owned** - Agents propose, humans approve; AI code never ships without human sign-off
3. **Trunk-Based, Short-Lived** - Branches <24h encouraged, squash merge only, auto-delete after merge
4. **Consensus Before Human Review** - Multi-agent consensus gate before human reviewers engaged
5. **Learning-Enhanced** - contextd integration optional; file-based fallback when MCP unavailable

---

## Multi-Agent Consensus Review

### The Review Council

| Agent | Focus | Veto Power | Budget |
|-------|-------|------------|--------|
| **Security** | Auth, injection, secrets, OWASP | Yes | 8192 |
| **Vulnerability** | CVEs, deps, supply chain | Yes | 8192 |
| **Code Quality** | Logic, complexity, patterns, tests | Yes | 8192 |
| **Documentation** | README, comments, API docs, CHANGELOG | Yes | 4096 |
| **User Persona** | UX impact, breaking changes, API ergonomics | Yes | 4096 |

### Consensus Rules

- **All agents have veto power** on findings in their domain
- Use `--ignore-vetos` flag to override (requires justification)
- **100% consensus** required: all Critical/High/Medium resolved
- Low findings: auto-create issues if <3, author triage if ≥3

---

## contextd Integration (Optional)

### When contextd MCP is Available

| Feature | Tool | Benefit |
|---------|------|---------|
| Pre-flight search | `semantic_search`, `memory_search` | Learn from past reviews |
| Context isolation | `branch_create`, `branch_return` | Parallel agent execution |
| Learning capture | `memory_record`, `remediation_record` | Cross-session knowledge |
| Checkpoints | `checkpoint_save`, `checkpoint_resume` | Resumable sessions |

### When contextd is NOT Available

| Feature | Fallback | Location |
|---------|----------|----------|
| Review findings | JSON files | `.claude/consensus-reviews/PR-XXX.json` |
| Past patterns | Local search | Grep/Glob on previous reviews |
| Audit trail | Markdown logs | `.claude/consensus-reviews/audit.md` |

### Detection

```
# Check for contextd
ToolSearch("contextd")

# If available: use mcp__contextd__* tools
# If not: write to .claude/consensus-reviews/
```

---

## Workflow Phases

### Phase 1: Pre-Flight (ReasoningBank)

**Optional: If contextd available, gather additional context:**

```
1. mcp__contextd__semantic_search(
     query: "code patterns in [changed files]",
     project_path: "."
   )
   → Understand codebase context

2. mcp__contextd__memory_search(
     project_id: "<project>",
     query: "PR review patterns [area]"
   )
   → Retrieve past review strategies

3. mcp__contextd__remediation_search(
     query: "common issues in [file types]",
     tenant_id: "<tenant>",
     include_hierarchy: true
   )
   → Pre-load known problem patterns

4. mcp__contextd__checkpoint_save(
     session_id: "<session>",
     project_path: ".",
     name: "review-start-PR-XXX",
     description: "Starting consensus review",
     summary: "5-agent review of PR #XXX",
     context: "[PR description, files changed]",
     full_state: "[complete PR context]",
     token_count: <current>,
     threshold: 0.0,
     auto_created: false
   )
   → Preserve review start state
```

### Phase 2: Parallel Agent Review (Context Folding)

Launch all 5 agents in isolated branches:

```
# For each agent:
mcp__contextd__branch_create(
  session_id: "<session>",
  description: "[Agent] review of PR #XXX",
  prompt: "[Agent-specific review instructions - see below]",
  budget: [agent budget],
  timeout_seconds: 300
)
→ Returns: branch_id

# Each agent internally:
# 1. semantic_search for relevant code
# 2. remediation_search for known patterns
# 3. Analyze and produce findings
# 4. Return structured results
```

**Agent Prompts:**

#### Security Agent
```
You are a SECURITY REVIEWER analyzing PR #XXX.

Context from pre-flight:
[Include semantic_search results]
[Include relevant remediation patterns]

Review focus:
1. Injection vulnerabilities (SQL, command, XSS)
2. Authentication/authorization flaws
3. Secrets exposure (hardcoded keys, tokens)
4. Supply chain risks (new dependencies)
5. OWASP Top 10 violations

For each finding:
- Severity: CRITICAL / HIGH / MEDIUM / LOW
- Location: file:line
- Issue: What's wrong
- Recommendation: How to fix
- Related remediation: [ID if from remediation_search]

You have VETO POWER on security issues.
```

#### Vulnerability Agent
```
You are a VULNERABILITY REVIEWER analyzing PR #XXX.

Review focus:
1. Known CVEs in dependencies
2. Outdated packages with security patches
3. Dependency confusion risks
4. License compliance issues
5. Transitive dependency risks

For each finding:
- Severity: CRITICAL / HIGH / MEDIUM / LOW
- Location: file or dependency
- CVE: [if applicable]
- Issue: What's vulnerable
- Recommendation: Version upgrade or mitigation

You have VETO POWER on security issues.
```

#### Code Quality Agent
```
You are a CODE QUALITY REVIEWER analyzing PR #XXX.

Review focus:
1. Logic errors and edge cases
2. Test coverage gaps
3. Cyclomatic complexity spikes
4. Code duplication
5. Pattern violations
6. Error handling gaps

For each finding:
- Severity: CRITICAL / HIGH / MEDIUM / LOW
- Location: file:line
- Issue: What's wrong
- Recommendation: How to fix
```

#### Documentation Agent
```
You are a DOCUMENTATION REVIEWER analyzing PR #XXX.

Review focus:
1. README updates needed
2. Missing/outdated code comments
3. API documentation gaps
4. CHANGELOG entry required
5. Breaking change documentation

For each finding:
- Severity: MEDIUM / LOW
- Location: file or section
- Issue: What's missing
- Recommendation: What to add
```

#### User Persona Agent
```
You are a USER EXPERIENCE REVIEWER analyzing PR #XXX.

Review focus:
1. Breaking API changes
2. Migration path clarity
3. Error message quality
4. Configuration complexity
5. Developer ergonomics

For each finding:
- Severity: MEDIUM / LOW
- Location: file:line or feature
- Issue: UX impact
- Recommendation: Improvement
```

### Phase 3: Collect & Aggregate

```
# For each agent:
mcp__contextd__branch_return(
  branch_id: "<branch>",
  message: "[Structured findings JSON]"
)
→ Auto-scrubs secrets before return

# Aggregate findings:
1. Parse all agent responses
2. Tally by severity across agents
3. Identify consensus (2+ agents = higher priority)
4. De-duplicate similar findings
5. Apply veto rules:
   - Any agent CRITICAL/HIGH → BLOCK regardless
   - Use `--ignore-vetos` for advisory mode only
```

**Findings Structure:**
```json
{
  "agent": "security",
  "verdict": "REQUEST_CHANGES",
  "findings": [
    {
      "severity": "HIGH",
      "location": "auth/handler.go:45",
      "issue": "SQL injection via unsanitized user input",
      "recommendation": "Use parameterized queries",
      "related_remediation": "rem_abc123"
    }
  ],
  "summary": {
    "critical": 0,
    "high": 1,
    "medium": 2,
    "low": 0
  }
}
```

### Phase 4: Consensus Decision

```
IF any agent has Critical/High/Medium findings:
  → BLOCK PR
  → Return to author with:
    - All findings prioritized
    - remediation_search suggestions for each
    - Links to past solutions

IF only Low findings:
  IF count < 3:
    → Auto-create GitHub issues for each
    → Link issues to PR
    → Mark as "deferred to backlog"
  ELSE (≥3):
    → Require author to triage
    → Author acknowledges or disputes each
    → Issues created for acknowledged items

IF all agents APPROVE (no Critical/High/Medium, Low handled):
  → CONSENSUS PASSED
  → Proceed to human review tier
```

### Phase 5: Post-Flight (Learning Capture)

**With contextd (recommended for cross-session learning):**

```
# 1. Record review outcome
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "PR #XXX review - [PASSED|BLOCKED]",
  content: "Agents: 5, Findings: [summary], Novel: [patterns],
            Blocked on: [if blocked], Time: [duration]",
  outcome: "success" | "failure",
  tags: ["pr-review", "consensus", "<project>", "<severity>"]
)

# 2. Record novel findings as remediations
# For each finding NOT from existing remediation:
mcp__contextd__remediation_record(
  title: "[Issue pattern title]",
  problem: "[Exact issue found]",
  symptoms: ["[observable symptoms]"],
  root_cause: "[Why it's a problem]",
  solution: "[How to fix]",
  affected_files: ["[files]"],
  category: "security" | "syntax" | "logic" | "config" | etc,
  confidence: 0.8,
  tags: ["pr-review", "[category]", "<project>"],
  tenant_id: "<tenant>",
  scope: "org"  # Share across projects
)

# 3. Feedback on memories that helped
mcp__contextd__memory_feedback(
  memory_id: "<id>",
  helpful: true | false
)

# 4. Report outcome for memories used
mcp__contextd__memory_outcome(
  memory_id: "<id>",
  succeeded: true | false,
  session_id: "<session>"
)

# 5. Final checkpoint
mcp__contextd__checkpoint_save(
  session_id: "<session>",
  project_path: ".",
  name: "review-complete-PR-XXX",
  description: "Consensus review completed",
  summary: "[verdict]: [finding counts]",
  context: "[final state]",
  full_state: "[complete audit trail if Full Trace mode]",
  token_count: <current>,
  threshold: 0.0,
  auto_created: false
)
```

---

## Task Tool Orchestration (Claude Code 2.1+)

### Parallel Agent Execution

Launch all reviewers simultaneously using the Task tool:

```
# Launch 5+ agents in parallel (non-blocking)
Task(subagent_type: "fs-dev:security-reviewer", run_in_background: true)
Task(subagent_type: "fs-dev:vulnerability-reviewer", run_in_background: true)
Task(subagent_type: "fs-dev:code-quality-reviewer", run_in_background: true)
Task(subagent_type: "fs-dev:documentation-reviewer", run_in_background: true)
Task(subagent_type: "fs-dev:user-persona-reviewer", run_in_background: true)
Task(subagent_type: "fs-dev:go-reviewer", run_in_background: true)  # if Go files
```

### Task Tool Parameters

| Parameter | Required | Purpose |
|-----------|----------|---------|
| `subagent_type` | Yes | Agent to spawn (e.g., "fs-dev:security-reviewer") |
| `description` | Yes | 3-5 word task summary |
| `prompt` | Yes | Detailed instructions |
| `run_in_background` | No | `true` for async execution |
| `model` | No | sonnet (default), opus, haiku |
| `resume` | No | Resume previous agent by ID |

### Background vs Foreground

| Mode | When to Use |
|------|-------------|
| Foreground (default) | Tasks <30 seconds needing immediate results |
| Background (`run_in_background: true`) | Tasks >1 minute, parallel work |

### Collecting Results

```
# Check status
/tasks

# Read output
TaskOutput(task_id: "<id>", block: true)

# Monitor live
tail -f /path/to/task.output
```

### Task Dependencies

Use `addBlockedBy` for staged reviews:

```
# Create dependent tasks
TaskCreate(subject: "Security review", ...)  # Returns #1
TaskCreate(subject: "Quality review", ...)   # Returns #2
TaskCreate(subject: "Final synthesis", ...)  # Returns #3

# Set dependencies
TaskUpdate(taskId: "3", addBlockedBy: ["1", "2"])

# Task #3 auto-unblocks when #1 and #2 complete
```

---

## Swarm Orchestration Patterns

### Multi-Agent Review Swarm

Coordinate multiple agents for comprehensive review:

```
# Pattern 1: Parallel Independent Review
Launch all agents simultaneously, aggregate results

# Pattern 2: Staged Review
Security → Quality → Documentation (each gates the next)

# Pattern 3: Specialist + Generalist
Domain expert first, generalist validates
```

### Swarm Coordination

| Pattern | When to Use | Example |
|---------|-------------|---------|
| **Fan-out** | Independent tasks | 5 reviewers in parallel |
| **Pipeline** | Sequential dependencies | Security → then Quality |
| **Map-reduce** | Aggregate findings | All agents → synthesizer |
| **Supervisor** | Complex orchestration | Orchestrator manages workers |

### Agent Handoff Protocol

```
1. Agent A completes work
2. Writes summary to shared location
3. Notifies orchestrator via TaskOutput
4. Orchestrator assigns to Agent B
5. Agent B reads context, continues
```

---

## Agent Lifecycle Hooks (Claude Code 2.1+)

### Available Hook Events

| Event | Fires When | Use Case |
|-------|------------|----------|
| `PreToolUse` | Before any tool executes | Validate, block, inject context |
| `PostToolUse` | After tool completes | Log, transform output, chain actions |
| `Stop` | Session ends | Cleanup, final reports |

### Hook Configuration

```json
// hooks/hooks.json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "command": "python3 hooks/validate-commit.py",
      "matcher": { "tool_name": "Bash", "command_pattern": "git commit" }
    },
    {
      "event": "PostToolUse",
      "command": "python3 hooks/log-findings.py",
      "matcher": { "tool_name": "Task", "subagent_pattern": "*-reviewer" }
    },
    {
      "event": "Stop",
      "command": "python3 hooks/generate-report.py"
    }
  ]
}
```

### Review Workflow Hooks

| Hook | Purpose |
|------|---------|
| `pre-review` | Load past patterns, check prerequisites |
| `post-agent` | Aggregate findings as each agent completes |
| `pre-commit` | Block commits without consensus |
| `post-review` | Record learnings, update remediations |

---

## Human Review Tiers (Label-Based)

After agent consensus passes, human review is required:

```yaml
# Configurable in .github/fyrsmith-workflow.yml
review:
  tiers:
    - labels: [critical-path, security-sensitive, breaking-change]
      approvals: 2  # Configurable
      required_reviewers: ["@security-team"]
    - labels: [api-change, infrastructure]
      approvals: 2
    - labels: []  # default
      approvals: 1
```

| Label | Approvals | Rationale |
|-------|-----------|-----------|
| `critical-path` | 2 | Core system changes |
| `security-sensitive` | 2 | Security-related code |
| `breaking-change` | 2 | API/behavior breaking |
| `api-change` | 2 | Public API modifications |
| `infrastructure` | 2 | Infra/deployment changes |
| (default) | 1 | Standard changes |

---

## Branch & Merge Strategy

**Model:** Trunk-Based with Short-Lived Branches

```
main (protected)
  └── feature/short-description
  └── fix/issue-number-description
  └── chore/cleanup-description
```

### Branch Naming

| Type | Purpose | Example |
|------|---------|---------|
| `feature/` | New functionality | `feature/plugin-search` |
| `fix/` | Bug fixes | `fix/123-auth-timeout` |
| `chore/` | Maintenance, deps | `chore/update-deps` |
| `docs/` | Documentation only | `docs/api-reference` |
| `refactor/` | Code restructuring | `refactor/auth-module` |
| `release/` | Release prep | `release/1.2.0` |

### Stale Branch Cleanup

| Timeline | Action |
|----------|--------|
| 7 days | Warning notification |
| 14 days | Auto-close PR |
| 21 days | Delete branch |

**Exceptions:**
- `long-running` label exempts from auto-close
- Active worktrees auto-extend deadline
- Agent-assigned branches get 48h extension per activity

### Merge Requirements

- Squash merge only (linear history)
- Branch must be up-to-date with main
- Auto-delete branch after merge
- All CI checks passing
- Agent consensus passed
- Human approvals met

### Force Push Policy

Force push is **prohibited** except for one specific case:

| Scenario | Allowed | Required Actions |
|----------|---------|------------------|
| Secret accidentally committed | **Yes** | 1. Rotate credential immediately, 2. Force push to remove from history, 3. Verify removal, 4. Document in PR |
| Clean up commit history | No | Use interactive rebase before push |
| Fix merge conflicts | No | Pull and merge properly |
| Override CI failures | No | Fix the actual issue |
| "Clean up" force push to main | **Never** | Not allowed under any circumstances |

**Secret Removal Procedure:**

**Recommended: Use git-filter-repo (safer, faster):**
```bash
# 1. IMMEDIATELY rotate the exposed credential
# 2. Install git-filter-repo: pip install git-filter-repo
# 3. Remove file from history (use single quotes to prevent injection):
git filter-repo --invert-paths --path 'config/secrets.json'

# 4. Force push (branch only, NEVER main)
git push origin --force --all
```

**Alternative: BFG Repo-Cleaner:**
```bash
# For removing specific secrets from all files:
bfg --replace-text passwords.txt repo.git
```

**Legacy: git filter-branch (deprecated, use with caution):**
```bash
# WARNING: Ensure filename is properly escaped
# NEVER use user input directly in this command
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch -- "config/secrets.json"' \
  --prune-empty --tag-name-filter cat -- --all

# Clean up refs
git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
git reflog expire --expire=now --all
git gc --prune=now
```

**Security Warning:** Never interpolate untrusted input into shell commands. Always validate and escape file paths before use.

**Key Rule:** Force push for secret removal is acceptable ONLY with immediate credential rotation. The credential must be rotated BEFORE the force push completes.

---

## PR Structure (Agent-Assisted)

Agent auto-generates PR description from commits; author reviews and approves:

```markdown
## Description
<!-- Agent-generated from commits, author-verified -->
[Auto-generated summary of changes]

## Change Type
- [ ] feat | fix | refactor | docs | chore | test

## Test Plan
- [ ] Unit tests added/updated
- [ ] Integration tests (if applicable)
- [ ] Manual testing performed

## Breaking Changes
- [ ] None
- [ ] Yes: <!-- describe migration path -->

## Linked Issues
Closes #XXX

---
## Agent Review Summary
| Agent | Verdict | Critical | High | Medium | Low |
|-------|---------|----------|------|--------|-----|
| Security | ✅ | 0 | 0 | 0 | 0 |
| Vulnerability | ✅ | 0 | 0 | 0 | 0 |
| Code Quality | ✅ | 0 | 0 | 1 | 2 |
| Documentation | ⚠️ | 0 | 0 | 1 | 0 |
| User Persona | ✅ | 0 | 0 | 0 | 1 |

**Consensus:** PASSED
**Low Issues Created:** #124, #125, #126
```

---

## Agent-Generated Commits

When agents commit directly (GitHub Copilot agent mode, etc.):

| Rule | Implementation |
|------|----------------|
| Auto-label | `agent-generated` label applied |
| Same rules | Identical consensus loop, no exceptions |
| Track separately | Metrics collected for process improvement |
| Audit trail | Full trace mode recommended |

---

## Audit Trail Levels

| Level | Captured | Storage |
|-------|----------|---------|
| **Standard** | Agent verdicts, findings summary, consensus result, issues created | `memory_record` |
| **Full Trace** | + Agent reasoning, branch timelines, debate transcripts, confidence scores | `checkpoint_save` with `full_state` |

**Configuration:**
```yaml
consensus:
  tracing:
    level: standard  # standard | full
    contextd_enabled: true
```

---

## Configuration Schema

```yaml
# .github/fyrsmith-workflow.yml

consensus:
  agents:
    security:
      enabled: true
      veto_power: true
      budget: 8192
    vulnerability:
      enabled: true
      veto_power: true
      budget: 8192
    code_quality:
      enabled: true
      veto_power: true
      budget: 8192
    documentation:
      enabled: true
      veto_power: true
      budget: 4096
    user_persona:
      enabled: true
      veto_power: true
      budget: 4096

  ignore_vetos: false  # Set true or use --ignore-vetos flag

  thresholds:
    block_on: [critical, high, medium]
    auto_issue_below: 3  # Low findings count

  tracing:
    level: standard
    contextd_enabled: true

review:
  tiers:
    - labels: [critical-path, security-sensitive, breaking-change]
      approvals: 2
    - labels: [api-change, infrastructure]
      approvals: 2
    - labels: []
      approvals: 1

branches:
  strategy: trunk-based
  merge_method: squash
  auto_delete: true
  stale:
    warn_days: 1
    close_days: 2
    delete_days: 3
    exempt_labels: [long-running]

pr_template:
  agent_assisted: true
  required_sections:
    - description
    - change_type
    - test_plan
    - breaking_changes
    - linked_issues

agent_commits:
  label: agent-generated
  same_rules: true
  track_metrics: true
```

---

## Quick Reference

### With contextd MCP

| Phase | Tools | Purpose |
|-------|-------|---------|
| Pre-flight | `semantic_search`, `memory_search`, `remediation_search` | Context loading |
| Review | `Task(run_in_background: true)` x5 | Parallel agents |
| Collect | `TaskOutput(task_id, block: true)` | Gather findings |
| Post-flight | `memory_record`, `remediation_record` | Learning capture |

### Without contextd (File Fallback)

| Phase | Action | Location |
|-------|--------|----------|
| Pre-flight | Grep previous reviews | `.claude/consensus-reviews/` |
| Review | `Task(run_in_background: true)` x5 | Same parallel agents |
| Collect | `TaskOutput(task_id, block: true)` | Same collection |
| Post-flight | Write JSON | `.claude/consensus-reviews/PR-XXX.json` |

---

## Common Mistakes

| Mistake | Prevention |
|---------|------------|
| Skipping pre-flight search (when contextd available) | Search first for past patterns |
| Not using context folding for agents | Agents MUST run in isolated branches |
| Forgetting post-flight learning capture | Record outcomes for every review |
| Ignoring veto power | All agent vetoes are non-negotiable (unless `--ignore-vetos`) |
| Not creating issues for Low findings | All findings must be tracked |
| Skipping remediation_record for novel issues | Novel patterns must be captured |

---

## Integration with git-repo-standards

This skill works alongside `git-repo-standards`:

| git-repo-standards | git-workflows |
|--------------------|---------------|
| Repo structure | PR/review process |
| Naming conventions | Branch naming |
| README/CHANGELOG | PR template |
| Gitleaks config | Security agent |
| License compliance | Vulnerability agent |
