---
name: complexity-assessment
description: Use when assessing task complexity, determining workflow depth, asking "how complex is this?", "should I use a worktree?", "is this a big change?", or sizing work before planning. Analyzes 7 dimensions (scope, integration, infrastructure, knowledge, risk, testing, decomposability) to return SIMPLE, STANDARD, or COMPLEX tier with confidence scoring.
---

# Complexity Assessment

Evaluate task complexity before planning to ensure appropriate workflow depth and artifact structure.

## Contextd Integration

If contextd MCP is available:
- `memory_search` to find similar past assessments
- `memory_record` for tier recommendations with rationale
- `memory_outcome` to track assessment accuracy over time
- `branch_create/return` for isolated assessment

If contextd is NOT available:
- Assessment runs inline (still works)
- No persistence of tier decisions
- No historical comparison available

## When to Use

This skill is called by `/brainstorm` Phase 2 to determine:
- Question depth (SIMPLE: 3-5, STANDARD: 8-12, COMPLEX: 15+)
- GitHub artifact structure (single issue vs epic + sub-issues vs project board)
- Worktree recommendation
- Context branch budget allocation

---

## 7 Dimensions

Assess each dimension and aggregate to determine tier:

### 1. Scope
**Question:** How many files will be touched?

| Files | Score | Indicator |
|-------|-------|-----------|
| 1-2 | 1 | Single component, localized change |
| 3-10 | 2 | Multiple components, cross-cutting |
| 10+ | 3 | System-wide, architectural change |

### 2. Integration
**Question:** What external dependencies are involved?

| Dependencies | Score | Indicator |
|--------------|-------|-----------|
| None | 1 | Self-contained, no external calls |
| 1-2 APIs/services | 2 | Moderate integration work |
| 3+ APIs/services | 3 | Complex orchestration required |

### 3. Infrastructure
**Question:** Are config/infra changes required?

| Changes | Score | Indicator |
|---------|-------|-----------|
| None | 1 | Code-only change |
| Config files | 2 | Environment variables, feature flags |
| New infra | 3 | Database, Docker, cloud resources |

### 4. Knowledge
**Question:** What domain expertise is required?

| Expertise | Score | Indicator |
|-----------|-------|-----------|
| Familiar patterns | 1 | Standard CRUD, common patterns |
| Some research | 2 | New library, unfamiliar domain |
| Deep expertise | 3 | Security, performance, compliance |

### 5. Risk
**Question:** What's the blast radius if something goes wrong?

| Risk | Score | Indicator |
|------|-------|-----------|
| Low | 1 | Easily reversible, non-critical path |
| Medium | 2 | User-facing, requires testing |
| High | 3 | Data integrity, security, payments |

### 6. Testing (New)
**Question:** What testing effort is required?

| Testing | Score | Indicator |
|---------|-------|-----------|
| Minimal | 1 | Unit tests only, existing patterns |
| Moderate | 2 | Integration tests, new test fixtures |
| Extensive | 3 | E2E tests, performance tests, security audits |

### 7. Decomposability (New)
**Question:** Can this task be split into independent units?

| Decomposability | Score | Indicator |
|-----------------|-------|-----------|
| Easily decomposable | 1 | Clear subtasks, no shared state |
| Partially decomposable | 2 | Some dependencies between subtasks |
| Monolithic | 3 | Tightly coupled, must be done together |

---

## Risk Multipliers

Apply these multipliers to the base score when present:

| Factor | Multiplier | When to Apply |
|--------|------------|---------------|
| Security-sensitive | 1.2x | Auth, encryption, user data, API keys |
| Data migration | 1.3x | Schema changes, data transformations |
| Breaking changes | 1.2x | API changes, deprecated features |
| Technical debt | 1.1x | Working in legacy/poorly-tested code |
| Time pressure | 1.1x | Urgent deadline, reduced review time |

**Calculation:** `adjusted_score = base_score * highest_applicable_multiplier`

---

## Confidence Scoring

Every assessment includes a confidence percentage (0-100%):

| Confidence | Range | Criteria |
|------------|-------|----------|
| High | 80-100% | Clear requirements, familiar domain, similar past tasks |
| Medium | 50-79% | Some ambiguity, partial familiarity |
| Low | 0-49% | Unclear scope, unfamiliar domain, novel problem |

**When confidence < 60%:** Use `AskUserQuestion` to clarify ambiguous dimensions before finalizing tier.

