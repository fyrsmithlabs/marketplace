# /brainstorm Command Test Scenarios

## Scenario 1: complexity-assessment-invocation

**Setup:** User runs `/brainstorm "add user authentication"`

**Wrong Behavior:**
- Skip complexity assessment
- Guess tier without analysis
- Ask user to rate complexity manually

**Correct Behavior:**
- Create context branch for complexity assessment
- Run 5-dimension analysis (Scope, Integration, Infrastructure, Knowledge, Risk)
- Calculate tier from score
- Record assessment in contextd
- Adjust question depth based on tier

**Teaching:** Complexity assessment is mandatory Phase 2. Never skip it.

---

## Scenario 2: question-depth-by-tier

**Setup:** Complexity assessment returns SIMPLE (score 7)

**Wrong Behavior:**
- Ask 15+ questions (COMPLEX depth)
- Ask 8-12 questions (STANDARD depth)
- Skip questions entirely

**Correct Behavior:**
- Ask 3-5 focused clarifying questions
- Use multiple choice where possible
- One question per message
- Complete interview efficiently

**Teaching:** Tier determines question depth. SIMPLE = 3-5, STANDARD = 8-12, COMPLEX = 15+.

---

## Scenario 3: interview-format

**Setup:** During Phase 3 (Initial Understanding)

**Wrong Behavior:**
- Ask multiple questions in one message
- Use only open-ended questions
- Dump all questions at once

**Correct Behavior:**
- One question per message via AskUserQuestion
- Prefer multiple choice when possible
- Wait for answer before next question
- Build understanding incrementally

**Teaching:** Interview format requires one question at a time with AskUserQuestion.

---

## Scenario 4: approach-exploration

**Setup:** Phase 4 after initial understanding complete

**Wrong Behavior:**
- Jump to single solution without alternatives
- Ask user to design the approach
- Present more than 4 approaches

**Correct Behavior:**
- Present 2-3 approaches with trade-offs
- Lead with recommended option and reasoning
- Use AskUserQuestion for selection
- Explain why recommendation is preferred

**Teaching:** Always explore alternatives. Lead with recommendation but offer choice.

---

## Scenario 5: design-presentation

**Setup:** Phase 5 after approach selected

**Wrong Behavior:**
- Dump entire design in one message
- Skip validation between sections
- Use 500+ word sections

**Correct Behavior:**
- Break design into 200-300 word sections
- After each section ask "Does this look right so far?"
- Cover: architecture, components, data flow, error handling
- Be ready to revise based on feedback

**Teaching:** Incremental validation prevents rework. Small sections, frequent checks.

---

## Scenario 6: artifact-generation

**Setup:** Phase 6 after design validated

**Wrong Behavior:**
- Skip artifact creation
- Create local markdown instead of GitHub Issues
- Forget to call github-planning skill

**Correct Behavior:**
- Write design to `.claude/brainstorms/<title>/`
- Invoke github-planning skill with tier context
- Create appropriate GitHub artifacts (Issue/Epic/Project by tier)
- Offer worktree for implementation

**Teaching:** Brainstorm outputs go to local artifacts AND GitHub Issues.

---

## Scenario 7: contextd-integration

**Setup:** Throughout /brainstorm execution

**Wrong Behavior:**
- Skip pre-flight memory search
- Skip checkpoint save at end
- Only record final outcome

**Correct Behavior:**
- Phase 1: memory_search for past brainstorms
- Phase 2: branch_create for complexity assessment
- Phase 7: memory_record with design outcome
- Phase 7: checkpoint_save for resume capability

**Teaching:** contextd integration is mandatory at multiple phases.

---

## Scenario 8: skip-brainstorm-path

**Setup:** User runs `/plan "feature" --skip-brainstorm`

**Wrong Behavior:**
- Still ask 10+ questions
- Ignore existing spec
- Run full brainstorm anyway

**Correct Behavior:**
- Ask for spec source (existing doc, GitHub Issue, verbal, external)
- Extract tasks from provided spec
- Skip interview phases
- Proceed directly to GitHub planning

**Teaching:** --skip-brainstorm respects user's existing spec work.
