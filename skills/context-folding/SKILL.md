---
name: context-folding
description: Use when executing complex sub-tasks that need context isolation - creates branches with token budgets that auto-cleanup on return
---

# Context Folding

Create isolated branches for complex sub-tasks. Each branch has its own token budget and cleans up on return, preventing context bloat.

## Prerequisites: contextd Integration

Context folding uses contextd MCP tools:
- `branch_create` - Create isolated context branch
- `branch_return` - Return summary and cleanup branch
- `branch_status` - Monitor budget and hierarchy

**If contextd unavailable:** Context folding degrades to inline execution (no isolation).

---

## When to Use

**Use context folding when:**
- Investigating a problem requiring many file reads
- Running exploratory work that would bloat context
- Multi-step sub-tasks with verbose intermediate steps
- Parallel agent coordination is needed
- Task complexity is STANDARD or COMPLEX tier

**Don't use when:**
- Task is SIMPLE tier (< 3 steps)
- Results need to stay in main context
- You're at end of session anyway

---

## Tools

### branch_create

```json
{
  "session_id": "my-session",
  "description": "Brief description of the sub-task",
  "prompt": "Detailed instructions for the branch",
  "budget": 4096,
  "timeout_seconds": 300,
  "parent_branch_id": "br_parent123"
}
```

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `session_id` | Yes | - | Session identifier |
| `description` | Yes | - | Brief description (shown in status) |
| `prompt` | No | - | Detailed instructions |
| `budget` | No | 8192 | Token budget |
| `timeout_seconds` | No | 300 | Auto-return timeout |
| `parent_branch_id` | No | - | Parent branch for nesting |

### branch_return

```json
{
  "branch_id": "br_abc123",
  "message": "Summary of findings",
  "return_value": { "key": "structured data" }
}
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `branch_id` | Yes | Branch to return from |
| `message` | Yes | Summary (scrubbed for secrets) |
| `return_value` | No | Structured data for parent |

### branch_status

```json
{ "branch_id": "br_abc123" }
```

Or check active branch:
```json
{ "session_id": "my-session" }
```

**Returns:**
```json
{
  "status": "active",
  "budget_total": 8192,
  "budget_used": 3421,
  "budget_remaining": 4771,
  "budget_percent": 42,
  "depth": 2,
  "parent_id": "br_parent123",
  "children": ["br_child456", "br_child789"],
  "timeout_remaining_seconds": 180
}
```

---

## Complexity-Based Budget Allocation

Integrate with `complexity-assessment` skill to determine appropriate budgets:

| Tier | Budget | Timeout | Rationale |
|------|--------|---------|-----------|
| SIMPLE | 4096 | 120s | Quick investigation, minimal context |
| STANDARD | 8192 | 300s | Multi-file analysis, moderate exploration |
| COMPLEX | 16384 | 600s | Deep investigation, cross-system analysis |

**Adaptive allocation pattern:**
```
1. Run complexity-assessment on sub-task
2. Map tier to budget:
   - SIMPLE (5-8): budget=4096
   - STANDARD (9-12): budget=8192
   - COMPLEX (13-15): budget=16384
3. Create branch with calculated budget
```

---

## Observability

### Real-Time Budget Monitoring

Check budget proactively during branch execution:

```
# Check at natural breakpoints
branch_status(branch_id) -> {
  budget_percent: 72,
  budget_remaining: 2294,
  warning_level: "caution"
}
```

**Warning Levels:**
| Percent Used | Level | Action |
|--------------|-------|--------|
| 0-70% | `normal` | Continue execution |
| 70-85% | `caution` | Consider wrapping up |
| 85-95% | `warning` | Begin summarization |
| 95-100% | `critical` | Force return |

### Branch Hierarchy Visualization

For nested branches, use `branch_status` with session to see full tree:

```
branch_status(session_id: "main") -> {
  hierarchy: {
    "br_root": {
      status: "active",
      budget_percent: 45,
      children: {
        "br_analysis": { status: "active", budget_percent: 72 },
        "br_testing": { status: "completed", budget_percent: 89 }
      }
    }
  }
}
```

### Token Usage Breakdown

Monitor what consumes budget:

```
branch_status(branch_id, detailed: true) -> {
  usage_breakdown: {
    file_reads: 1200,
    searches: 800,
    tool_calls: 400,
    reasoning: 1021
  }
}
```

---

## Adaptive Budget Management

### Dynamic Warnings

Implement threshold-based warnings:

```
# After each significant operation
status = branch_status(branch_id)

