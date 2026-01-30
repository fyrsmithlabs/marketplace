# Orchestration Patterns

Shared patterns for multi-agent workflow coordination used by orchestration skills.

## What is Orchestration?

Orchestration coordinates multiple agents working in parallel to accomplish complex tasks. An **orchestrator** acts as a hub that:

1. Dispatches agents with specific sub-tasks
2. Monitors progress and handles failures
3. Synthesizes results into a coherent output
4. Manages context and checkpoints

## When to Use Orchestration

| Use Case | Single Agent | Orchestration |
|----------|--------------|---------------|
| Simple file edit | Yes | No |
| Code review (one file) | Yes | No |
| Multi-perspective review | No | Yes |
| Research with multiple sources | No | Yes |
| Complex refactoring | Maybe | Yes |
| Architecture analysis | No | Yes |

**Rule of thumb:** If a task benefits from multiple independent perspectives or can be parallelized into distinct sub-tasks, use orchestration.

## Available Patterns

| Pattern File | Purpose |
|--------------|---------|
| [parallel-execution.md](./parallel-execution.md) | Dispatching and managing concurrent agents |
| [result-synthesis.md](./result-synthesis.md) | Collecting and consolidating agent outputs |
| [context-management.md](./context-management.md) | Context isolation and memory integration |
| [checkpoint-patterns.md](./checkpoint-patterns.md) | Save and resume for long-running orchestrations |

## Skills Using These Patterns

| Skill | Use Case |
|-------|----------|
| `contextd:orchestration` | General multi-task execution with contextd integration |
| `research:orchestration` | Research workflows with source synthesis |

## How Skills Reference Patterns

Skills include these patterns using the `{{include:}}` directive:

```markdown
## Parallel Execution
{{include: orchestration/parallel-execution.md}}

## Result Synthesis
{{include: orchestration/result-synthesis.md}}
```

This keeps skills DRY while allowing customization in the skill-specific sections.

## Orchestration vs Context Folding

| Feature | Context Folding | Orchestration |
|---------|-----------------|---------------|
| Scope | Single sub-task isolation | Multiple parallel agents |
| Tool | `branch_create`/`branch_return` | `Task` tool with background execution |
| Communication | Branch returns summary | Agents write outputs |
| State | Automatic context management | Explicit checkpoint management |

**Orchestration can use context folding internally** - each dispatched agent may use `branch_create` for its own sub-tasks if contextd is available.

## Architecture

```
                    +----------------+
                    |  Orchestrator  |
                    +-------+--------+
                            |
            +---------------+---------------+
            |               |               |
      +-----v-----+   +-----v-----+   +-----v-----+
      |  Agent 1  |   |  Agent 2  |   |  Agent 3  |
      +-----------+   +-----------+   +-----------+
            |               |               |
      +-----v-----+   +-----v-----+   +-----v-----+
      |  Output 1 |   |  Output 2 |   |  Output 3 |
      +-----------+   +-----------+   +-----------+
            |               |               |
            +---------------+---------------+
                            |
                    +-------v--------+
                    |   Synthesis    |
                    +----------------+
```

## Quick Reference

**Dispatch agents:**
```
Task tool with run_in_background: true
Launch independent agents in parallel
```

**Collect results:**
```
TaskOutput with block: false for status
block: true when ready to synthesize
```

**Save state:**
```
checkpoint_save after each phase (if contextd available)
```

**Record learnings:**
```
memory_record with orchestration outcomes (if contextd available)
```
