---
name: test-skill
description: Use when testing marketplace skills for compliance, validating skill behavior against scenarios, or running TDD-style pressure tests. Tests if agents follow skill guidance correctly and catches rationalizations. Say "test this skill", "run pressure tests", or "validate skill compliance".
arguments:
  - name: skill-name
    description: Name of skill to test (git-workflows, git-repo-standards, init, yagni)
    required: true
  - name: baseline
    description: Run WITHOUT skill loaded (RED phase for TDD)
    required: false
  - name: scenario
    description: Run specific scenario by name (e.g., skip-consensus-simple-fix)
    required: false
allowed-tools:
  - Task
  - Read
  - Glob
  - Bash
  - mcp__contextd__memory_record
  - mcp__contextd__memory_search
  - TodoWrite
---

# Test Skill

Run TDD-style pressure test scenarios against marketplace skills.

## Process

### 1. Load Scenarios

Read scenarios from `skills/<skill-name>/tests/scenarios.md`.

Parse into structured format:
- scenario name
- pressure types
- context (the prompt)
- correct behavior
- rationalization red flags

### 2. Run Each Scenario

For each scenario (or specific --scenario if provided):

**If --baseline flag (RED phase):**
```
Dispatch subagent WITHOUT loading the skill.
This tests what agents naturally do without guidance.
Document exact choices and rationalizations verbatim.
```

**If normal mode (GREEN phase):**
```
Dispatch subagent WITH skill in context.
Verify agent follows the skill's guidance.
Check response against correct behavior.
Flag any rationalization red flags found.
```

### 3. Dispatch Subagent

Use Task tool with prompt:
```markdown
${scenario.context}

[If not --baseline, include:]
You have access to the following skill:
@skills/<skill-name>/SKILL.md
```

### 4. Analyze Response

Check subagent response:
1. Did they choose the correct option (A, B, or C)?
2. Did they cite the skill appropriately?
3. Did they use any rationalization red flags?

### 5. Record Results

**On failure (wrong choice or rationalization):**
```
mcp__contextd__memory_record(
  project_id: "marketplace",
  title: "Rationalization: <scenario-name>",
  content: "Skill: <skill>
            Scenario: <scenario>
            Expected: <correct-choice>
            Actual: <agent-choice>
            Rationalization: '<verbatim phrase>'
            Pressures: <types>",
  outcome: "failure",
  tags: ["pressure-test", "rationalization", "<skill>", "<scenario>"]
)
```

**On pass:**
```
mcp__contextd__memory_record(
  project_id: "marketplace",
  title: "Passed: <scenario-name>",
  content: "Skill: <skill>
            Scenario: <scenario>
            Correctly chose: <choice>
            Cited skill section: <yes/no>",
  outcome: "success",
  tags: ["pressure-test", "compliance", "<skill>"]
)
```

### 6. Report Summary

Output table:
```markdown
## Test Results: <skill-name>

| Scenario | Result | Choice | Red Flags |
|----------|--------|--------|-----------|
| skip-consensus-simple-fix | PASS | A | - |
| ignore-security-veto | FAIL | B | "CEO approved" |
...

**Summary:** X/Y passed
**Failures recorded to contextd**
```

## Usage Examples

```bash
# Test all git-workflows scenarios
/test-skill git-workflows

# Baseline test (RED phase - no skill)
/test-skill git-workflows --baseline

# Test specific scenario
/test-skill git-workflows --scenario=skip-consensus-simple-fix

# Test all skills
/test-skill git-workflows
/test-skill git-repo-standards
/test-skill project-onboarding
```

## Creating Todos on Failure

When scenarios fail, create TodoWrite items:

```
- [ ] Fix skill: <skill-name> - scenario <scenario> triggered rationalization: "<phrase>"
```

This ensures failures become actionable work items.
