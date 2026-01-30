# Result Synthesis

Patterns for collecting, validating, and consolidating agent outputs into coherent results.

## Overview

Synthesis transforms multiple agent outputs into a unified, actionable result. The goal is to combine perspectives while preserving attribution and handling conflicts.

## Synthesis Pipeline

```
+-------------+    +---------------+    +----------------+    +-------------+
|  Collect    | -> |   Validate    | -> |  Cross-Check   | -> |  Consolidate|
|  Outputs    |    |   Structure   |    |   Conflicts    |    |   Results   |
+-------------+    +---------------+    +----------------+    +-------------+
```

## Collection Phase

### Gathering Outputs

```markdown
## Collection Protocol

1. Wait for all agents to complete (blocking TaskOutput)
2. Extract output from each agent
3. Preserve agent identity for attribution
4. Log collection timestamp
```

### Expected Structure

Each agent output should contain these sections:

| Section | Required | Purpose |
|---------|----------|---------|
| Findings | Yes | Discovered items with evidence |
| Recommendations | Yes | Actionable next steps |
| Confidence | Yes | Certainty level |
| Sources | No | References examined |
| Caveats | No | Limitations or assumptions |

### Parsing Example

```markdown
## Parsed Agent Outputs

### Agent: security-reviewer
- Findings: 3
- Recommendations: 2
- Confidence: HIGH

### Agent: performance-reviewer
- Findings: 1
- Recommendations: 1
- Confidence: MEDIUM

### Agent: documentation-reviewer
- Findings: 2
- Recommendations: 3
- Confidence: HIGH
```

## Validation Phase

### Structure Validation

Check each output has required sections:

```markdown
## Validation Results

| Agent | Has Findings | Has Recommendations | Has Confidence | Valid |
|-------|--------------|---------------------|----------------|-------|
| security | Yes | Yes | Yes | Pass |
| performance | Yes | Yes | No | Fail* |
| documentation | Yes | Yes | Yes | Pass |

*Note: Missing confidence - defaulting to MEDIUM
```

### Content Validation

- Findings have supporting evidence
- Recommendations are actionable
- Confidence is justified

## Cross-Validation Phase

### Detecting Conflicts

Agents may produce conflicting findings:

```markdown
## Conflict Detection

### Conflict 1: File complexity
- Agent A (performance): "auth.go is too complex, needs refactoring"
- Agent B (security): "auth.go complexity is necessary for security"
- Resolution: FLAG for human review

### Conflict 2: API exposure
- Agent A (security): "Hide internal endpoint"
- Agent B (documentation): "Document internal endpoint"
- Resolution: Security takes precedence - hide endpoint
```

### Conflict Resolution Strategies

| Strategy | When to Use |
|----------|-------------|
| Security precedence | Security vs convenience conflicts |
| Evidence weight | Both have evidence, weigh quality |
| Flag for review | Cannot determine programmatically |
| Merge perspectives | Complementary, not contradictory |

### Weighting by Expertise

```markdown
## Agent Weights

| Agent | Domain | Base Weight | Source Quality | Final Weight |
|-------|--------|-------------|----------------|--------------|
| security | security | 1.0 | HIGH | 1.0 |
| security | performance | 0.3 | - | 0.3 |
| performance | performance | 1.0 | MEDIUM | 0.8 |
| documentation | documentation | 1.0 | HIGH | 1.0 |
```

## Consolidation Phase

### Merge Complementary Findings

Combine findings that address different aspects:

```markdown
## Before Consolidation

- Security: "auth.go lacks input validation on line 42"
- Performance: "auth.go has O(n^2) loop on line 87"
- Documentation: "auth.go missing function docstrings"

## After Consolidation

### auth.go Issues
1. **Security** (line 42): Lacks input validation [HIGH]
2. **Performance** (line 87): O(n^2) loop [MEDIUM]
3. **Documentation**: Missing function docstrings [LOW]
```

### Deduplication

Remove duplicate findings:

```markdown
## Deduplication

- Agent A: "Missing error handling in process()"
- Agent B: "process() doesn't handle errors"
-> Merged: "Missing error handling in process()" (attributed to both)
```

### Preserve Attribution

Always track which agent produced each finding:

```markdown
## Finding Attribution

| Finding | Source Agents | Confidence |
|---------|---------------|------------|
| SQL injection risk | security | HIGH |
| Missing docs | documentation | HIGH |
| Slow query | performance, security | MEDIUM |
```

## Output Format

### Standard Synthesis Output

```markdown
## Synthesis Results

### Summary
- Total findings: N
- Critical: X, High: Y, Medium: Z, Low: W
- Agents reporting: [list]

### Findings by Category

#### Security (N findings)
1. [Finding] - [Evidence] - [Source Agent]
2. ...

#### Performance (N findings)
1. [Finding] - [Evidence] - [Source Agent]
2. ...

#### Documentation (N findings)
1. [Finding] - [Evidence] - [Source Agent]
2. ...

### Recommendations (Priority Order)
1. [Recommendation] - [Rationale] - [Source]
2. ...

### Conflicts Requiring Review
- [Conflict description with both perspectives]

### Coverage
- Files analyzed: [list]
- Agents completed: X/Y
- Failed agents: [list with reasons]
```

## Synthesis Checklist

- [ ] All agent outputs collected
- [ ] Structure validated (required sections present)
- [ ] Conflicts identified and resolved/flagged
- [ ] Duplicates merged with attribution
- [ ] Findings organized by category
- [ ] Recommendations prioritized
- [ ] Failed agents noted
- [ ] Attribution preserved throughout

## Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| Lose attribution | Can't trace findings to source | Preserve agent ID on all items |
| Ignore conflicts | Contradictory output confuses | Detect and resolve/flag |
| Duplicate findings | Inflates issue count | Merge with multiple attribution |
| Flat list | Hard to prioritize | Organize by severity/category |
| Hide failures | Incomplete picture | Report failed agents explicitly |
