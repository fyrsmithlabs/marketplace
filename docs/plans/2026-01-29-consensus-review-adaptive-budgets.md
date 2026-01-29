# Consensus Review: Adaptive Budgets & Context Management

**Status**: Approved
**Date**: 2026-01-29
**Author**: Claude + dahendel

## Problem Statement

Parallel agents in consensus reviews hit context limits on large scopes. All 6 agents receive fixed 4-8KB budgets regardless of scope size, causing:
- Incomplete analysis on large PRs
- "Context limit reached" errors
- Lost review coverage

## Solution: Hybrid Adaptive System

Three capabilities to prevent context exhaustion:
1. **Adaptive budgets** - Scale agent budgets based on indexed token counts
2. **Context-folding** - Branch isolation for large scopes (>16K tokens)
3. **Progressive summarization** - Graceful degradation as budget depletes

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

## Design Decisions

### 1. File Indexing Strategy

**Decision**: Index changed files to contextd in parallel with scope detection.

- Uses existing `repository_index` with file filter
- Branch auto-detected via go-git, stored as metadata
- Returns token counts for budget calculation
- Enables semantic search instead of raw file reads

### 2. Budget Calculation

**Decision**: Token-aware budgets from indexing results.

```
base_budgets = {
    "security-reviewer":       8192,
    "vulnerability-reviewer":  8192,
    "go-reviewer":            8192,
    "code-quality-reviewer":  6144,
    "documentation-reviewer": 4096,
    "user-persona-reviewer":  4096
}

scale = 1.0 + (total_tokens / 16384)  # +1x per 16K tokens
scale = min(scale, 4.0)               # Cap at 4x

per_agent_budget = base_budget[agent] * scale
```

### 3. Isolation Mode

**Decision**: Hybrid - branch isolation only for large scopes.

| Total Tokens | Mode | Behavior |
|--------------|------|----------|
| ≤16K | Shared | Agents run in parent context with budget tracking |
| >16K | Branch | Each agent gets isolated contextd branch |

### 4. Progressive Summarization

**Decision**: Agents self-monitor and degrade gracefully.

| Budget Usage | Behavior |
|--------------|----------|
| 0-80% | Full analysis (all severities, detailed evidence) |
| 80-95% | High severity only (CRITICAL/HIGH, concise) |
| 95%+ | Force return with `partial: true` |

### 5. Partial Result Handling

**Decision**: Synthesis handles incomplete outputs gracefully.

- Flag partial results in report
- Show coverage percentage per agent
- Suggest targeted follow-up reviews for skipped files
- Reduce confidence weight for partial findings

## Agent Output Schema

```json
{
  "agent": "security-reviewer",
  "partial": false,
  "cutoff_reason": null,
  "files_reviewed": 12,
  "files_skipped": 0,
  "findings": [...],
  "verdict": "VETO" | "WARN" | "OK",
  "veto_reasons": [...]
}
```

## Implementation Phases

### Phase 1: Budget Infrastructure
- Create `includes/consensus-review/budget.md`
- Create `includes/consensus-review/progressive.md`
- Define budget calculation formula

### Phase 2: Agent Updates
- Add budget awareness prompts to all 6 reviewer agents
- Add progressive summarization protocol
- Add partial output schema

### Phase 3: Command Enhancement
- Update `commands/consensus-review.md`
- Add parallel indexing step
- Add isolation mode decision
- Add partial result synthesis

### Phase 4: Skill Creation
- Create `skills/consensus-review/SKILL.md`
- Full workflow documentation

### Phase 5: Testing
- Test small scope (shared mode)
- Test large scope (branch mode)
- Test partial result handling

## Files to Create/Modify

| File | Action |
|------|--------|
| `commands/consensus-review.md` | Modify |
| `skills/consensus-review/SKILL.md` | Create |
| `agents/security-reviewer.md` | Modify |
| `agents/vulnerability-reviewer.md` | Modify |
| `agents/code-quality-reviewer.md` | Modify |
| `agents/documentation-reviewer.md` | Modify |
| `agents/user-persona-reviewer.md` | Modify |
| `agents/go-reviewer.md` | Modify |
| `includes/consensus-review/budget.md` | Create |
| `includes/consensus-review/progressive.md` | Create |

## Contextd Integration

- `repository_index` - Index changed files with branch metadata
- `semantic_search` - Agents query instead of reading raw files
- `branch_create/branch_return` - Isolation for large scopes

## Success Criteria

1. No context exhaustion on reviews up to 50 files
2. Partial results clearly flagged with actionable follow-up
3. Budget scaling responds correctly to scope size
4. Branch isolation activates automatically for large scopes
