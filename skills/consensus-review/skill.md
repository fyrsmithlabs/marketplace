---
name: consensus-review
description: Multi-agent consensus code review with adaptive budgets, context-folding isolation, and progressive summarization. Use when reviewing PRs, directories, or code changes with 5-6 parallel reviewer agents.
---

# Consensus Review Skill

Multi-agent code review that dispatches specialized reviewers in parallel with adaptive budget allocation and graceful degradation.

## When to Use

- Reviewing pull requests before merge
- Auditing security-sensitive code
- Evaluating architectural decisions
- Code quality assessment with multiple perspectives

## When NOT to Use

- Single-file typo fixes (overkill)
- Simple refactoring with no behavioral changes
- Quick feedback needed (use single reviewer)

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    /consensus-review <scope>                        │
├─────────────────────────────────────────────────────────────────────┤
│  Phase 1: Parallel Initialization                                   │
│  ┌──────────────────────┐  ┌──────────────────────┐                │
│  │   Scope Detection    │  │   File Indexing      │                │
│  │   - Resolve files    │  │   - Index to contextd│                │
│  │   - Detect languages │  │   - Get token counts │                │
│  │   - Select agents    │  │   - Branch metadata  │                │
│  └──────────┬───────────┘  └──────────┬───────────┘                │
│             └──────────────┬──────────┘                            │
│                            ▼                                        │
│  Phase 2: Budget Calculation                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  total_tokens = sum(indexed_file_tokens)                    │   │
│  │  isolation_mode = total_tokens > 16K ? "branch" : "shared"  │   │
│  │  per_agent_budget = calculate_budget(total_tokens, agent)   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                            ▼                                        │
│  Phase 3: Agent Dispatch (parallel, with budgets)                  │
│  Phase 4: Synthesis (handles partial results)                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Reviewer Agents

| Agent | Focus | Base Budget | Veto |
|-------|-------|-------------|------|
| `security-reviewer` | Injection, auth, secrets, OWASP | 8,192 | Yes |
| `vulnerability-reviewer` | CVEs, deps, supply chain | 8,192 | Yes |
| `go-reviewer` | Effective Go, concurrency | 8,192 | Yes |
| `code-quality-reviewer` | Logic, tests, complexity | 6,144 | Yes |
| `documentation-reviewer` | README, API docs, CHANGELOG | 4,096 | Yes |
| `user-persona-reviewer` | UX, breaking changes, ergonomics | 4,096 | No |

## Budget Calculation

See `includes/consensus-review/budget.md` for full details.

```
scale = min(4.0, 1.0 + total_tokens / 16384)
per_agent_budget = base_budget[agent] * scale
```

### Example Calculations

| Scope Size | Total Tokens | Scale | Security Budget |
|------------|--------------|-------|-----------------|
| Small (5 files) | ~4K | 1.25 | 10,240 |
| Medium (15 files) | ~16K | 2.0 | 16,384 |
| Large (50+ files) | ~48K | 4.0 (cap) | 32,768 |

## Isolation Modes

| Total Tokens | Mode | Behavior |
|--------------|------|----------|
| ≤16,384 | **Shared** | Agents run in parent context with budget tracking |
| >16,384 | **Branch** | Each agent gets isolated contextd branch |

### Branch Isolation (Large Scopes)

```
For each agent:
  branch_create(
    description: "{agent} review of {scope}",
    budget: calculated_budget
  )
  → Agent executes in isolated context
  → branch_return(findings_json)
```

## Progressive Summarization

See `includes/consensus-review/progressive.md` for full protocol.

Agents adapt their analysis based on budget consumption:

| Budget Used | Mode | Behavior |
|-------------|------|----------|
| 0-80% | Full Analysis | All severities, detailed evidence |
| 80-95% | High Severity Only | CRITICAL/HIGH, concise evidence |
| 95%+ | Force Return | Stop immediately, `partial: true` |

### Partial Output Schema

```json
{
  "agent": "security-reviewer",
  "partial": true,
  "cutoff_reason": "budget",
  "files_reviewed": 8,
  "files_skipped": 4,
  "skipped_files": ["worker.go", "cache.go", ...],
  "findings": [...],
  "recommendation": "Re-run: /consensus-review worker.go cache.go"
}
```

## Workflow Steps

### 1. Parallel Initialization

Run concurrently:
- **Scope Detection**: Resolve files, detect languages, select agents
- **File Indexing**: Index to contextd with branch metadata, get token counts

### 2. Budget Calculation

