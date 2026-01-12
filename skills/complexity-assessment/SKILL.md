---
name: complexity-assessment
description: Assess task complexity using 5 dimensions to right-size workflow depth. Returns SIMPLE, STANDARD, or COMPLEX tier.
---

# Complexity Assessment

Evaluate task complexity before planning to ensure appropriate workflow depth and artifact structure.

## When to Use

This skill is called by `/brainstorm` Phase 2 to determine:
- Question depth (SIMPLE: 3-5, STANDARD: 8-12, COMPLEX: 15+)
- GitHub artifact structure (single issue vs epic + sub-issues vs project board)
- Worktree recommendation

## 5 Dimensions

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

## Tier Calculation

Sum scores across all 5 dimensions:

| Total Score | Tier | Characteristics |
|-------------|------|-----------------|
| 5-8 | SIMPLE | Quick change, minimal planning needed |
| 9-12 | STANDARD | Moderate complexity, structured approach |
| 13-15 | COMPLEX | High complexity, extensive planning required |

## Output

Store assessment in contextd:

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Complexity assessment: <task-summary>",
  content: "Tier: <tier>. Scope: <score>/<rationale>. Integration: <score>/<rationale>.
            Infrastructure: <score>/<rationale>. Knowledge: <score>/<rationale>.
            Risk: <score>/<rationale>. Total: <sum>/15.",
  outcome: "success",
  tags: ["complexity-assessment", "<tier>"]
)
```

## Tier Implications

### SIMPLE (5-8)
- **Questions:** 3-5 quick clarifications
- **GitHub:** Single Issue with checklist
- **Worktree:** Optional, can work in main
- **Review:** Standard consensus review

### STANDARD (9-12)
- **Questions:** 8-12 detailed questions
- **GitHub:** Epic Issue + sub-Issues
- **Worktree:** Recommended for isolation
- **Review:** Full consensus review

### COMPLEX (13-15)
- **Questions:** 15+ comprehensive questions
- **GitHub:** Epic + sub-Issues + Project board
- **Worktree:** Required for isolation
- **Review:** Full consensus + additional scrutiny

## Example Assessment

**Task:** "Add user authentication with OAuth2"

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Scope | 2 | Auth routes, middleware, user model, frontend components |
| Integration | 2 | OAuth provider API integration |
| Infrastructure | 2 | Environment variables, session config |
| Knowledge | 2 | OAuth2 flow, security best practices |
| Risk | 3 | Security-critical, user data |

**Total:** 11/15 = **STANDARD**

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

1. Apply 5-dimension analysis to user's task description
2. Calculate tier based on total score
3. Record assessment in contextd

mcp__contextd__branch_return(
  branch_id: "<branch>",
  message: "Tier: <tier> (Score: <total>/15). Key factors: <top 2 dimensions>"
)
```

---

## Mandatory Checklist

**EVERY assessment MUST complete ALL steps:**

- [ ] Analyze Scope dimension with score and rationale
- [ ] Analyze Integration dimension with score and rationale
- [ ] Analyze Infrastructure dimension with score and rationale
- [ ] Analyze Knowledge dimension with score and rationale
- [ ] Analyze Risk dimension with score and rationale
- [ ] Calculate total score (sum of 5 dimensions)
- [ ] Determine tier from score
- [ ] **RECORD to contextd** (see Output section)
- [ ] Return tier with score and key factors

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
| "I can skip dimensions for simple tasks" | ALL 5 dimensions. Every time. |
| "The user already knows the complexity" | Document for future sessions. Record it. |

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Inflating simple tasks | Typo fix = SIMPLE. Don't over-engineer. |
| Deflating complex tasks | Payment/security = COMPLEX. Don't underestimate. |
| Gut-feel tier assignment | Show your math. 5 dimensions, explicit scores. |
| Skipping contextd | Recording enables future efficiency. Always record. |
| Ignoring high-risk dimensions | Risk=3 deserves attention regardless of total. |

---

## Attribution

Adapted from Auto-Claude `complexity_assessor.md` by AndyMik90 (MIT).
See CREDITS.md for full attribution.
