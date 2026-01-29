---
name: research
description: Run multi-agent research orchestration on a topic
usage: /research [options] "topic"
arguments:
  - name: topic
    description: The topic to research
    required: true
options:
  - name: --agents
    description: Comma-separated list of agents (technical,architectural,ux,security,competitive)
    default: auto
  - name: --quick
    description: Quick mode - technical agent only
    type: boolean
  - name: --debug
    description: Debug mode - technical + architectural for troubleshooting
    type: boolean
  - name: --output
    description: Output directory (default: docs/.claude/research/{topic})
    type: string
---

# /research Command

Run comprehensive research on a topic using specialized agents.

## Usage

```bash
# Full research (auto-select agents)
/research "implementing OAuth 2.1 with PKCE"

# Quick research (technical only)
/research --quick "React 19 new features"
/research:quick "React 19 new features"

# Specific agents
/research --agents technical,security "API authentication patterns"

# Debug mode (troubleshooting)
/research --debug "CORS preflight failures"
/research:debug "CORS preflight failures"

# Custom output location
/research --output ./research "GraphQL federation"
```

## What Happens

1. **Query Analysis** - Determines which agents to dispatch based on topic keywords
2. **Parallel Research** - Selected agents search and analyze simultaneously
3. **Synthesis** - Results consolidated into unified report
4. **Output** - Report written to `docs/.claude/research/{topic}/`

## Agent Selection

| Flag | Agents Used |
|------|-------------|
| (none) | Auto-selected based on topic |
| `--quick` | technical only |
| `--debug` | technical, architectural |
| `--agents X,Y` | Specified agents |

### Auto-Selection Logic

| Topic Contains | Agents Dispatched |
|----------------|-------------------|
| "how to", "implement" | technical, architectural |
| "best practice" | technical, security |
| "UI", "UX", "user" | technical, ux |
| "secure", "auth" | technical, security |
| "compare", "vs" | technical, competitive |
| "market", "trend" | competitive |
| Default | technical, architectural |

## Output

After completion, find your research at:

```
docs/.claude/research/{topic-slug}/
├── README.md          # Start here - executive summary
├── technical.md       # Technical findings
├── architectural.md   # Architecture analysis
├── ux.md             # UX considerations (if applicable)
├── security.md       # Security analysis (if applicable)
├── competitive.md    # Market context (if applicable)
└── sources.md        # All citations
```

## Examples

### Before Feature Development
```bash
/research "dark mode implementation patterns"
/brainstorm "add dark mode to our app"
```

### Comparing Technologies
```bash
/research "GraphQL vs REST API 2026 comparison"
```

### Security Review
```bash
/research --agents technical,security "JWT token storage best practices"
```

### Troubleshooting
```bash
/research:debug "webpack module federation errors"
```

### Quick Lookup
```bash
/research:quick "Go context cancellation patterns"
```

## Contextd Integration

If contextd MCP is available:

**Pre-flight:**
- `memory_search` for past research on similar topics
- `semantic_search` for relevant codebase context

**Post-flight:**
- `memory_record` with research summary
- Research findings indexed for future sessions

If contextd is NOT available:
- Research runs without memory integration
- Results still written to docs/

## Critical Notes

- All searches include current year (2026) automatically
- Results include confidence scores (HIGH/MEDIUM/LOW)
- All findings are cited with source URLs
- Research is saved for future reference
- Partial results returned if some agents fail

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Agent timeout | Retry once, proceed without if retry fails |
| All agents fail | Report failure, no partial output |
| No findings | Explicit message, suggest refined query |

## Related Commands

- `/brainstorm` - Design features (can use research as input)
- `/discover` - Analyze existing codebase
- `/plan` - Full planning workflow
