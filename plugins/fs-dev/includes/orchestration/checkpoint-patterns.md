# Checkpoint Patterns

Save and resume patterns for long-running orchestrations.

## Overview

Checkpoints enable recovery from failures, session interruptions, and context limits. They capture orchestration state at key milestones, allowing work to resume without starting over.

## When to Checkpoint

### Automatic Triggers

| Trigger | Checkpoint Name | Priority |
|---------|-----------------|----------|
| All agents dispatched | `{type}-dispatch-complete` | Medium |
| Phase/group completes | `{type}-phase-{n}-complete` | High |
| Context at 70% | `{type}-budget-warning` | High |
| Before synthesis | `{type}-pre-synthesis` | Critical |
| After synthesis | `{type}-complete` | High |

### Manual Triggers

Create checkpoints before:
- Resource-intensive operations
- Operations that modify external state
- Long-running agent tasks
- Any point where restart would be costly

## Checkpoint Contents

### Required State

```markdown
## Checkpoint: {orchestration-type}-phase-{n}-complete

### Orchestration Metadata
- Type: {orchestration-type}
- Started: {timestamp}
- Checkpoint created: {timestamp}
- Duration: {elapsed}

### Task State
- Total tasks: {count}
- Completed: {count} [{list}]
- In progress: {count} [{list}]
- Pending: {count} [{list}]
- Failed: {count} [{list with reasons}]

### Completed Results (Summarized)
- Task A: {brief summary}
- Task B: {brief summary}

### Next Actions
1. {what to do next}
2. {subsequent step}
```

### Optional State

- Partial agent outputs (if valuable)
- Conflict notes
- Memory references used
- Files modified

## Save Protocol

### With contextd

```markdown
## Save Checkpoint

checkpoint_save(
  name: "{orchestration-type}-{phase}-complete",
  summary: "Completed: {X}/{total}. Remaining: {list}. Next: {action}",
  description: "Phase {n} complete. Results: {brief}. Failures: {count}"
)
```

### Naming Convention

```
{orchestration-type}-{milestone}[-{detail}]

Examples:
- research-dispatch-complete
- review-phase-2-complete
- analysis-pre-synthesis
- orchestration-budget-warning-75pct
- research-complete
```

### Summary Guidelines

Keep summaries actionable:

| Good | Bad |
|------|-----|
| "3/4 agents complete. Waiting on security." | "Some progress made." |
| "Synthesis ready. 2 conflicts to resolve." | "Almost done." |
| "Phase 1 done: 5 findings. Starting phase 2." | "Continuing work." |

## Resume Protocol

### Step 1: Find Checkpoint

```markdown
## List Available Checkpoints

checkpoint_list(
  project_path: "{path}",
  limit: 5
)

## Expected Output
| Name | Created | Summary |
|------|---------|---------|
| research-phase-2-complete | 2h ago | 3/4 sources processed |
| research-dispatch-complete | 3h ago | All agents launched |
```

### Step 2: Resume from Checkpoint

```markdown
## Resume Checkpoint

checkpoint_resume(
  checkpoint_id: "{id}",
  level: "full"  # or "summary" for lighter restore
)
```

### Step 3: Continue Work

```markdown
## Post-Resume Protocol

1. Parse restored state
2. Identify completed vs pending tasks
3. Skip completed work (use saved results)
4. Resume from next pending task
5. Continue normal orchestration flow
```

## Without contextd

### Manual State Tracking

If contextd is unavailable, track state manually:

```markdown
## Manual Checkpoint

### Orchestration State (Manual)

**Timestamp:** {ISO timestamp}
**Phase:** {current phase}

**Completed Tasks:**
- [ ] Task A - Result: {summary}
- [ ] Task B - Result: {summary}

**Pending Tasks:**
- [ ] Task C
- [ ] Task D

**To Resume:**
1. Re-run orchestration
2. Use --skip-completed flag
3. Reference above results for completed tasks
```

### Resume with Skip Flags

```markdown
## Manual Resume

When resuming manually:
1. Check the manual checkpoint above
2. Mark completed tasks as skip
3. Provide saved results for synthesis
4. Continue with pending tasks only
```

## Budget-Triggered Checkpoints

### Detection

Monitor context usage during orchestration:

```markdown
## Budget Monitoring

Context thresholds:
- 70%: Warning - consider checkpoint
- 80%: Critical - checkpoint required
- 90%: Emergency - checkpoint and pause
```

### Response Protocol

```markdown
## Budget Warning Response

1. Immediately checkpoint current state
2. Summarize all verbose outputs
3. Compress agent results to essentials
4. If 90%+: Pause and inform user
5. Continue with compressed context or new session
```

## Time-Based Checkpoints

For long orchestrations, checkpoint periodically:

| Duration | Checkpoint Frequency |
|----------|---------------------|
| < 5 min | None needed |
| 5-15 min | After each phase |
| 15-30 min | Every 10 minutes |
| 30+ min | Every 10 minutes + each phase |

## Checkpoint Cleanup

### Retention Policy

| Checkpoint Type | Retention |
|-----------------|-----------|
| `-complete` | Keep for 7 days |
| `-phase-N-complete` | Keep until orchestration completes |
| `-budget-warning` | Delete after successful completion |
| `-dispatch-complete` | Delete after phase 1 completes |

### Cleanup Protocol

After successful orchestration:

```markdown
## Cleanup

1. Keep final `-complete` checkpoint
2. Remove intermediate checkpoints
3. Optionally archive for analysis
```

## Recovery Scenarios

### Scenario 1: Session Interrupted

```markdown
## Recovery: Session Interrupted

1. Start new session
2. checkpoint_list to find latest
3. checkpoint_resume with full level
4. Verify state restored correctly
5. Continue from where stopped
```

### Scenario 2: Agent Failed After Partial Progress

```markdown
## Recovery: Partial Failure

1. Checkpoint saves partial results
2. Resume skips completed agents
3. Retry or skip failed agent
4. Continue synthesis with available results
```

### Scenario 3: Context Limit Reached

```markdown
## Recovery: Context Overflow

1. Checkpoint triggered at 70% warning
2. Start new session
3. Resume with summary level
4. Continue with compressed context
5. Reference checkpoint for full details if needed
```

## Best Practices

### DO

- Checkpoint before expensive operations
- Use descriptive names
- Include actionable summaries
- Clean up intermediate checkpoints
- Test resume procedures

### DON'T

- Skip checkpoints to save time
- Use vague summaries
- Keep all checkpoints forever
- Assume resume works without testing
- Ignore budget warnings

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| No checkpoints | Lose all progress on failure | Checkpoint each phase |
| Too many checkpoints | Clutters state, slows down | Checkpoint at milestones only |
| Vague summaries | Can't understand state | Include counts and next actions |
| No cleanup | Storage bloat | Delete intermediate after completion |
| Ignore budget warnings | Context overflow | Checkpoint immediately at 70% |
