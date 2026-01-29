---
name: self-reflection
description: Use when reviewing agent behavior patterns, improving CLAUDE.md based on past failures, or checking ReasoningBank health. REQUIRES contextd MCP server - this skill is inoperable without it.
---

# Self-Reflection

Mine memories and remediations for behavior patterns, surface findings to user, remediate docs with pressure-tested improvements.

**Core loop:** Search -> Report -> User prioritizes -> Brainstorm -> Pressure test -> Apply

## When to Use

- Periodic review of agent behavior patterns
- After series of failures or poor outcomes
- Before major project milestones
- When CLAUDE.md feels stale or incomplete
- To check ReasoningBank health

## When NOT to Use

- Immediate error diagnosis -> use `contextd-workflow` skill
- Recording a single learning -> use `/remember`
- Checkpoint management -> use `contextd-workflow` skill

## Behavioral Taxonomy

Focus on **agent behaviors**, not technical failures:

| Behavior Type | Description | Examples |
|---------------|-------------|----------|
| **rationalized-skip** | Justified skipping required step | "too simple to test", "user implied consent" |
| **overclaimed** | Absolute language inappropriately | "ensures", "guarantees", "production ready" |
| **ignored-instruction** | Didn't follow CLAUDE.md/skill | Skipped contextd search, ignored TDD |
| **assumed-context** | Assumed without verification | Assumed permission, requirements, state |
| **undocumented-decision** | Significant choice without rationale | Changed architecture without comparison |

## Severity Overlay

| Severity | Combination |
|----------|-------------|
| **CRITICAL** | rationalized-skip + destructive/security operation |
| **HIGH** | rationalized-skip + validation skip, ignored-instruction |
| **MEDIUM** | overclaimed, assumed-context |
| **LOW** | undocumented-decision, style issues |

## The Report

For each finding, surface:

1. **Behavior Type** - Which taxonomy category
2. **Severity** - CRITICAL/HIGH/MEDIUM/LOW
3. **Evidence** - Memory/remediation IDs with excerpts
4. **Violated Instruction** - The skill/command/CLAUDE.md section ignored
5. **Suggested Fix** - Target doc and proposed change
6. **Pressure Scenario** - Test case from real failure

## Remediation Flow

```
Present findings
      |
User selects findings to remediate
      |
Generate doc improvements
      |
Generate pressure scenarios (from real failures)
      |
Run batch tests via subagents
      |
  Pass? --No--> Iterate
      | Yes
Create Issue/PR
      |
Apply changes
      |
Close feedback loop:
  memory_feedback(memory_id, helpful=true)
  Tag original memories as remediated
```

## Behavioral Search Queries

```
# Rationalized skips
memory_search("skip OR skipped OR bypass OR ignored")
memory_search("too simple OR trivial OR obvious")

# User feedback indicating ignored instructions
memory_search("why did you OR should have OR forgot to")

# Assumptions without verification
memory_search("assumed OR without checking")

# Overclaiming
memory_search("ensures OR guarantees OR production ready")
```

Filter out technical bugs: Exclude memories with `error:*` tags or stack traces.

## ReasoningBank Health

`--health` flag analyzes:

- **Memory quality**: feedback rate, confidence distribution
- **Tag hygiene**: inconsistent tags needing consolidation
- **Stale content**: old memories without feedback
- **Remediation completeness**: missing fields

## Quick Reference

| Action | Command |
|--------|---------|
| Full report | `/reflect` |
| Health only | `/reflect --health` |
| Apply fixes | `/reflect --apply` |
| Recent only | `/reflect --since=7d` |
| Filter by behavior | `/reflect --behavior=rationalized-skip` |
| Filter by severity | `/reflect --severity=HIGH` |

## Anti-Patterns

| Mistake | Why It Fails |
|---------|--------------|
| Skipping pressure tests | "Fixed" docs don't actually prevent behavior |
| Modifying plugin source | Breaks on update; use includes |
| Auto-applying security fixes | High-stakes changes need review |
| Ignoring frequency | 10 TDD skips is systemic, not minor |
| Absolute claims in fixes | "This prevents X" -> "This helps reduce X" |

---

## Causal Chain Analysis

### Root Cause Tracing

Go beyond symptoms to find root causes:

