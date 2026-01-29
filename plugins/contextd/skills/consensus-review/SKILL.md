---
name: consensus-review
description: Use when reviewing code changes, PRs, or plugins using multiple specialized agents in parallel - dispatches Security, Correctness, Architecture, and UX agents then synthesizes findings
---

# Consensus Review

Multi-agent code review that dispatches 4 specialized reviewers in parallel, then synthesizes findings into actionable recommendations.

## When to Use

- Reviewing pull requests before merge
- Evaluating plugin configurations
- Auditing security-sensitive code
- Assessing architectural decisions

## When NOT to Use

- Single-file typo fixes (overkill)
- Simple refactoring with no behavioral changes
- When you need quick feedback (use single reviewer)

## The 4 Reviewers

| Agent | Focus Areas |
|-------|-------------|
| **Security** | Injection, secrets, supply chain, permissions |
| **Correctness** | Logic errors, schema compliance, edge cases |
| **Architecture** | Structure, maintainability, patterns, extensibility |
| **UX/Documentation** | Clarity, completeness, examples, discoverability |

## Workflow

### Step 1: Identify Scope

Determine what to review: specific files (PR diff), directory, or commit range.

### Step 2: Dispatch Agents in Parallel

Launch all 4 agents using Task tool with `run_in_background=true`:

```
Task(subagent_type="general-purpose", run_in_background=true):
  "You are a SECURITY REVIEWER analyzing [scope].
   Focus on: injection, secrets exposure, supply chain, permissions.
   For each issue: Severity (CRITICAL/HIGH/MEDIUM/LOW), Location, Issue, Recommendation."

Task(subagent_type="general-purpose", run_in_background=true):
  "You are a CORRECTNESS REVIEWER analyzing [scope]..."

Task(subagent_type="general-purpose", run_in_background=true):
  "You are an ARCHITECTURE REVIEWER analyzing [scope]..."

Task(subagent_type="general-purpose", run_in_background=true):
  "You are a UX/DOCUMENTATION REVIEWER analyzing [scope]..."
```

### Step 3: Collect & Synthesize

1. Wait for all agents with `AgentOutputTool(block=true)`
2. Tally by severity across all agents
3. Identify consensus (issues flagged by 2+ agents = higher priority)
4. De-duplicate similar findings
5. Prioritize: Critical > High > Medium > Low

### Step 4: Present Report

```markdown
# Consensus Review: [Subject]

## Summary
| Agent | Issues | Critical | High | Medium | Low |
|-------|--------|----------|------|--------|-----|
| Security | N | n | n | n | n |
| Correctness | N | n | n | n | n |
| Architecture | N | n | n | n | n |
| UX/Docs | N | n | n | n | n |

## Critical Issues (Must Fix)
[Issues with CRITICAL severity]

## High Priority (Should Fix)
[Issues with HIGH severity OR flagged by 2+ agents]

## Recommendations
[Prioritized action items]
```

### Step 5: Record Memory

```
memory_record(
  project_id: "<project>",
  title: "Consensus review of [subject]",
  content: "Key findings: [summary]. Critical: [count]. Recommendations: [top 3]",
  outcome: "success",
  tags: ["code-review", "consensus"]
)
```

## Severity Definitions

| Severity | Definition | Action |
|----------|------------|--------|
| **CRITICAL** | Security vulnerability, data loss risk | Fix immediately |
| **HIGH** | Significant issue, maintainability risk | Fix before merge |
| **MEDIUM** | Technical debt, should improve | Plan to fix |
| **LOW** | Minor polish, nice to have | Backlog |

## Common Mistakes

| Mistake | Prevention |
|---------|------------|
| Running agents sequentially | Always use `run_in_background=true` |
| Not waiting for all agents | Use `AgentOutputTool(block=true)` for each |
| Skipping synthesis | Raw output is overwhelming - always synthesize |
| Not recording memory | Capture findings for future reference |

## Quick Reference

| Step | Action |
|------|--------|
| 1 | Identify files/scope |
| 2 | Dispatch 4 agents in parallel |
| 3 | Wait for all results |
| 4 | Synthesize: tally, de-duplicate, prioritize |
| 5 | Present summary + recommendations |
| 6 | Record memory with findings |

---

## Dynamic Reviewer Selection

### Context-Aware Agent Selection

Not all reviews need all 4 agents. Select dynamically based on change type:

| Change Type | Required Reviewers | Optional |
|-------------|-------------------|----------|
| Security-sensitive (auth, crypto) | Security, Correctness | Architecture |
| API changes | Correctness, UX/Docs, Architecture | Security |
| Documentation only | UX/Docs | - |
| Refactoring | Architecture, Correctness | - |
| New feature | All 4 | - |
| Bug fix | Correctness | Security (if auth-related) |

### Auto-Detection Rules

```json
{
  "file_patterns": {
    "auth|crypto|secret|password": ["Security", "Correctness"],
    "README|docs/|*.md": ["UX/Docs"],
    "test|spec": ["Correctness"],
    "schema|migration": ["Architecture", "Correctness"]
  },
  "label_mapping": {
    "security": ["Security", "Correctness"],
    "breaking-change": ["UX/Docs", "Architecture"],
    "performance": ["Architecture", "Correctness"]
  }
}
```

### Reviewer Selection Prompt

```
Task(prompt: |
  Analyze the diff scope and select appropriate reviewers:
  - Files changed: {{files}}
  - Labels: {{labels}}
  - Commit messages: {{messages}}
  
  Return: { "reviewers": ["Security", "Correctness"], "rationale": "..." }
|, run_in_background: false)
```

---

## Finding Relationships

### Cross-Finding Analysis

