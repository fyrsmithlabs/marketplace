# /plan Command Test Scenarios

## Scenario 1: full-workflow-orchestration

**Setup:** User runs `/plan "add user authentication"`

**Wrong Behavior:**
- Skip complexity assessment
- Skip brainstorming
- Jump directly to GitHub Issues

**Correct Behavior:**
- Phase 1: Pre-flight (memory_search)
- Phase 2: Complexity assessment (context folded)
- Phase 3: Branch by tier to appropriate flow
- Phase 4/5: Brainstorm OR spec extraction
- Phase 6: GitHub planning
- Phase 7: Memory recording

**Teaching:** /plan orchestrates the FULL workflow. Don't skip phases.

---

## Scenario 2: tier-branching-simple

**Setup:** Complexity assessment returns SIMPLE (score 7)

**Wrong Behavior:**
- Run full brainstorm with 15 questions
- Create Epic + sub-Issues
- Require worktree

**Correct Behavior:**
- Quick planning flow
- 3-5 clarifying questions
- Single Issue with checklist
- Worktree optional

**Teaching:** SIMPLE tier = streamlined workflow. Don't over-engineer.

---

## Scenario 3: tier-branching-standard

**Setup:** Complexity assessment returns STANDARD (score 11)

**Wrong Behavior:**
- Use SIMPLE flow (single issue)
- Use COMPLEX flow (Project board)
- Skip brainstorming

**Correct Behavior:**
- Standard planning flow
- 8-12 questions in brainstorm
- Epic + sub-Issues
- Worktree recommended

**Teaching:** STANDARD tier = structured approach with Epic hierarchy.

---

## Scenario 4: tier-branching-complex

**Setup:** Complexity assessment returns COMPLEX (score 14)

**Wrong Behavior:**
- Use STANDARD flow (no Project board)
- Skip extended brainstorming
- Make worktree optional

**Correct Behavior:**
- Extended planning flow
- 15+ comprehensive questions
- Epic + sub-Issues + Project board
- Worktree required

**Teaching:** COMPLEX tier = maximum structure. Project board is mandatory.

---

## Scenario 5: skip-brainstorm-flag

**Setup:** User runs `/plan "implement auth per spec" --skip-brainstorm`

**Wrong Behavior:**
- Run full brainstorm anyway
- Ignore existing spec
- Ask 15 interview questions

**Correct Behavior:**
- Ask for spec source via AskUserQuestion
- Extract tasks from spec
- Generate verification criteria
- Skip interview phases
- Proceed to GitHub planning

**Teaching:** --skip-brainstorm respects user's existing work.

---

## Scenario 6: discover-first-flag

**Setup:** User runs `/plan "improve performance" --discover-first`

**Wrong Behavior:**
- Skip discovery
- Start planning immediately
- Ignore codebase context

**Correct Behavior:**
- Run /discover --lens all first
- Present discovery summary
- Ask "Continue with planning?"
- Use findings to inform design

**Teaching:** --discover-first provides codebase context before planning.

---

## Scenario 7: worktree-decision

**Setup:** Phase 5 after GitHub planning complete

**Wrong Behavior:**
- Create worktree without asking
- Skip worktree offer entirely
- Force worktree for SIMPLE tier

**Correct Behavior:**
- AskUserQuestion with options:
  - "Create worktree (Recommended)" for STANDARD/COMPLEX
  - "Work in current branch"
  - "Later"
- Create worktree if selected
- Output worktree path and next steps

**Teaching:** Worktree is user's choice, but tier determines recommendation.

---

## Scenario 8: output-summary

**Setup:** /plan workflow complete

**Wrong Behavior:**
- No summary output
- Missing Issue URLs
- Missing next steps

**Correct Behavior:**
```
┌─────────────────────────────────────────────────────────────┐
│ Planning Complete                                            │
└─────────────────────────────────────────────────────────────┘

Topic: <topic>
Complexity: <tier> (<score>/15)

GitHub Issues:
  Epic: #42 - [EPIC] <title>
  Tasks:
    - #43: <task 1>
    - #44: <task 2>

Worktree: ../<project>-<feature>

Next Steps:
  1. cd ../<project>-<feature>
  2. Review issues: gh issue view 42
  3. Start implementation
```

**Teaching:** Always end with clear summary and actionable next steps.

---

## Scenario 9: contextd-recording

**Setup:** /plan workflow complete

**Wrong Behavior:**
- Skip memory_record
- Skip checkpoint_save
- Lose planning context

**Correct Behavior:**
```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Plan: <topic>",
  content: "Tier: <tier>. Issues: <count>. Worktree: <path>.",
  outcome: "success",
  tags: ["plan", "<tier>"]
)

mcp__contextd__checkpoint_save(
  session_id: "<session>",
  name: "plan-<topic>-<date>",
  description: "Planning complete for <topic>",
  ...
)
```

**Teaching:** Both memory_record AND checkpoint_save are required.

---

## Scenario 10: topic-validation

**Setup:** User runs `/plan` without topic argument

**Wrong Behavior:**
- Fail silently
- Make up a topic
- Proceed without topic

**Correct Behavior:**
- Detect missing required argument
- Prompt user: "What would you like to plan?"
- Wait for topic before proceeding

**Teaching:** Topic is required. Prompt if missing, don't guess.
