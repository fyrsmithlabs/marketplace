---
name: comp-analysis
description: Use when reviewing competitor analysis results, getting a quick market overview, or summarizing competitive landscape from previous app-interview sessions. Generates executive summary directly to terminal. Say "summarize competitors", "show competitive analysis", or "what did we learn about the market?".
arguments:
  - name: source
    description: "Path to competition.json or interview directory (optional - searches .claude/interviews/ if not provided)"
    required: false
---

# /comp-analysis

Generate a token-efficient executive summary of competitor analysis, output directly to the terminal session.

## Execution

**Agent:** `contextd:contextd-task-executor`
**Context Folding:** Yes - minimize token usage
**Output:** Terminal only (no files written)

## Workflow

### Phase 1: Source Location

```
IF source argument provided:
  Read {{source}}
ELSE:
  1. Search for competition.json files:
     - .claude/interviews/*/competition.json
     - docs/.claude/interviews/*/competition.json

  2. If multiple found, ask user:
     AskUserQuestion(
       questions: [{
         question: "Multiple competitor analyses found. Which one?",
         header: "Select Analysis",
         options: [dynamically generated from found files],
         multiSelect: false
       }]
     )

  3. If none found:
     → Suggest running /app-interview first
     → Exit gracefully
```

### Phase 2: Context-Folded Analysis

```
mcp__contextd__branch_create(
  session_id: "<session>",
  description: "Generate executive summary",
  budget: 4096,  # Minimal budget for token efficiency
  timeout_seconds: 120
)
```

Parse competition.json and extract:
- Top 3 competitors by relevance
- Top 5 pain points by severity + frequency
- Top 3 differentiation opportunities by user value
- Key market gaps

```
mcp__contextd__branch_return(
  branch_id: "<branch>",
  message: "[Structured summary data only]"
)
```

### Phase 3: Terminal Output

**Format: Executive Summary (Token-Efficient)**

```markdown
## Competitor Analysis: <App Name>

### Top Competitors
| Competitor | Relevance | Key Weakness |
|------------|-----------|--------------|
| <name>     | High      | <pain point> |
| <name>     | High      | <pain point> |
| <name>     | Medium    | <pain point> |

### Critical Pain Points (User Complaints)
1. **<Issue>** - <severity> severity, <frequency> mentions
   Source: <where found>
   → Opportunity: <how to solve>

2. **<Issue>** - <severity> severity, <frequency> mentions
   Source: <where found>
   → Opportunity: <how to solve>

3. **<Issue>** - <severity> severity, <frequency> mentions
   Source: <where found>
   → Opportunity: <how to solve>

### Differentiation Opportunities
| Opportunity | Complexity | Value | Competitors Missing |
|-------------|------------|-------|---------------------|
| <desc>      | Low        | High  | A, B, C             |
| <desc>      | Medium     | High  | A, B                |
| <desc>      | Low        | Med   | B, C                |

### Market Gaps
- <Gap 1>: <evidence summary>
- <Gap 2>: <evidence summary>

### Recommended Focus
**Primary:** <top differentiation opportunity>
**Secondary:** <second opportunity>
**Avoid:** <competitor strengths to not compete on>

---
*Analysis from: <source file>*
*Research date: <date>*
*Run `/app-interview` to update or deepen analysis*
```

### Token Efficiency Rules

1. **No file writes** - Terminal output only
2. **Truncate descriptions** - Max 50 chars per cell
3. **Top N only** - Never list all, only top 3-5
4. **No raw JSON** - Always formatted markdown
5. **Single summary** - No pagination or sections
6. **Branch budget: 4096** - Force concise synthesis

### Phase 4: Memory Recording (Minimal)

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Comp analysis summary viewed",
  content: "Top competitor: <name>. Top opportunity: <desc>.",
  outcome: "success",
  tags: ["comp-analysis", "summary"]
)
```

## Error Handling

**No competition.json found:**
```
No competitor analysis found.

Run `/app-interview` to conduct competitor research first.
This will generate competition.json with:
- Competitor profiles
- User pain points
- Differentiation opportunities
```

**Invalid JSON:**
```
Error parsing competition.json at <path>

The file may be corrupted or incomplete.
Run `/app-interview` to regenerate.
```

**Empty/minimal data:**
```
Competitor analysis has limited data.

Found: <N> competitors, <M> pain points

Consider running `/app-interview` again for deeper research.
```

## Integration with Other Commands

| Command | Relationship |
|---------|--------------|
| `/app-interview` | Generates the competition.json this command reads |
| `/spec-refinement` | Can use insights from this summary |
| `/onboard` | May suggest running this for new projects |

## Example Output

```markdown
## Competitor Analysis: TaskFlow

### Top Competitors
| Competitor | Relevance | Key Weakness           |
|------------|-----------|------------------------|
| Todoist    | High      | No team collaboration  |
| Asana      | High      | Overwhelming complexity|
| TickTick   | Medium    | Poor integrations      |

### Critical Pain Points (User Complaints)
1. **Sync issues** - High severity, common mentions
   Source: Reddit r/productivity, App Store reviews
   → Opportunity: Real-time sync with conflict resolution

2. **Feature bloat** - High severity, common mentions
   Source: Twitter, G2 reviews
   → Opportunity: Minimal, focused feature set

3. **No offline mode** - Medium severity, occasional mentions
   Source: App Store reviews
   → Opportunity: Offline-first architecture

### Differentiation Opportunities
| Opportunity         | Complexity | Value | Competitors Missing |
|---------------------|------------|-------|---------------------|
| AI task suggestions | Medium     | High  | Todoist, TickTick   |
| True offline-first  | Low        | High  | Asana, Todoist      |
| Dev-focused integr. | Low        | Med   | All                 |

### Market Gaps
- Developer-specific workflows: No competitor targets devs
- CLI-first interface: All competitors are GUI-only

### Recommended Focus
**Primary:** Developer-focused task management with CLI
**Secondary:** True offline-first with smart sync
**Avoid:** Enterprise features (Asana's strength)

---
*Analysis from: .claude/interviews/taskflow-2026-01-08/competition.json*
*Research date: 2026-01-08*
*Run `/app-interview` to update or deepen analysis*
```