```json
{
  "finding_id": "ref_001",
  "behavior": "rationalized-skip",
  "symptom": "Skipped tests before claiming fix complete",
  "causal_chain": [
    {
      "level": 1,
      "cause": "Agent claimed fix without running tests",
      "evidence": ["mem_123", "mem_124"]
    },
    {
      "level": 2,
      "cause": "CLAUDE.md test instruction buried in long section",
      "evidence": ["claude_md_line_245"]
    },
    {
      "level": 3,
      "cause": "No PreToolUse hook enforcing test requirement",
      "evidence": ["hooks.json missing enforcement"]
    }
  ],
  "root_cause": "Missing automated enforcement of test-before-fix policy",
  "fix_target": "hooks.json + CLAUDE.md restructure"
}
```

### Chain Depth Levels

| Level | Description | Fix Location |
|-------|-------------|--------------|
| 1 | Immediate behavior | Agent prompt/skill |
| 2 | Missing guidance | CLAUDE.md/documentation |
| 3 | Missing enforcement | Hooks/automation |
| 4 | Systemic gap | Plugin/skill redesign |

### Multi-Incident Correlation

Find patterns across incidents:

```
causal_correlate(findings: [ref_001, ref_002, ref_003])

Returns:
  shared_root_causes: [
    { cause: "Missing hook enforcement", incidents: [ref_001, ref_002] },
    { cause: "Ambiguous CLAUDE.md section", incidents: [ref_002, ref_003] }
  ]
  recommended_fixes: [
    { target: "hooks.json", impact: "high", fixes_incidents: 2 }
  ]
```

---

## Comparative Benchmarks

### Behavior Metrics Over Time

Track improvement (or regression):

```json
{
  "benchmark_period": "2026-01-01 to 2026-01-28",
  "metrics": {
    "rationalized_skip": {
      "count": 5,
      "previous_period": 12,
      "trend": "improving",
      "change_pct": -58
    },
    "ignored_instruction": {
      "count": 8,
      "previous_period": 6,
      "trend": "regressing",
      "change_pct": +33
    },
    "assumed_context": {
      "count": 3,
      "previous_period": 3,
      "trend": "stable",
      "change_pct": 0
    }
  }
}
```

### Benchmark Categories

| Metric | Target | Good | Warning | Critical |
|--------|--------|------|---------|----------|
| rationalized_skip/week | 0 | < 2 | 2-5 | > 5 |
| ignored_instruction/week | 0 | < 3 | 3-7 | > 7 |
| overclaimed/week | 0 | < 5 | 5-10 | > 10 |
| test_coverage_skip | 0% | < 5% | 5-15% | > 15% |

### Comparative Reports

```
/reflect --benchmark --compare-periods "2026-01" "2025-12"

Output:
  | Behavior | Dec 2025 | Jan 2026 | Change |
  |----------|----------|----------|--------|
  | rationalized-skip | 12 | 5 | -58% |
  | ignored-instruction | 6 | 8 | +33% |

  Top Improvement: Hook enforcement reduced skips
  Top Regression: New skills lack CLAUDE.md entries
```

---

## Behavioral Prediction

### Pattern-Based Prediction

Predict likely future failures based on patterns:

```json
{
  "prediction": {
    "behavior": "rationalized-skip",
    "likelihood": 0.75,
    "conditions": [
      "Complex task with > 5 sub-steps",
      "Time pressure mentioned in prompt",
      "No explicit test requirement in task"
    ],
    "historical_basis": ["mem_101", "mem_102", "mem_103"],
    "prevention": "Add explicit test checkpoint to complex task prompts"
  }
}
```

### Risk Factors

| Factor | Risk Increase | Mitigation |
|--------|---------------|------------|
| Task complexity > 5 steps | +40% skip risk | Explicit checkpoints |
| "Quick fix" language | +60% skip risk | Reject quick-fix framing |
| No acceptance criteria | +50% assumption risk | Require criteria |
| Security-adjacent code | +30% overclaim risk | Require review |

### Predictive Alerts

```json
{
  "alert": "high_risk_task_detected",
  "task_description": "Quick fix for authentication bug",
  "risk_factors": ["quick_fix_language", "security_adjacent"],
  "predicted_behaviors": ["rationalized-skip", "assumed-context"],
  "recommended_guardrails": [
    "Require explicit test plan before starting",
    "Trigger consensus-review before merge"
  ]
}
```

