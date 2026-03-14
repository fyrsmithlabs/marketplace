---
name: consensus-review
description: Multi-agent consensus code review with adaptive budgets, complexity-aware agent selection, multiple consensus protocols (Approval/Veto, AAD, CI, Supermajority), cross-agent coverage tracking, context-folding isolation, and progressive summarization. Use when reviewing PRs, directories, or code changes.
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

## Adaptive Budget Allocation

See `includes/consensus-review/budget.md` for base budget details.

Budget scales based on BOTH scope size AND complexity tier (from the complexity-assessment skill):

### Base Formula (unchanged)

```
scale = min(4.0, 1.0 + total_tokens / 16384)
per_agent_budget = base_budget[agent] * scale
```

### Complexity Multiplier

After calculating the scope-based budget, apply a complexity multiplier from the complexity-assessment tier:

```
complexity_multiplier = {
  "SIMPLE": 0.75,    # Reduce budget for simple reviews
  "STANDARD": 1.0,   # Standard budget
  "COMPLEX": 1.5     # Increase budget for complex reviews
}

adjusted_budget = per_agent_budget * complexity_multiplier[tier]
```

### Example Calculations with Complexity Tiers

| Scope Size | Tokens | Scale | Tier | Multiplier | Security Budget |
|------------|--------|-------|------|------------|-----------------|
| Small (5 files) | ~4K | 1.25 | SIMPLE | 0.75 | 7,680 |
| Small (5 files) | ~4K | 1.25 | STANDARD | 1.0 | 10,240 |
| Small (5 files) | ~4K | 1.25 | COMPLEX | 1.5 | 15,360 |
| Medium (15 files) | ~16K | 2.0 | SIMPLE | 0.75 | 12,288 |
| Medium (15 files) | ~16K | 2.0 | STANDARD | 1.0 | 16,384 |
| Medium (15 files) | ~16K | 2.0 | COMPLEX | 1.5 | 24,576 |
| Large (50+ files) | ~48K | 4.0 | SIMPLE | 0.75 | 24,576 |
| Large (50+ files) | ~48K | 4.0 | STANDARD | 1.0 | 32,768 |
| Large (50+ files) | ~48K | 4.0 | COMPLEX | 1.5 | 49,152 |

When complexity tier is not available (e.g., standalone review without prior assessment), default to STANDARD (1.0x).

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

## Adaptive Agent Selection

Before dispatching all reviewers, classify the review scope using the complexity tier to determine which agents are needed:

### Triage Matrix

| Complexity | Agents Dispatched |
|------------|-------------------|
| SIMPLE | code-quality-reviewer only |
| STANDARD | code-quality-reviewer + language-specific (e.g., go-reviewer) + security-reviewer |
| COMPLEX | All 6 reviewers |

### Override Rules

Regardless of complexity tier, force-include agents when the diff matches these patterns:

- If diff touches auth/crypto/secrets → always include `security-reviewer`
- If diff includes Go files → always include `go-reviewer`
- If diff modifies public API → always include `user-persona-reviewer`
- If diff changes docs/README → always include `documentation-reviewer`
- If diff adds/updates dependencies → always include `vulnerability-reviewer`

### Triage Workflow

```
1. Determine complexity tier (from complexity-assessment or default STANDARD)
2. Select base agent set from triage matrix
3. Scan diff for override patterns
4. Merge override agents into base set (deduplicate)
5. Dispatch final agent set with calculated budgets
```

This reduces cost and latency for SIMPLE reviews while maintaining full coverage for COMPLEX changes.

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
complexity_multiplier = {"SIMPLE": 0.75, "STANDARD": 1.0, "COMPLEX": 1.5}
tier = complexity_assessment.tier or "STANDARD"  # Default if not available

for agent in selected_agents:
    agent.budget = base_budgets[agent] * scale * complexity_multiplier[tier]
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

## Consensus Protocols

The default protocol is Approval/Veto. Additional protocols can be selected based on review type to improve accuracy and reduce convergence on suboptimal conclusions.

### Protocol Selection Matrix