Identify relationships between findings from different agents:

| Relationship | Description | Priority Boost |
|--------------|-------------|----------------|
| `reinforces` | Same issue, different perspective | +1 severity |
| `contradicts` | Conflicting recommendations | Needs human review |
| `depends_on` | Fix A requires fixing B first | Order matters |
| `related` | Same root cause | Fix once |

### Relationship Detection

```json
{
  "finding_id": "sec_001",
  "relationships": [
    {
      "related_finding": "arch_003",
      "type": "reinforces",
      "reason": "Both identify missing input validation"
    },
    {
      "related_finding": "correct_002",
      "type": "depends_on",
      "reason": "Type fix required before validation can work"
    }
  ]
}
```

### Consensus Scoring

```
Base Score = Severity Weight (CRITICAL=4, HIGH=3, MEDIUM=2, LOW=1)

Adjustments:
  +1 for each additional agent flagging same issue
  +1 for 'reinforces' relationships
  +2 for security + correctness agreement
  -1 if 'contradicts' exists (flag for human)

Final Priority = Base Score + Adjustments
```

---

## Incremental Review

### Review Changed Lines Only

For large PRs, focus on actual changes:

```json
{
  "review_mode": "incremental",
  "baseline": "main",
  "target": "feature/new-auth",
  "include": {
    "changed_lines": true,
    "context_lines": 5,
    "new_files": true,
    "deleted_files": "summary_only"
  }
}
```

### Incremental vs Full Review

| Mode | When to Use | Speed |
|------|-------------|-------|
| `incremental` | PRs, focused changes | Fast |
| `full` | New features, audits | Thorough |
| `targeted` | Specific concerns | Fastest |

### Review Cache

Skip re-reviewing unchanged code:

```json
{
  "cache": {
    "enabled": true,
    "key": "file_hash + reviewer_version",
    "ttl_hours": 24,
    "invalidate_on": ["reviewer_update", "config_change"]
  }
}
```

---

## Unified Memory Type References

Tag review findings with standard types:

| Finding Type | Tag | Purpose |
|--------------|-----|---------|
| Security issue | `type:remediation`, `category:security` | Track for future |
| Architecture concern | `type:decision`, `category:architecture` | ADR candidate |
| Pattern violation | `type:failure`, `category:quality` | Learn from |
| Best practice | `type:pattern`, `category:quality` | Share broadly |

---

## Hierarchical Namespace Guidance

### Review Scopes

Structure review scopes for consistent tracking:

```
<org>/<project>/<pr_number>/<review_id>

Examples:
  fyrsmithlabs/contextd/PR-42/review_001
  fyrsmithlabs/marketplace/PR-15/review_002
```

### Cross-Project Findings

Link related findings across repositories:

```json
{
  "finding_id": "fyrsmithlabs/contextd/PR-42/sec_001",
  "cross_project_refs": [
    "fyrsmithlabs/marketplace/PR-15/sec_003"
  ],
  "shared_pattern": "Missing input validation on API endpoints"
}
```

---

## Audit Fields

All review findings record:

| Field | Description | Auto-set |
|-------|-------------|----------|
| `created_by` | Reviewer agent ID | Yes |
| `created_at` | ISO timestamp | Yes |
| `reviewed_at` | Human review timestamp | Manual |
| `resolved_at` | Fix verified timestamp | Manual |
| `usage_count` | Times referenced | Yes |

---

## Claude Code 2.1 Patterns

### Background Agent Dispatch

Launch reviewers without blocking:

```
security_task = Task(
  subagent_type: "general-purpose",
  prompt: "Security review of {{scope}}",
  run_in_background: true,
  description: "Security reviewer"
)

correctness_task = Task(
  subagent_type: "general-purpose",
  prompt: "Correctness review of {{scope}}",
  run_in_background: true,
  description: "Correctness reviewer"
)

// Continue with other work while reviews run...
```

### Task Dependencies for Review Flow

Chain review phases:

```
scope_task = Task(prompt: "Identify review scope from PR")
select_task = Task(prompt: "Select reviewers", addBlockedBy: [scope_task.id])
review_tasks = [
  Task(prompt: "Security review", addBlockedBy: [select_task.id]),
  Task(prompt: "Correctness review", addBlockedBy: [select_task.id])
]
synthesize_task = Task(prompt: "Synthesize findings", addBlockedBy: review_tasks.map(t => t.id))
```

### PreToolUse Hook for Auto-Review

Trigger review before merge operations:

```json
{
  "hook_type": "PreToolUse",
  "tool_name": "Bash",
  "condition": "command.contains('gh pr merge')",
  "prompt": "PR merge detected. Verify consensus review completed. If not, prompt user to run /consensus-review first."
}
```

### PostToolUse Hook for Finding Recording

Auto-record critical findings:

```json
{
  "hook_type": "PostToolUse",
  "tool_name": "Task",
  "condition": "task_description.contains('reviewer')",
  "prompt": "Review complete. If CRITICAL findings exist, auto-record to remediation_record for future reference."
}
```

---

## Event-Driven State Sharing

Consensus review emits events for other skills:

```json
{
  "event": "review_complete",
  "payload": {
    "scope": "PR-42",
    "reviewers": ["Security", "Correctness", "Architecture", "UX/Docs"],
    "critical_count": 0,
    "high_count": 2,
    "verdict": "approve_with_comments"
  },
  "notify": ["workflow", "orchestration"]
}
```

Subscribe to review events:
- `review_started` - Review agents dispatched
- `reviewer_complete` - Single agent finished
- `review_complete` - All agents finished, synthesis done
- `critical_found` - CRITICAL severity issue detected
- `consensus_reached` - 2+ agents agree on finding