if status.budget_percent >= 95:
  # CRITICAL: Force immediate return
  branch_return(branch_id, message: "Budget exhausted: {partial_findings}")

elif status.budget_percent >= 85:
  # WARNING: Begin summarization
  # Summarize findings, stop new exploration

elif status.budget_percent >= 70:
  # CAUTION: Plan exit strategy
  # Complete current task, avoid new threads
```

### Graceful Degradation

When approaching limits, auto-summarize:

```
# At 85% budget
1. Stop exploratory work
2. Consolidate findings so far
3. Create summary of discovered patterns
4. Return with partial results + "investigation incomplete" flag

branch_return(
  branch_id,
  message: "Partial analysis (budget: 87%): Found 3 of estimated 5 patterns...",
  return_value: {
    complete: false,
    findings: [...partial...],
    unexplored: ["area1", "area2"]
  }
)
```

---

## Dependency DAG

### Branch Dependencies

Track dependencies between parallel branches:

```
# Create independent branches
br_auth = branch_create(description: "Analyze auth module")
br_db = branch_create(description: "Analyze DB schema")

# Create dependent branch
br_integration = branch_create(
  description: "Analyze auth-DB integration",
  depends_on: [br_auth, br_db]  # Waits for these to complete
)
```

### Parallel Branch Coordination

For orchestration patterns:

```
# Phase 1: Independent branches (parallel)
branches = [
  branch_create(description: "Task A"),
  branch_create(description: "Task B"),
  branch_create(description: "Task C")
]

# Monitor all branches
for br in branches:
  status = branch_status(br)
  # Track completion

# Phase 2: Collect results
results = [branch_return(br) for br in branches]

# Phase 3: Dependent work using results
branch_create(
  description: "Synthesize findings",
  prompt: "Combine results: {results}"
)
```

### Return Value Propagation

Pass structured data between branches:

```
# Child branch returns structured data
branch_return(
  branch_id: "br_analysis",
  message: "Found 3 security issues",
  return_value: {
    issues: [
      { severity: "high", file: "auth.go", line: 42 },
      { severity: "medium", file: "db.go", line: 108 },
      { severity: "low", file: "utils.go", line: 15 }
    ],
    recommendations: ["Add input validation", "Use parameterized queries"]
  }
)

# Parent receives return_value for further processing
```

---

## Error Handling

### Branch Timeout Handling

Branches auto-return on timeout. Handle gracefully:

```
# Timeout returns partial results
branch_return(
  branch_id,
  message: "TIMEOUT: Partial results after 300s",
  return_value: {
    timed_out: true,
    completed_steps: ["step1", "step2"],
    incomplete_steps: ["step3", "step4"],
    partial_findings: {...}
  }
)

# Parent should:
1. Check return_value.timed_out
2. Decide: retry with larger timeout OR accept partial
3. Record in memory for future budget planning
```

### Failed Branch Recovery

When a branch fails:

```
# Branch encounters error
try:
  # ... work that might fail ...
except error:
  # Record remediation for future reference
  remediation_record(
    title: "Branch failure: {description}",
    problem: error.message,
    root_cause: "...",
    solution: "..."
  )

  # Return with error flag
  branch_return(
    branch_id,
    message: "FAILED: {error.summary}",
    return_value: {
      failed: true,
      error: error.message,
      partial_work: {...},
      recovery_suggestions: [...]
    }
  )
```

### Orphaned Branch Cleanup

Detect and clean up orphaned branches:

```
# Check for orphaned branches at session start
status = branch_status(session_id: "main")

