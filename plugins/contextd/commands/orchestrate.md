---
name: orchestrate
description: Execute multi-task orchestration plans with parallel agents and consensus reviews
arguments:
  - name: plan-file
    description: "Path to orchestration plan file (markdown with task definitions)"
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

## Execution

Load and follow the `contextd:orchestration` skill for the complete workflow.

## Usage

```bash
# Execute from plan file
/orchestrate PHASE2-ORCHESTRATION-PLAN.md

# Execute specific groups
/orchestrate --groups "3,4,5"

# Strict review (100% findings fixed)
/orchestrate --review-threshold strict

# Resume from checkpoint
/orchestrate --resume "group-2-complete"
```

## Key Capabilities

- **Parallel execution** with context folding per group
- **Dependency resolution** via topological sort
- **Consensus review** with veto-powered security agents
- **Automatic remediation** with past fix lookup
- **Checkpoint/resume** for long-running orchestrations
- **RALPH reflection** for learning capture
