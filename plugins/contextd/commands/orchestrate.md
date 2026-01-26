---
name: orchestrate
description: Execute multi-task orchestration from GitHub issues or epics with parallel agents and consensus reviews
arguments:
  - name: issues
    description: "Comma-separated issue numbers (e.g., '42,43,44') or epic number"
    required: false
  - name: groups
    description: "Comma-separated list of group numbers to execute (e.g., '2,3,4')"
    required: false
  - name: review-threshold
    description: "Consensus review threshold: 'strict' (100%), 'standard' (no vetoes), 'advisory' (report only)"
    required: false
  - name: resume
    description: "Resume from checkpoint name (e.g., 'group-2-complete')"
    required: false
---

# /orchestrate

**Agent:** `contextd:orchestrator`
**Skill:** `contextd:orchestration`

## Input Resolution

If no issues provided, prompt the user:

```
AskUserQuestion(
  questions: [{
    question: "Which issues or epic would you like to orchestrate?",
    header: "Issues",
    options: [
      { label: "Enter issue numbers", description: "Comma-separated list (e.g., 42,43,44)" },
      { label: "Select an epic", description: "Epic issue that contains sub-issues" },
      { label: "Current milestone", description: "All open issues in current milestone" }
    ],
    multiSelect: false
  }]
)
```

## Issue Discovery

Once issues are identified:

```
1. Fetch issue details:
   gh issue view <number> --json title,body,labels,milestone

2. For epics, fetch sub-issues:
   gh issue list --search "parent:<epic_number>"

3. Extract task information:
   - Title → Task name
   - Body → Agent prompt (look for ## Agent Prompt section)
   - Labels → Priority (P0, P1, P2)
   - Dependencies from body (Depends On: #XX, #YY)

4. Build dependency graph from issue relationships
```

## Usage

```bash
# Execute specific issues
/contextd:orchestrate 42,43,44

# Execute all sub-issues of an epic
/contextd:orchestrate 100

# Execute with strict review
/contextd:orchestrate 42,43 --review-threshold strict

# Resume from checkpoint
/contextd:orchestrate --resume "group-2-complete"
```

## Execution

Load and follow the `contextd:orchestration` skill for the complete workflow.

## Key Capabilities

- **Issue-driven** - Works directly from GitHub issues
- **Epic support** - Orchestrate all sub-issues of an epic
- **Parallel execution** with context folding per group
- **Dependency resolution** from issue relationships
- **Consensus review** with veto-powered security agents
- **Checkpoint/resume** for long-running orchestrations