**Confidence factors:**
- Requirements clarity (+/- 20%)
- Domain familiarity (+/- 15%)
- Historical data available (+/- 15%)
- Codebase familiarity (+/- 10%)

---

## Team Velocity Factors

Adjust expectations based on team context:

| Factor | Impact | Consideration |
|--------|--------|---------------|
| Team size | +/- 1 tier | Solo dev may need COMPLEX timeline adjustment |
| Experience level | +/- 1 dimension score | Junior devs add +1 to Knowledge dimension |
| Codebase familiarity | +/- 1 dimension score | New team members add +1 to Scope |
| Concurrent priorities | +/- 1 tier | High WIP may require elevated treatment |

---

## Tier Calculation

Sum scores across all 7 dimensions (max 21):

| Total Score | Tier | Characteristics |
|-------------|------|-----------------|
| 7-11 | SIMPLE | Quick change, minimal planning needed |
| 12-16 | STANDARD | Moderate complexity, structured approach |
| 17-21 | COMPLEX | High complexity, extensive planning required |

**After multipliers:** Round to nearest integer before tier assignment.

---

## Structured Output

Return assessment as JSON for downstream consumption:

```json
{
  "tier": "STANDARD",
  "confidence": 75,
  "confidence_justification": "Clear scope but unfamiliar OAuth library",
  "base_score": 14,
  "adjusted_score": 16.8,
  "multipliers_applied": ["security-sensitive"],
  "dimensions": {
    "scope": { "score": 2, "rationale": "Auth routes, middleware, user model, frontend" },
    "integration": { "score": 2, "rationale": "OAuth provider API" },
    "infrastructure": { "score": 2, "rationale": "Environment variables, session config" },
    "knowledge": { "score": 2, "rationale": "OAuth2 flow, security best practices" },
    "risk": { "score": 3, "rationale": "Security-critical, user data" },
    "testing": { "score": 2, "rationale": "Integration tests for OAuth flow" },
    "decomposability": { "score": 1, "rationale": "Backend/frontend can be parallelized" }
  },
  "decomposition_suggestions": null,
  "historical_comparison": "Similar OAuth task took 3 iterations (Issue #45)",
  "team_velocity_adjustments": null,
  "integration_hints": {
    "github_artifact": "epic_with_sub_issues",
    "context_branch_budget": 8192,
    "worktree_recommended": true
  }
}
```

---

## Tier Implications

### SIMPLE (7-11)
- **Questions:** 3-5 quick clarifications
- **GitHub:** Single Issue with checklist
- **Worktree:** Optional, can work in main
- **Review:** Standard consensus review
- **Context branch budget:** 4096 tokens
- **Testing:** Unit tests, 70%+ coverage on new code

### STANDARD (12-16)
- **Questions:** 8-12 detailed questions
- **GitHub:** Epic Issue + sub-Issues
- **Worktree:** Recommended for isolation
- **Review:** Full consensus review
- **Context branch budget:** 8192 tokens
- **Testing:** Unit + integration tests, 80%+ coverage

### COMPLEX (17-21)
- **Questions:** 15+ comprehensive questions
- **GitHub:** Epic + sub-Issues + Project board
- **Worktree:** Required for isolation
- **Review:** Full consensus + additional scrutiny
- **Context branch budget:** 16384 tokens
- **Testing:** Unit + integration + E2E, 90%+ coverage, security audit

---

## Integration with Other Skills

### github-planning Integration
Tier determines GitHub artifact structure:

| Tier | Artifact Type | Details |
|------|---------------|---------|
| SIMPLE | Single Issue | Checklist in body, no sub-issues |
| STANDARD | Epic + Sub-Issues | Parent issue links children |
| COMPLEX | Epic + Sub-Issues + Project | Board with columns, milestones |

### context-folding Integration
Tier determines branch budget:

| Tier | Token Budget | Max Depth |
|------|--------------|-----------|
| SIMPLE | 4096 | 1 level |
| STANDARD | 8192 | 2 levels |
| COMPLEX | 16384 | 3 levels |

---

## Decomposition Suggestions

For COMPLEX tasks (score 17+), provide decomposition suggestions:

