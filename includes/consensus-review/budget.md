# Budget Calculation for Consensus Review

Adaptive budget allocation based on indexed token counts from contextd.

## Base Budgets by Agent Type

| Agent | Base Budget | Rationale |
|-------|-------------|-----------|
| `security-reviewer` | 8,192 | Deep analysis of injection, auth, secrets |
| `vulnerability-reviewer` | 8,192 | CVE lookup, dependency scanning |
| `go-reviewer` | 8,192 | Effective Go patterns, concurrency analysis |
| `code-quality-reviewer` | 6,144 | Logic, complexity, patterns |
| `documentation-reviewer` | 4,096 | README, API docs, CHANGELOG |
| `user-persona-reviewer` | 4,096 | UX, breaking changes, ergonomics |

## Scale Factor Formula

```
scale = 1.0 + (total_tokens / 16384)
scale = min(scale, 4.0)  // Cap at 4x base budget

per_agent_budget = base_budget * scale
```

### Why 16,384?

- Represents ~2x minimum agent budget
- Triggers scaling before agents hit limits
- Allows gradual increase rather than sudden jumps

### Why Cap at 4.0?

- Maximum budget of 32K for largest agents (security/vulnerability/go)
- Prevents runaway allocation on massive scopes
- Beyond 4x, consider splitting the review scope

## Example Calculations

### Small Scope (5 files, ~4K tokens)

```
total_tokens = 4,096
scale = 1.0 + (4096 / 16384) = 1.25

security-reviewer:    8,192 * 1.25 = 10,240 tokens
vulnerability-reviewer: 8,192 * 1.25 = 10,240 tokens
go-reviewer:          8,192 * 1.25 = 10,240 tokens
code-quality-reviewer: 6,144 * 1.25 = 7,680 tokens
documentation-reviewer: 4,096 * 1.25 = 5,120 tokens
user-persona-reviewer: 4,096 * 1.25 = 5,120 tokens
```

### Medium Scope (15 files, ~16K tokens)

```
total_tokens = 16,384
scale = 1.0 + (16384 / 16384) = 2.0

security-reviewer:    8,192 * 2.0 = 16,384 tokens
vulnerability-reviewer: 8,192 * 2.0 = 16,384 tokens
go-reviewer:          8,192 * 2.0 = 16,384 tokens
code-quality-reviewer: 6,144 * 2.0 = 12,288 tokens
documentation-reviewer: 4,096 * 2.0 = 8,192 tokens
user-persona-reviewer: 4,096 * 2.0 = 8,192 tokens
```

### Large Scope (50+ files, ~48K tokens)

```
total_tokens = 49,152
scale = 1.0 + (49152 / 16384) = 4.0 (capped)

security-reviewer:    8,192 * 4.0 = 32,768 tokens
vulnerability-reviewer: 8,192 * 4.0 = 32,768 tokens
go-reviewer:          8,192 * 4.0 = 32,768 tokens
code-quality-reviewer: 6,144 * 4.0 = 24,576 tokens
documentation-reviewer: 4,096 * 4.0 = 16,384 tokens
user-persona-reviewer: 4,096 * 4.0 = 16,384 tokens
```

## Isolation Mode Threshold

| Total Tokens | Mode | Behavior |
|--------------|------|----------|
| ≤16,384 | **Shared** | Agents run in parent context with budget tracking |
| >16,384 | **Branch** | Each agent gets isolated contextd branch |

### Why 16K for Isolation?

- Below 16K: Agents can share context efficiently
- Above 16K: Risk of context pollution, isolation prevents cross-agent interference
- Uses `branch_create`/`branch_return` for clean separation

## Integration with Indexing

Budget calculation requires token counts from contextd indexing:

```
1. Index changed files:
   repository_index(path, include_patterns: changed_files)

2. Get token counts:
   total_tokens = sum(file.token_count for file in indexed_files)

3. Calculate scale:
   scale = min(4.0, 1.0 + total_tokens / 16384)

4. Apply to each agent:
   budget[agent] = base_budget[agent] * scale
```

## Usage in Agent Prompts

Reference this include in agent prompts:

```
BUDGET: You have been allocated {{budget}} tokens for this review.
See includes/consensus-review/progressive.md for degradation protocol.
```