for branch in status.all_branches:
  if branch.status == "orphaned" or branch.timeout_exceeded:
    # Force return with cleanup
    branch_return(
      branch_id: branch.id,
      message: "CLEANUP: Orphaned branch recovered"
    )

    # Record for awareness
    memory_record(
      title: "Orphaned branch cleanup",
      content: "Branch {branch.description} was orphaned and cleaned up"
    )
```

---

## Checkpoint Integration

### Save Branch State

Before risky operations or at natural breakpoints:

```
# Within a branch, save checkpoint
checkpoint_save(
  session_id: current_session,
  name: "branch-{branch_id}-checkpoint",
  summary: "Mid-branch checkpoint: completed {steps}, next {remaining}",
  context: "Branch work in progress..."
)
```

### Resume From Branch Checkpoint

```
# List available checkpoints
checkpoints = checkpoint_list(session_id)

# Find branch checkpoints
branch_checkpoints = [c for c in checkpoints if "branch-" in c.name]

# Resume specific branch state
checkpoint_resume(
  checkpoint_id: branch_checkpoint.id,
  level: "context"
)
```

---

## Memory Recording at Boundaries

### On Branch Create

```
memory_record(
  project_id: current_project,
  title: "Branch created: {description}",
  content: "Created branch for: {prompt}. Budget: {budget}.",
  outcome: "in_progress",
  tags: ["context-folding", "branch-start"]
)
```

### On Branch Return

```
memory_record(
  project_id: current_project,
  title: "Branch completed: {description}",
  content: "Findings: {summary}. Budget used: {percent}%.",
  outcome: "success",  # or "partial" or "failed"
  tags: ["context-folding", "branch-complete"]
)
```

### Cross-Branch State Sharing

Use memory for state that needs to persist across branches:

```
# In branch A: Record finding
memory_record(
  title: "Discovery: Auth pattern",
  content: "Found JWT validation in auth/middleware.go",
  tags: ["auth", "discovery", "branch-a"]
)

# In branch B: Search for related
results = memory_search(
  query: "auth pattern discovery",
  tags: ["discovery"]
)
# Use findings from branch A
```

---

## Integration Patterns

### With Orchestration Skill

```
# Orchestration creates branches for each task group
branch_create(
  description: "Group 1: Issues #42, #43",
  budget: 8192
)

# Launch task agents within branch
Task(subagent_type: "contextd:task-agent", ...)

# Return with group results
branch_return(message: "Group complete: 2 issues resolved")
```

### With Complexity Assessment

```
# Before creating branch
tier = complexity_assessment(task_description)

# Map tier to budget
budget = {
  "SIMPLE": 4096,
  "STANDARD": 8192,
  "COMPLEX": 16384
}[tier]

# Create appropriately sized branch
branch_create(
  description: task_description,
  budget: budget
)
```

### With Consensus Review

```
# Create branch for review work
branch_create(
  description: "Security review: {files}",
  budget: 4096
)

# Run review agents
# ... review work ...

# Return findings
branch_return(
  message: "Review complete: 2 findings",
  return_value: {
    verdict: "APPROVED_WITH_FINDINGS",
    findings: [...]
  }
)
```

---

## Workflow

```
1. branch_create(session_id, description, budget) -> branch_id
2. memory_record(title: "Branch started: {description}")
3. Do work in the branch (read files, search, analyze)
4. branch_status(branch_id) - monitor budget at intervals
5. If budget >= 70%: plan exit strategy
6. If budget >= 85%: begin summarization
7. branch_return(branch_id, message, return_value)
8. memory_record(title: "Branch completed: {description}")
```

---

## Example: Basic Usage

```
# Create branch for code analysis
branch_create(
  session_id: "main",
  description: "Analyze auth module structure",
  budget: 4096
) -> branch_id: "br_abc123"

# Record branch start
memory_record(title: "Branch: auth analysis started")

# Do analysis...
semantic_search("authentication handlers")
Read files, analyze patterns...