```json
{
  "decomposition_suggestions": [
    {
      "subtask": "Backend OAuth integration",
      "estimated_tier": "STANDARD",
      "dependencies": [],
      "can_parallelize": true
    },
    {
      "subtask": "Frontend auth UI components",
      "estimated_tier": "SIMPLE",
      "dependencies": [],
      "can_parallelize": true
    },
    {
      "subtask": "Session management middleware",
      "estimated_tier": "SIMPLE",
      "dependencies": ["Backend OAuth integration"],
      "can_parallelize": false
    }
  ],
  "parallelization_potential": "2 of 3 subtasks can run in parallel",
  "recommended_approach": "Split into 3 issues, assign backend and frontend in parallel"
}
```

---

## Ambiguity Handling

When confidence < 60%, use `AskUserQuestion` to clarify:

```
AskUserQuestion(
  question: "I'm uncertain about the complexity of this task. To provide an accurate assessment, I need clarification on:",
  options: [
    "What external services/APIs will this integrate with?",
    "Are there existing tests I should reference for patterns?",
    "What's the expected timeline pressure?",
    "Are there schema/database changes involved?"
  ],
  allow_custom: true
)
```

**After clarification:** Re-score affected dimensions and recalculate tier.

---

## Historical Comparison

When contextd is available, search for similar past assessments:

```
# Search for similar tasks
mcp__contextd__memory_search(
  project_id: "<project>",
  query: "<task description keywords>",
  tags: ["complexity-assessment"]
)
```

Include in output:
- Similar past tasks and their actual outcomes
- Iteration count (how many rounds to complete)
- Assessment accuracy (predicted vs actual complexity)

**Example output:**
```
Historical comparison: "Similar OAuth task (Issue #45) was assessed as STANDARD,
took 3 iterations to complete. Assessment was accurate."
```

---

## Contextd Recording

Store assessment in contextd with full rationale:

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Complexity assessment: <task-summary>",
  content: JSON.stringify({
    tier: "<tier>",
    confidence: <0-100>,
    base_score: <sum>,
    adjusted_score: <after multipliers>,
    dimensions: { <all 7 with scores and rationale> },
    multipliers: [<applied multipliers>],
    decomposition: <suggestions if COMPLEX>,
    integration_hints: { <github, context-folding settings> }
  }),
  outcome: "success",
  tags: ["complexity-assessment", "<tier>", "confidence-<high|medium|low>"]
)
```

---

## Example Assessment

**Task:** "Add user authentication with OAuth2"

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Scope | 2 | Auth routes, middleware, user model, frontend components |
| Integration | 2 | OAuth provider API integration |
| Infrastructure | 2 | Environment variables, session config |
| Knowledge | 2 | OAuth2 flow, security best practices |
| Risk | 3 | Security-critical, user data |
| Testing | 2 | Integration tests for OAuth flow needed |
| Decomposability | 1 | Backend/frontend can be parallelized |

**Base Score:** 14/21
**Multiplier:** 1.2x (security-sensitive)
**Adjusted Score:** 16.8 -> 17 = **COMPLEX** (borderline)
**Confidence:** 75% (clear scope, unfamiliar library)

**JSON Output:**
```json
{
  "tier": "COMPLEX",
  "confidence": 75,
  "confidence_justification": "Clear scope but unfamiliar OAuth library",
  "base_score": 14,
  "adjusted_score": 17,
  "multipliers_applied": ["security-sensitive"],
  "dimensions": {
    "scope": { "score": 2, "rationale": "Auth routes, middleware, user model, frontend" },
    "integration": { "score": 2, "rationale": "OAuth provider API" },
    "infrastructure": { "score": 2, "rationale": "Environment variables, session config" },
    "knowledge": { "score": 2, "rationale": "OAuth2 flow, security best practices" },
    "risk": { "score": 3, "rationale": "Security-critical, user data" },
    "testing": { "score": 2, "rationale": "Integration tests for OAuth flow" },
    "decomposability": { "score": 1, "rationale": "Backend/frontend can be parallelized" }
  },
  "decomposition_suggestions": [
    { "subtask": "Backend OAuth routes", "estimated_tier": "STANDARD", "can_parallelize": true },
    { "subtask": "Frontend auth UI", "estimated_tier": "SIMPLE", "can_parallelize": true }
  ],
  "historical_comparison": "Similar OAuth task took 3 iterations (Issue #45)",
  "integration_hints": {
    "github_artifact": "epic_with_sub_issues_and_project",
    "context_branch_budget": 16384,
    "worktree_recommended": true
  }
}
```

---

## Integration

This skill is designed to be called by other commands/skills:

```markdown
# In /brainstorm command Phase 2:

