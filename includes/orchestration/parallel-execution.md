# Parallel Agent Execution

Patterns for dispatching and managing multiple agents concurrently.

## Overview

Parallel execution enables multiple agents to work simultaneously on independent sub-tasks. The orchestrator dispatches agents, monitors their progress, and collects results when complete.

## Dispatch Pattern

Use the `Task` tool with background execution for agent dispatch:

```
Task tool call:
  description: "Agent purpose and sub-task"
  prompt: "Detailed instructions for the agent"
  run_in_background: true
```

**Key principles:**

1. **Launch independent agents together** - Multiple `Task` calls in a single message execute in parallel
2. **Collect agent IDs** - Track which agents are running for later result collection
3. **Define clear boundaries** - Each agent should have a well-scoped, independent task

## Concurrency Limits

| Orchestration Type | Default Max Agents | Configurable |
|-------------------|-------------------|--------------|
| contextd          | 4                 | Yes          |
| research          | 4                 | Yes          |
| consensus-review  | 6                 | No           |

**Why limits matter:**
- Prevents resource exhaustion
- Ensures meaningful result synthesis
- Keeps orchestration manageable

## Agent Dispatch Example

```markdown
## Dispatch Phase

Launching 3 agents in parallel:

[Task call 1]
description: "Security analysis agent"
prompt: "Analyze {files} for security vulnerabilities. Focus on: injection, auth, secrets."
run_in_background: true

[Task call 2]
description: "Performance analysis agent"
prompt: "Analyze {files} for performance issues. Focus on: complexity, memory, I/O."
run_in_background: true

[Task call 3]
description: "Documentation analysis agent"
prompt: "Check {files} for documentation completeness. Focus on: public APIs, examples."
run_in_background: true
```

## Monitoring Progress

Use `TaskOutput` to check agent status:

```
TaskOutput:
  task_id: "{agent_id}"
  block: false  # Non-blocking status check
```

**Status indicators:**
- Agent still running: Partial output or "in progress" message
- Agent complete: Full output available
- Agent failed: Error message in output

## Error Handling

### Individual Agent Failures

Individual agent failures do not stop the orchestration:

```markdown
## Error Handling Protocol

1. Log failed agent to dead letter queue
2. Continue with remaining agents
3. Report partial results with failure notes
4. Include failure context in synthesis
```

### Retry Policy

| Attempt | Delay | Action |
|---------|-------|--------|
| 1 | Immediate | Initial execution |
| 2 | 5 seconds | Retry with same prompt |
| 3 | 15 seconds | Retry with simplified prompt |
| Failed | - | Log and continue without |

### Dead Letter Queue Format

```markdown
## Failed Agents

| Agent | Task | Error | Attempts |
|-------|------|-------|----------|
| security-1 | Scan auth module | Timeout | 3 |
```

## Collection Phase

Wait for all agents before synthesis:

```
TaskOutput:
  task_id: "{agent_id}"
  block: true  # Blocking wait for completion
```

**Collection order:**
1. Wait for all agents (blocking)
2. Parse outputs into structured format
3. Validate outputs have expected sections
4. Pass to synthesis phase

## Agent Output Requirements

Each agent must produce structured output for synthesis:

```markdown
## Agent Output Format

### Findings
- [Finding 1 with evidence]
- [Finding 2 with evidence]

### Recommendations
- [Actionable recommendation 1]
- [Actionable recommendation 2]

### Confidence
- Overall: [HIGH/MEDIUM/LOW]
- Per finding: [if applicable]

### Sources
- [Files/docs examined]
```

## Dispatch Checklist

Before dispatching agents:

- [ ] Tasks are truly independent (no dependencies between agents)
- [ ] Each agent has clear, scoped instructions
- [ ] Output format is specified in agent prompts
- [ ] Concurrency limit not exceeded
- [ ] Error handling strategy defined

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Sequential dispatch | Loses parallelization benefit | Dispatch all independent agents together |
| Vague prompts | Inconsistent outputs | Specify exact output format |
| No timeout | Stuck agents block orchestration | Set reasonable timeouts |
| Ignore failures | Missing context in synthesis | Log and report failures |
| Over-dispatch | Resource exhaustion | Respect concurrency limits |
