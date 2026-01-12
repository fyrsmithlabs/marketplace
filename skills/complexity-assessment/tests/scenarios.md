# Complexity Assessment Test Scenarios

Pressure tests to ensure correct behavior.

## Scenario 1: simple-task-inflation

**Setup:** User asks to "fix a typo in the README"

**Wrong Behavior:**
- Assign STANDARD or COMPLEX tier
- Ask 10+ questions
- Create epic with sub-issues

**Correct Behavior:**
- Score: Scope=1, Integration=1, Infrastructure=1, Knowledge=1, Risk=1 = 5
- Tier: SIMPLE
- 3-5 quick questions max
- Single issue with checklist

**Teaching:** Don't inflate simple tasks. A typo fix is a typo fix.

---

## Scenario 2: complex-task-deflation

**Setup:** User asks to "add payment processing with Stripe"

**Wrong Behavior:**
- Assign SIMPLE tier because "it's just an API integration"
- Skip detailed questions
- Create single issue

**Correct Behavior:**
- Score: Scope=2, Integration=3, Infrastructure=2, Knowledge=3, Risk=3 = 13
- Tier: COMPLEX
- 15+ comprehensive questions
- Epic + sub-issues + project board
- Worktree required

**Teaching:** Payment systems are inherently high-risk. Never downgrade complexity for financial integrations.

---

## Scenario 3: skip-dimension-analysis

**Setup:** User asks to "add dark mode toggle"

**Wrong Behavior:**
- Guess tier without analyzing all 5 dimensions
- Skip rationale for scores

**Correct Behavior:**
1. Analyze each dimension explicitly:
   - Scope: 2 (CSS, theme context, multiple components)
   - Integration: 1 (no external APIs)
   - Infrastructure: 1 (maybe localStorage for preference)
   - Knowledge: 1 (standard React/CSS patterns)
   - Risk: 1 (cosmetic, easily reversible)
2. Total: 6 = SIMPLE
3. Record full rationale in contextd

**Teaching:** Always show your work. Dimension-by-dimension analysis prevents gut-feel errors.

---

## Scenario 4: missing-contextd-record

**Setup:** Assessment completed, tier determined

**Wrong Behavior:**
- Return tier without recording to contextd
- Skip tags or use generic tags

**Correct Behavior:**
```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Complexity assessment: dark mode toggle",
  content: "Tier: SIMPLE. Scope: 2/multiple components. Integration: 1/no APIs.
            Infrastructure: 1/localStorage only. Knowledge: 1/standard patterns.
            Risk: 1/cosmetic change. Total: 6/15.",
  outcome: "success",
  tags: ["complexity-assessment", "SIMPLE"]
)
```

**Teaching:** Every assessment must be recorded. Future sessions need this context.

---

## Scenario 5: boundary-score-bias

**Setup:** Task scores exactly 8 (boundary between SIMPLE and STANDARD)

**Wrong Behavior:**
- Arbitrarily choose STANDARD "to be safe"
- Ignore that 8 is within SIMPLE range

**Correct Behavior:**
- 8 = SIMPLE (range is 5-8)
- Apply SIMPLE workflow
- If unsure, re-examine dimension scores for accuracy

**Teaching:** Respect tier boundaries. Don't round up complexity unnecessarily - that's YAGNI violation.

---

## Scenario 6: risk-dimension-override

**Setup:** Task scores 7 overall but Risk=3 (security-critical)

**Wrong Behavior:**
- Apply SIMPLE workflow because total is 7
- Skip security considerations

**Correct Behavior:**
- Flag high-risk dimension in output
- Consider upgrading workflow depth for high-risk tasks
- At minimum, note: "SIMPLE tier but high-risk dimension - recommend additional security review"

**Teaching:** Risk=3 always deserves attention regardless of total score.
