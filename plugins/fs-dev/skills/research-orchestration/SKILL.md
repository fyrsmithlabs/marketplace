---
name: research:orchestration
description: Multi-agent research orchestration for gathering technical, architectural, UX, security, and competitive insights. Use before brainstorm, during planning, or for troubleshooting.
triggers:
  - /research
  - research orchestration
  - gather research
  - before brainstorm research
---

# Research Orchestration

Execute parallel research agents to gather comprehensive insights on a topic, then synthesize into actionable reports.

## Shared Orchestration Patterns

This skill builds on shared orchestration patterns. See:
- `includes/orchestration/parallel-execution.md` - Agent dispatch and concurrency
- `includes/orchestration/result-synthesis.md` - Collecting and merging results
- `includes/orchestration/context-management.md` - Context folding and memory
- `includes/orchestration/checkpoint-patterns.md` - Save/resume workflows

The patterns below are **research-specific** extensions.

## Research-Specific Workflow

### Phase 1: Topic Analysis
1. Parse user query for research scope
2. Determine which agents to dispatch:
   - Always: technical, architectural
   - If UI/UX involved: ux
   - If security implications: security
   - If strategic/market question: competitive

### Phase 2: Parallel Research
Dispatch selected agents with:
- Topic context
- Current year requirement (2026)
- Confidence scoring requirement
- Citation requirement

### Phase 3: Synthesis
After all agents complete:
1. Launch research:synthesis agent
2. Cross-validate findings
3. Generate consolidated report
4. Write to docs/.claude/research/{topic}/

## Agent Selection Matrix

| Query Contains | Agents to Dispatch |
|----------------|-------------------|
| "how to implement" | technical, architectural |
| "best practice" | technical, security |
| "UI", "UX", "user" | technical, ux |
| "secure", "auth" | technical, security |
| "compare", "vs" | technical, competitive |
| "market", "trend" | competitive |
| Default | technical, architectural |

## Output Structure

```
docs/.claude/research/{topic-slug}/
├── README.md          # Executive summary
├── technical.md       # Technical findings
├── architectural.md   # Architecture analysis
├── ux.md             # UX considerations (if applicable)
├── security.md       # Security analysis (if applicable)
├── competitive.md    # Market context (if applicable)
└── sources.md        # All citations
```

## Critical Requirements

### Year Validation
ALL web searches MUST include current year:
```
WebSearch(query: "{topic} best practices 2026")
```

### Confidence Scoring
Every finding must include:
- **HIGH**: Multiple 2025-2026 sources agree
- **MEDIUM**: Some sources, needs verification
- **LOW**: Single source or older

### Citations
Every finding must cite:
- Source URL
- Access date
- Relevance to query

## Integration Points

### Before Brainstorm
```
/brainstorm "add feature X"
  -> Automatically triggers /research "feature X" first
  -> Brainstorm receives research context
```

### During Troubleshooting
```
Error encountered
  -> /research:debug "error message"
  -> Technical + architectural agents analyze
```

## Command Variants

| Command | Agents | Use Case |
|---------|--------|----------|
| `/research "topic"` | Auto-selected | General research |
| `/research:quick "topic"` | technical only | Fast answer |
| `/research --agents tech,security "topic"` | Specified | Targeted |
| `/research:debug "error"` | tech, arch | Troubleshooting |

## Consensus Review (Required)

After synthesis completes, run consensus review:

### Review Agents
- `documentation-reviewer` - Technical accuracy, completeness
- `code-quality-reviewer` - Code example correctness (if applicable)

### Pass Criteria
| Requirement | Threshold |
|-------------|-----------|
| Consensus Score | >= 70% |
| Critical Findings | 0 |
| High Findings | 0 |

### Re-Synthesis Loop

If consensus < 70% OR critical/high findings exist:

1. Collect reviewer feedback
2. Re-run synthesis agent with feedback
3. Re-run consensus review
4. Maximum 3 iterations
5. Report partial success if max reached

See `includes/orchestration/consensus-review.md` for detailed patterns.

## Anti-Patterns

- Searching without current year -> outdated results
- Skipping synthesis -> disconnected findings
- Not checking codebase -> recommendations don't fit
- Single source confidence HIGH -> inaccurate scoring
- Skipping consensus review -> quality not validated