```python
total_tokens = sum(file.token_count for file in indexed_files)
scale = min(4.0, 1.0 + total_tokens / 16384)

for agent in selected_agents:
    agent.budget = base_budgets[agent] * scale
```

### 3. Isolation Decision

```python
if total_tokens > 16384:
    mode = "branch"  # Use contextd branch_create/branch_return
else:
    mode = "shared"  # Run in parent context
```

### 4. Agent Dispatch

```
Task(
  subagent_type: "fs-dev:{agent}",
  prompt: |
    Review {scope}.
    Budget: {calculated_budget} tokens.
    See includes/consensus-review/progressive.md for degradation protocol.
  run_in_background: true
)
```

### 5. Collect & Synthesize

```python
results = []
partial_agents = []

for agent in agents:
    output = TaskOutput(agent.task_id)
    results.append(output)

    if output.partial:
        partial_agents.append({
            "agent": output.agent,
            "files_reviewed": output.files_reviewed,
            "files_skipped": output.files_skipped
        })

# Calculate coverage per agent
# De-duplicate findings
# Check veto status
# Generate report
```

### 6. Handle Partial Results

When agents return partial results:

1. Flag in report header: `⚠️ Partial results: {agent} hit budget limit`
2. Show coverage percentage: `67% ⚠️` in table
3. List skipped files
4. Suggest follow-up: `→ Consider: /consensus-review {skipped_files}`

## contextd Integration

### File Indexing

```
repository_index(
  path: project_path,
  include_patterns: changed_files,
  branch: current_branch  # Auto-detected
)
```

### Branch Isolation

```
branch_create(
  session_id: "review-{scope}-{timestamp}",
  description: "Security review of {scope}",
  budget: 16384
)

# ... agent executes ...

branch_return(
  message: "Security review complete: 2 CRITICAL, 1 HIGH"
)
```

### Memory Recording

```
memory_record(
  title: "Consensus Review: {scope}",
  content: "{summary}",
  tags: ["consensus-review", "{verdict}"]
)
```

## Output Examples

### With Partial Results

```
═══ Consensus Review: src/auth/ ═══

Verdict: BLOCKED (2 vetoes)
⚠️  Partial results: security-reviewer hit budget limit (8/12 files)

┌────────────────┬─────────┬────┬────┬────┬────┬──────────┐
│ Agent          │ Verdict │ C  │ H  │ M  │ L  │ Coverage │
├────────────────┼─────────┼────┼────┼────┼────┼──────────┤
│ Security       │ VETO    │ 1  │ 0  │ 2  │ 0  │ 67% ⚠️   │
│ Vulnerability  │ OK      │ 0  │ 0  │ 1  │ 0  │ 100%     │
│ Code Quality   │ OK      │ 0  │ 1  │ 1  │ 0  │ 100%     │
└────────────────┴─────────┴────┴────┴────┴────┴──────────┘

Files not reviewed by security-reviewer: worker.go, cache.go
→ Consider: /consensus-review src/auth/worker.go src/auth/cache.go
```

### Full Coverage

```
═══ Consensus Review: src/api/ ═══

Verdict: APPROVED

┌────────────────┬─────────┬────┬────┬────┬────┬──────────┐
│ Agent          │ Verdict │ C  │ H  │ M  │ L  │ Coverage │
├────────────────┼─────────┼────┼────┼────┼────┼──────────┤
│ Security       │ OK      │ 0  │ 0  │ 1  │ 2  │ 100%     │
│ Vulnerability  │ OK      │ 0  │ 0  │ 0  │ 1  │ 100%     │
│ Code Quality   │ OK      │ 0  │ 0  │ 2  │ 3  │ 100%     │
└────────────────┴─────────┴────┴────┴────┴────┴──────────┘

Medium (3): ...
Low (6): ...
```

## Troubleshooting

### Agents Hitting Budget Limits

**Symptoms**: Multiple agents returning `partial: true`

**Solutions**:
1. Split scope into smaller chunks
2. Increase base budgets in agent definitions
3. Use `--agents` flag to run subset of agents
4. Review in multiple passes

### contextd Not Available

**Fallback behavior**:
- Skip file indexing step
- Use fixed budgets (no scaling)
- Run in shared mode only
- Store results to `.claude/consensus-reviews/`

### Branch Isolation Failures

**Symptoms**: `branch_create` errors

**Solutions**:
1. Check contextd MCP server is running
2. Verify session_id is unique
3. Check project_path is valid git repo

## Related

- `includes/consensus-review/budget.md` - Budget calculation formula
- `includes/consensus-review/progressive.md` - Degradation protocol
- `/discover` - Broader codebase analysis
- `effective-go` skill - Go-specific guidance