# Check budget mid-way
branch_status("br_abc123") -> budget_percent: 45

# Continue work...

# Return with summary
branch_return(
  branch_id: "br_abc123",
  message: "Auth module has 3 handlers: login, logout, refresh. Uses JWT with 15min expiry.",
  return_value: {
    handlers: ["login", "logout", "refresh"],
    token_type: "JWT",
    expiry: "15min"
  }
)

# Record completion
memory_record(title: "Branch: auth analysis complete", outcome: "success")
```

---

## Example: Adaptive Budget with Warnings

```
# Create branch
br = branch_create(description: "Deep code analysis", budget: 8192)

# Work loop with monitoring
while work_remaining:
  status = branch_status(br)

  if status.budget_percent >= 85:
    # WARNING: Begin wrap-up
    summary = summarize_findings_so_far()
    branch_return(br, message: summary, return_value: {complete: false})
    break

  if status.budget_percent >= 70:
    # CAUTION: Prioritize remaining work
    work_remaining = prioritize(work_remaining)

  # Continue most important work
  do_next_task(work_remaining.pop())

# Normal completion
branch_return(br, message: final_summary, return_value: {complete: true})
```

---

## Example: Parallel Branches with Dependencies

```
# Phase 1: Create parallel branches
br_frontend = branch_create(description: "Analyze frontend auth")
br_backend = branch_create(description: "Analyze backend auth")
br_database = branch_create(description: "Analyze auth tables")

# Phase 2: Execute in parallel (via Task tool)
Task(prompt: "Analyze frontend auth components", branch_id: br_frontend)
Task(prompt: "Analyze backend auth handlers", branch_id: br_backend)
Task(prompt: "Analyze user/session tables", branch_id: br_database)

# Phase 3: Collect results
results = {
  frontend: branch_return(br_frontend).return_value,
  backend: branch_return(br_backend).return_value,
  database: branch_return(br_database).return_value
}

# Phase 4: Synthesize (new branch)
br_synthesis = branch_create(description: "Synthesize auth analysis")
# Use results from all three branches...
branch_return(br_synthesis, message: "Full auth architecture documented")
```

---

## Best Practices

| Practice | Why |
|----------|-----|
| Keep summaries concise | Only essential info returns to parent |
| Use complexity-based budgets | Match budget to task tier |
| Monitor at 70/85/95% thresholds | Graceful degradation |
| Record memories at boundaries | Cross-session learning |
| Use return_value for structured data | Enable dependent processing |
| Checkpoint before risky operations | Recovery capability |
| Clean up orphaned branches | Prevent resource leaks |

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Not returning from branch | Always call `branch_return` |
| Huge return messages | Summarize, don't dump |
| Nesting too deep | Max depth is 3 |
| Ignoring timeout | Branch auto-returns on timeout |
| Skipping budget monitoring | Check at 70%, 85%, 95% |
| Not recording memories | Record at branch start/end |
| Fixed budgets for all tasks | Use complexity-based allocation |
| No error handling | Handle timeouts and failures gracefully |
| Orphaned branches | Clean up at session start |

---

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Budget guessing | Under/over allocation | Use complexity assessment |
| Ignore budget warnings | Context overflow | Monitor thresholds |
| No return_value | Lost structured data | Always return structured findings |
| Skip memory recording | Lost cross-session context | Record at boundaries |
| Monolithic branches | Hard to recover | Break into smaller branches |
| No checkpoint integration | Can't resume | Checkpoint before risky ops |

---

## Quick Reference

| Scenario | Action |
|----------|--------|
| Starting sub-task | `branch_create` + `memory_record` |
| Mid-task check | `branch_status` -> check budget_percent |
| Budget at 70% | Plan exit strategy |
| Budget at 85% | Begin summarization |
| Budget at 95% | Force return |
| Task complete | `branch_return` + `memory_record` |
| Before risky op | `checkpoint_save` |
| Session start | Check for orphaned branches |
| Error in branch | Record remediation + return with error flag |