| Review Type | Protocol | Rationale |
|-------------|----------|-----------|
| Code review (default) | Approval/Veto | Security needs hard stops |
| Research synthesis | Supermajority (66%) | Knowledge tasks benefit from consensus |
| Architecture review | All-Agents Drafting (AAD) | Prevents early convergence on suboptimal design |
| Iterative improvement | Collective Improvement (CI) | Allows agents to refine findings collaboratively |

### Approval/Veto (Default)

The existing protocol. Each agent independently reviews and can veto. Synthesis agent merges findings. Best for code reviews where security vetoes are critical.

### All-Agents Drafting (AAD)

Each agent independently generates findings before seeing other agents' outputs. No cross-agent communication during the initial review phase. The synthesis agent merges all findings after all agents complete.

```
1. Dispatch all agents in parallel (no shared context)
2. Collect all agent outputs
3. Synthesis agent merges findings (no agent sees others' work)
4. Final report generated from merged findings
```

Research basis: ACL 2025 shows +3.3% accuracy improvement over sequential protocols by preventing anchoring bias.

### Collective Improvement (CI)

After initial findings, agents exchange findings (not rationale). Each agent can update their findings based on others' discoveries. Maximum 2 rounds of exchange.

```
Round 1: All agents generate independent findings
Exchange: Findings (not rationale) shared across agents
Round 2: Agents update their findings based on others' discoveries
Synthesis: Final merge of updated findings
```

**Important:** Research shows more than 2 rounds decrease performance due to groupthink convergence. Do NOT exceed 2 rounds.

Research basis: ACL 2025 shows +7.4% accuracy improvement. Best for iterative reviews where agents can build on each other's discoveries.

### Supermajority

Findings require 66% agent agreement to be included in the final report. Vetoes still apply regardless of protocol (security vetoes are never overridden by majority).

```
1. Collect all agent findings
2. Group findings by file + issue
3. Include in report only if >= 66% of reviewing agents flagged it
4. Exception: CRITICAL/HIGH security findings always included (veto applies)
```

Used for knowledge-heavy reviews where binary pass/fail is too coarse.

### Protocol Override via Command

```
/consensus-review <scope> --protocol aad    # All-Agents Drafting
/consensus-review <scope> --protocol ci     # Collective Improvement
/consensus-review <scope> --protocol vote   # Supermajority
/consensus-review <scope>                   # Default: Approval/Veto
```

## Cross-Agent Coverage Tracking

Track file coverage across ALL agents to identify gaps, not just per-agent coverage:

### Coverage Matrix

```
| File         | Security | Vuln | Quality | Go  | Docs | Persona |
|--------------|----------|------|---------|-----|------|---------|
| handler.go   | Y        | Y    | Y       | Y   | -    | -       |
| worker.go    | SKIP     | Y    | Y       | Y   | -    | -       |
| README.md    | -        | -    | -       | -   | Y    | Y       |
| auth.go      | Y        | Y    | Y       | Y   | -    | Y       |
```

Legend:
- `Y` = File reviewed by this agent
- `SKIP` = File in scope but skipped (budget/partial)
- `-` = File not in this agent's review domain

### Gap Detection

After collecting all agent outputs, check for coverage gaps:

1. If a file is skipped by an agent but covered by others:
   → Note: "worker.go has quality coverage but lacks security coverage"
   → Suggest targeted follow-up: `/consensus-review worker.go --agents security`

2. If a file has NO agent coverage at all:
   → Flag as UNCOVERED in the report header
   → Require manual review or re-run with expanded budget

3. If a security-sensitive file lacks security-reviewer coverage:
   → Escalate: "auth.go was not reviewed by security-reviewer (budget limit)"
   → Block merge until security coverage is obtained

### Coverage in Report Output

Include coverage matrix in the report footer:

```
Coverage: 11/12 files fully covered
Gap: worker.go lacks security coverage (skipped due to budget)
→ Suggested: /consensus-review worker.go --agents security
```

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
- `complexity-assessment` skill - Provides tier, recommended_agents, and intent gating
- `/discover` - Broader codebase analysis
- `effective-go` skill - Go-specific guidance