### Intervention Hooks

Auto-intervene when risk detected:

```json
{
  "hook_type": "PreToolUse",
  "tool_name": "Edit",
  "condition": "file_path.contains('auth') AND prediction.skip_risk > 0.5",
  "prompt": "High skip risk detected for security code. Before editing, confirm: 1) Tests exist 2) Review planned 3) No assumptions about user state"
}
```

---

## Unified Memory Type References

Tag reflection findings with standard types:

| Finding Type | Tag | Purpose |
|--------------|-----|---------|
| Behavior pattern | `type:pattern`, `category:behavior` | Track patterns |
| Root cause | `type:decision`, `category:analysis` | Document cause |
| Fix proposal | `type:learning`, `category:improvement` | Capture fix |
| Regression | `type:failure`, `category:regression` | Track setbacks |
| Policy update | `type:policy`, `category:enforcement` | New rules |

---

## Hierarchical Namespace Guidance

### Reflection Namespaces

```
<org>/<project>/reflections/<reflection_id>

Examples:
  fyrsmithlabs/contextd/reflections/2026-01-weekly
  fyrsmithlabs/marketplace/reflections/v1.6-pre-release
```

### Finding Namespaces

```
<reflection_namespace>/findings/<finding_id>

Example:
  fyrsmithlabs/contextd/reflections/2026-01-weekly/findings/ref_001
```

---

## Audit Fields

All reflection records include:

| Field | Description | Auto-set |
|-------|-------------|----------|
| `created_by` | Reflection agent/session | Yes |
| `created_at` | Analysis timestamp | Yes |
| `period_start` | Analysis period start | Yes |
| `period_end` | Analysis period end | Yes |
| `memory_count` | Memories analyzed | Yes |
| `finding_count` | Findings generated | Yes |
| `remediation_count` | Fixes applied | Yes |

---

## Claude Code 2.1 Patterns

### Background Analysis

Run reflection analysis without blocking:

```
Task(
  subagent_type: "general-purpose",
  prompt: "Analyze memories for behavior patterns over past 7 days",
  run_in_background: true,
  description: "Background reflection analysis"
)

// Continue other work...
// Collect results later:
TaskOutput(task_id, block: true)
```

### Task Dependencies for Reflection Flow

Chain reflection phases:

```
search_task = Task(prompt: "Search memories for behavior patterns")
analyze_task = Task(prompt: "Analyze patterns, build causal chains", addBlockedBy: [search_task.id])
benchmark_task = Task(prompt: "Compare to previous period", addBlockedBy: [analyze_task.id])
predict_task = Task(prompt: "Generate predictions", addBlockedBy: [analyze_task.id])
report_task = Task(prompt: "Synthesize report", addBlockedBy: [benchmark_task.id, predict_task.id])
```

### PreToolUse Hook for High-Risk Detection

Auto-alert on predicted risky operations:

```json
{
  "hook_type": "PreToolUse",
  "tool_name": "Edit|Bash",
  "condition": "prediction_model.risk_score > 0.7",
  "prompt": "High-risk operation predicted. Review risk factors and confirm guardrails are in place before proceeding."
}
```

### PostToolUse Hook for Pattern Recording

Auto-record behavior patterns:

```json
{
  "hook_type": "PostToolUse",
  "tool_name": "Task",
  "condition": "task_description.contains('reflection')",
  "prompt": "Reflection complete. Record findings to memory with type:pattern tags. Update benchmarks."
}
```

---

## Event-Driven State Sharing

Self-reflection emits events for other skills:

```json
{
  "event": "reflection_complete",
  "payload": {
    "reflection_id": "2026-01-weekly",
    "findings_count": 12,
    "critical_count": 1,
    "high_count": 3,
    "trend": "improving",
    "top_behavior": "rationalized-skip"
  },
  "notify": ["setup", "workflow", "orchestration"]
}
```

Subscribe to reflection events:
- `reflection_started` - Analysis began
- `reflection_complete` - Analysis finished
- `critical_finding` - CRITICAL behavior detected
- `regression_detected` - Metrics worsening
- `benchmark_updated` - New baseline recorded
- `prediction_generated` - Risk prediction available
- `intervention_triggered` - Auto-guardrail activated
