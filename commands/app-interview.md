---
name: app-interview
description: Conduct comprehensive app interview - reads existing specs, performs competitor analysis, and helps flesh out the app idea with differentiation strategies
arguments:
  - name: reuse
    description: "Reuse previous interview context from contextd (optional)"
    required: false
---

# /app-interview

Comprehensive app ideation interview that reads existing specs, conducts competitor analysis, and helps developers flesh out their app idea with differentiation strategies.

## Execution

**Agent:** `contextd:contextd-task-executor`
**Context Folding:** Yes - isolate competitor research and interview phases
**Output:** Interview artifacts in `.claude/interviews/<generated-title>/`

## Workflow

### Phase 1: Context Gathering (Pre-Flight)

```
1. mcp__contextd__memory_search(
     project_id: "<project>",
     query: "app interview competitor analysis"
   )
   → Load past interview insights

2. Glob for existing specs:
   - docs/**/*.spec.md
   - docs/**/spec*.md
   - **/*.spec.md
   - **/SPEC.md
   - **/spec.md

3. Read all found specs to understand current app vision

4. If --reuse flag:
   mcp__contextd__checkpoint_resume(
     checkpoint_id: "<previous-interview>",
     level: "context"
   )
```

### Phase 2: Initial App Understanding

Use AskUserQuestion to establish baseline:

```
AskUserQuestion(
  questions: [{
    question: "What problem does your app solve in one sentence?",
    header: "Core Problem",
    options: [
      { label: "Productivity/Efficiency", description: "Helps users do things faster/better" },
      { label: "Communication/Collaboration", description: "Helps people work together" },
      { label: "Entertainment/Content", description: "Provides enjoyment or content" },
      { label: "Information/Discovery", description: "Helps users find or learn things" }
    ],
    multiSelect: false
  },
  {
    question: "Who is your primary target user?",
    header: "Target User",
    options: [
      { label: "Developers/Technical", description: "Software engineers, DevOps, etc." },
      { label: "Business/Enterprise", description: "Teams, managers, enterprises" },
      { label: "Consumers", description: "General public, individuals" },
      { label: "Creators", description: "Artists, writers, content creators" }
    ],
    multiSelect: false
  }]
)
```

### Phase 3: Competitor Analysis (Context Folded)

```
mcp__contextd__branch_create(
  session_id: "<session>",
  description: "Competitor research and analysis",
  budget: 16384,
  timeout_seconds: 600
)
```

**Research Methodology:**

1. **Competitor Identification**
   - WebSearch: "[app type] alternatives 2025"
   - WebSearch: "[problem domain] apps comparison"
   - Identify 3-5 main competitors

2. **User Feedback Research**
   - App store reviews and ratings
   - Reddit/community discussions
   - GitHub issues (if applicable)
   - Twitter/social sentiment

3. **Pain Point Documentation**
   For each competitor, extract:
   - Common complaints (with sources)
   - Missing features users want
   - UX problems mentioned
   - Performance/reliability issues
   - Pricing concerns

4. **Gap Analysis**
   - Patterns across competitors
   - Underserved segments
   - Differentiation opportunities

**Output:** Write to `.claude/interviews/<title>/competition.json`

```json
{
  "project": {
    "name": "<app-name>",
    "type": "<app-type>",
    "target_audience": "<audience>"
  },
  "competitors": [
    {
      "id": "comp_001",
      "name": "<competitor>",
      "url": "<url>",
      "relevance": "high|medium|low",
      "strengths": ["..."],
      "pain_points": [
        {
          "id": "pain_001",
          "description": "<issue>",
          "source": "<where found>",
          "severity": "high|medium|low",
          "frequency": "common|occasional|rare",
          "opportunity": "<how your app can solve this>"
        }
      ],
      "market_position": "<description>"
    }
  ],
  "market_gaps": [
    {
      "gap": "<description>",
      "evidence": ["<sources>"],
      "opportunity_score": 1-10
    }
  ],
  "differentiation_opportunities": [
    {
      "opportunity": "<description>",
      "competitors_lacking": ["<names>"],
      "implementation_complexity": "low|medium|high",
      "user_value": "high|medium|low"
    }
  ],
  "metadata": {
    "research_date": "<timestamp>",
    "sources_consulted": ["<list>"],
    "limitations": ["<any gaps in research>"]
  }
}
```

Return branch:
```
mcp__contextd__branch_return(
  branch_id: "<branch>",
  message: "Found [N] competitors, [M] pain points, [K] differentiation opportunities"
)
```

### Phase 4: Differentiation Interview

With competitor context loaded, interview user about differentiation:

**Question Areas:**
- Which competitor pain points resonate most with your vision?
- What unique angle can you bring that competitors miss?
- What tradeoffs are you willing to make for differentiation?
- Which market gaps align with your capabilities?
- What's your unfair advantage (tech, domain expertise, distribution)?

**Interview until sufficient context:**
- User has identified 2-3 clear differentiation strategies
- Key technical approach is defined
- Target user segment is refined
- MVP scope is understood

Offer completion:
```
AskUserQuestion(
  questions: [{
    question: "We've covered competitors and differentiation. How would you like to proceed?",
    header: "Interview Status",
    options: [
      { label: "Generate differentiation strategy", description: "Summarize findings and strategy" },
      { label: "Deep dive on specific competitor", description: "Analyze one competitor more thoroughly" },
      { label: "Explore more differentiation angles", description: "Continue brainstorming unique approaches" },
      { label: "End and save context", description: "Save progress for later /comp-analysis" }
    ],
    multiSelect: false
  }]
)
```

### Phase 5: Output Generation

Write artifacts to `.claude/interviews/<generated-title>/`:

```
.claude/interviews/<app-name>-<date>/
├── competition.json         # Structured competitor data
├── differentiation.md       # Strategy document
├── interview-notes.md       # Raw interview context
└── next-steps.md           # Recommended actions
```

### Phase 6: Memory Recording

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "App interview: <app-name> differentiation",
  content: "Competitors: [list]. Key differentiators: [list].
            Market gaps: [list]. Strategy: [summary].",
  outcome: "success",
  tags: ["app-interview", "competitor-analysis", "differentiation"]
)

mcp__contextd__checkpoint_save(
  session_id: "<session>",
  project_path: ".",
  name: "app-interview-<app-name>",
  description: "App interview with competitor analysis",
  summary: "[competitor count] analyzed, [differentiation count] opportunities",
  context: "[key findings]",
  full_state: "[complete interview context]",
  token_count: <current>,
  threshold: 0.0,
  auto_created: false
)
```

## Generated Title Logic

Title generated from:
1. App name (if provided)
2. Core problem domain
3. Date stamp

Format: `<app-name|domain>-<YYYY-MM-DD>`

Example: `task-manager-2026-01-08`

## Reuse Flag

When `--reuse` is passed:
1. Search for previous interview checkpoints
2. Present list to user for selection
3. Load selected checkpoint context
4. Continue from where previous interview ended