## Phase 2: Complexity Assessment (Context Folded)

mcp__contextd__branch_create(
  session_id: "<session>",
  description: "Assess task complexity",
  budget: 4096
)

1. Search contextd for similar past assessments
2. Apply 7-dimension analysis to user's task description
3. Calculate confidence score
4. Apply risk multipliers if applicable
5. Calculate tier based on adjusted score
6. Generate decomposition suggestions if COMPLEX
7. Record assessment in contextd with full JSON

mcp__contextd__branch_return(
  branch_id: "<branch>",
  message: JSON.stringify({
    tier: "<tier>",
    confidence: <0-100>,
    score: "<adjusted>/<max>",
    key_factors: ["<top 2 dimensions>"],
    decomposition: <if COMPLEX>,
    integration_hints: { github_artifact, context_branch_budget, worktree_recommended }
  })
)
```

---

## Mandatory Checklist

**EVERY assessment MUST complete ALL steps:**

- [ ] Search contextd for similar past assessments (if available)
- [ ] Analyze Scope dimension with score and rationale
- [ ] Analyze Integration dimension with score and rationale
- [ ] Analyze Infrastructure dimension with score and rationale
- [ ] Analyze Knowledge dimension with score and rationale
- [ ] Analyze Risk dimension with score and rationale
- [ ] Analyze Testing dimension with score and rationale
- [ ] Analyze Decomposability dimension with score and rationale
- [ ] Calculate base score (sum of 7 dimensions)
- [ ] Apply risk multipliers if applicable
- [ ] Calculate confidence score with justification
- [ ] Determine tier from adjusted score
- [ ] Generate decomposition suggestions if COMPLEX
- [ ] Include integration hints (github-planning, context-folding)
- [ ] **RECORD to contextd** with full JSON (see Recording section)
- [ ] Return structured JSON output

**The assessment is NOT complete until contextd recording is done.**

---

## Red Flags - STOP and Reconsider

If you're thinking any of these, you're about to violate the skill:

| Thought | Reality |
|---------|---------|
| "This is obviously simple, no need to score" | Score anyway. Intuition misses edge cases. |
| "I'll just say STANDARD to be safe" | Calculate the actual score. Don't guess. |
| "Recording to contextd is optional" | Recording is MANDATORY. No exceptions. |
| "Risk doesn't matter for this task" | Risk ALWAYS matters. Score it. |
| "I can skip dimensions for simple tasks" | ALL 7 dimensions. Every time. |
| "The user already knows the complexity" | Document for future sessions. Record it. |
| "Confidence scoring is extra work" | Confidence enables better decisions. Calculate it. |
| "Decomposition is only for COMPLEX" | Consider it for STANDARD too if helpful. |
| "Historical comparison is optional" | Past data improves accuracy. Search for it. |

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Inflating simple tasks | Typo fix = SIMPLE. Don't over-engineer. |
| Deflating complex tasks | Payment/security = COMPLEX. Don't underestimate. |
| Gut-feel tier assignment | Show your math. 7 dimensions, explicit scores. |
| Skipping contextd | Recording enables future efficiency. Always record. |
| Ignoring high-risk dimensions | Risk=3 deserves attention regardless of total. |
| Not applying multipliers | Security/migrations/breaking changes need multipliers. |
| Low confidence without clarification | Use AskUserQuestion when confidence < 60%. |
| Missing decomposition for COMPLEX | Always suggest how to break down COMPLEX tasks. |
| Returning text instead of JSON | Downstream tools expect structured output. |

---

## Tracking Assessment Accuracy

After task completion, update the original assessment:

```
mcp__contextd__memory_outcome(
  memory_id: "<original assessment id>",
  outcome: "success|partial|failure",
  notes: "Predicted STANDARD, actual was COMPLEX due to unexpected API rate limits"
)
```

**Track metrics over time:**
- Tier prediction accuracy
- Iteration count vs predicted
- Common underestimation patterns
- Team velocity calibration

---

## Attribution

Adapted from Auto-Claude `complexity_assessor.md` by AndyMik90 (MIT).
Enhanced with testing dimension, confidence scoring, decomposability analysis, and structured output.
See CREDITS.md for full attribution.
