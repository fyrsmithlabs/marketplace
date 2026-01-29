# Context Management

Patterns for managing context across orchestrated agents.

## Overview

Effective context management ensures agents have the information they need while preventing context pollution and enabling learning capture. This includes context isolation, memory integration, and state sharing protocols.

## Context Isolation Strategies

### With Context Folding (contextd available)

Use `branch_create` to isolate agent execution:

```markdown
## Branch-Based Isolation

For each agent task:
1. branch_create(description, prompt, budget)
2. Agent executes in isolated context
3. branch_return(summary) sends results back
4. Main context grows minimally (~50 tokens per agent)
```

**Benefits:**
- Prevents context pollution
- Automatic budget enforcement
- Clean separation of concerns

### Without Context Folding

Agents operate independently via Task tool:

```markdown
## Task-Based Isolation

1. Task tool dispatches agent with full prompt
2. Agent executes with fresh context
3. TaskOutput retrieves results
4. Orchestrator maintains summary state
```

**Tradeoffs:**
- No automatic context budget
- Results may be verbose
- Manual summarization required

## Budget Allocation

### Per-Agent Budgets

| Task Complexity | Recommended Budget | Use Case |
|-----------------|-------------------|----------|
| Simple lookup | 4,096 tokens | Find specific info |
| Standard analysis | 8,192 tokens | Review single file |
| Complex analysis | 12,288 tokens | Multi-file analysis |
| Deep investigation | 16,384 tokens | Architecture analysis |

### Orchestration Budget Planning

```markdown
## Budget Example: 4-Agent Orchestration

Total budget: 40,000 tokens
- Orchestrator overhead: 8,000 tokens
- Per-agent budget: (40,000 - 8,000) / 4 = 8,000 tokens each

Agent allocations:
- security-reviewer: 8,000
- performance-reviewer: 8,000
- documentation-reviewer: 8,000
- code-quality-reviewer: 8,000
```

## Memory Integration

### Pre-Orchestration Search

Before dispatching agents, check for relevant past orchestrations:

```markdown
## Memory Search Protocol

1. memory_search(project_id, "orchestration {task-type}")
2. Review past approaches and outcomes
3. Adjust agent prompts based on learnings
4. Note relevant memories to include in synthesis
```

**Search queries:**
- `"orchestration review"` - Past review patterns
- `"orchestration failure"` - What went wrong before
- `"synthesis conflict"` - How conflicts were resolved

### Post-Orchestration Recording

Record orchestration outcomes for future reference:

```markdown
## Memory Record Protocol

memory_record(
  project_id: "{project}",
  title: "Orchestration: {task-type} - {outcome}",
  content: "Approach: {approach}. Agents: {count}. Key findings: {summary}. Learnings: {insights}",
  outcome: "{success/failure/partial}",
  tags: ["type:orchestration", "category:{task-type}", ...]
)
```

### Recommended Tags

| Tag | Purpose |
|-----|---------|
| `type:orchestration` | Identifies orchestration memories |
| `category:{task}` | Task type (review, research, analysis) |
| `outcome:{result}` | Success/failure/partial |
| `agents:{count}` | Number of agents used |
| `conflicts:{count}` | Conflicts encountered |

## State Sharing Protocol

### Orchestrator-to-Agent Communication

Agents receive read-only context from the orchestrator:

```markdown
## Agent Context Package

Each agent receives:
1. Task-specific instructions
2. Relevant file paths/content
3. Constraints (budget, scope)
4. Output format requirements

Agents do NOT receive:
- Other agents' progress
- Orchestration state
- Past agent outputs (during execution)
```

### No Direct Agent-to-Agent Communication

```
     Orchestrator
    /      |      \
Agent A  Agent B  Agent C
   |        |        |
Output A Output B Output C
    \       |       /
     Orchestrator
```

**Rationale:**
- Prevents circular dependencies
- Ensures reproducible results
- Simplifies error handling

### Hub-Based Coordination

All coordination flows through the orchestrator:

```markdown
## Coordination Flow

1. Orchestrator defines tasks
2. Orchestrator dispatches agents
3. Agents work independently
4. Orchestrator collects results
5. Orchestrator synthesizes outputs
6. Orchestrator handles conflicts
```

## Context Checkpointing

### When to Checkpoint

| Trigger | Action |
|---------|--------|
| All agents dispatched | `checkpoint_save("dispatch-complete")` |
| Agent group completes | `checkpoint_save("phase-{n}-complete")` |
| Before synthesis | `checkpoint_save("pre-synthesis")` |
| After synthesis | `checkpoint_save("post-synthesis")` |

### Checkpoint Contents

```markdown
## Checkpoint: phase-1-complete

### State
- Dispatched agents: [list]
- Completed agents: [list]
- Pending agents: [list]
- Failed agents: [list]

### Partial Results
- Agent A summary: [brief]
- Agent B summary: [brief]

### Next Steps
- Wait for remaining agents
- Begin synthesis after completion
```

## Error Recovery

### Agent Failure Recovery

```markdown
## Recovery Protocol

1. Log failure with error details
2. Check if task is critical
3. If critical: Attempt retry (max 3)
4. If non-critical: Continue without
5. Note gap in synthesis
```

### Context Overflow Recovery

```markdown
## Overflow Protocol

1. Detect context approaching limit (80%)
2. Checkpoint current state
3. Summarize verbose outputs
4. Continue with compressed context
5. Or: Resume from checkpoint in new session
```

## Best Practices

### DO

- Allocate explicit budgets per agent
- Search memories before orchestrating
- Record outcomes after completion
- Checkpoint between phases
- Keep agent contexts isolated

### DON'T

- Share raw context between agents
- Skip pre-orchestration memory search
- Ignore partial failures
- Exceed concurrency limits
- Forget to record learnings

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Context bleed | Agents affect each other | Use branch isolation |
| No memory search | Repeat past mistakes | Always search first |
| Skip checkpoints | Lose progress on failure | Checkpoint each phase |
| Ignore budgets | Agents exhaust context | Enforce per-agent limits |
| No post-recording | Learnings lost | Always record outcomes |
