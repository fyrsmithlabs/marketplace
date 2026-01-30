# Consensus Review Patterns

## Overview
Patterns for reviewing orchestration outputs and ensuring quality thresholds are met before finalization.

## Consensus Thresholds

| Orchestration Type | Consensus Required | Critical/High Allowed | Re-attempt |
|--------------------|-------------------|----------------------|------------|
| Research | >= 70% | 0 | Re-synthesize with feedback |
| Task (contextd) | 100% | 0 (veto blocks) | Fix and re-review |

## Review Agent Dispatch

After synthesis/completion, dispatch review agents:

```
# Research orchestration reviewers
Task(subagent_type: "documentation-reviewer", ...)
Task(subagent_type: "code-quality-reviewer", ...) # if code examples present

# Task orchestration reviewers (all with veto)
Task(subagent_type: "security-reviewer", ...)
Task(subagent_type: "vulnerability-reviewer", ...)
Task(subagent_type: "code-quality-reviewer", ...)
Task(subagent_type: "documentation-reviewer", ...)
# ... additional reviewers as needed
```

## Consensus Calculation

```
consensus_score = (approvals / total_reviewers) * 100

# Severity classification
CRITICAL: Security vulnerabilities, data loss risk, breaking production
HIGH: Significant bugs, performance issues, incorrect behavior
MEDIUM: Code quality issues, minor bugs, style violations
LOW: Suggestions, minor improvements, nitpicks
```

## Re-Synthesis Loop (Research)

When consensus < 70% OR critical/high findings exist:

1. Collect feedback from all reviewers
2. Format feedback for synthesis agent:
```markdown
## Re-Synthesis Required (Iteration {n})

### Previous Consensus: {X}%
### Target: >= 70% with no critical/high

### Critical Findings (MUST fix)
- [{reviewer}] {finding}

### High Findings (MUST fix)
- [{reviewer}] {finding}

### Medium Findings (SHOULD address)
- [{reviewer}] {finding}

### Specific Changes Required
1. {change from reviewer feedback}
2. {change from reviewer feedback}
```

3. Re-run synthesis agent with feedback
4. Re-run consensus review
5. Loop until passing (max 3 iterations)
6. If max iterations reached, report partial success with warnings

## Re-Review Loop (Task/contextd)

When any veto or consensus < 100%:

1. Collect all findings
2. Create remediation tasks
3. Fix issues
4. Re-run full review
5. Continue until 100% consensus

## Review Output Format

Each reviewer should output:
```markdown
## Review: {agent_name}

### Verdict: APPROVE | REQUEST_CHANGES | VETO

### Consensus Contribution: {APPROVE = 1, else = 0}

### Findings

#### Critical
- {finding with specific location}

#### High
- {finding with specific location}

#### Medium
- {finding}

#### Low
- {suggestion}

### Summary
{1-2 sentence summary}
```

## Aggregation

Orchestrator aggregates reviews:
```markdown
## Consensus Summary

### Score: {X}% ({approvals}/{total})

### Verdicts
| Reviewer | Verdict | Critical | High | Medium | Low |
|----------|---------|----------|------|--------|-----|

### Blocking Issues
- [{severity}] [{reviewer}] {issue}

### Decision: PASS | RE-SYNTHESIZE | RE-REVIEW | ESCALATE
```

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Skip review for "simple" changes | Quality degradation | Always review |
| Ignore LOW findings | Technical debt | Track and address |
| Infinite re-synthesis loop | Stuck orchestration | Max 3 iterations |
| Override vetoes | Security/quality risk | Vetoes are absolute |
