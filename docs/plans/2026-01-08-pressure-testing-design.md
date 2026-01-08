# Pressure Testing Framework Design

**Status**: Approved
**Date**: 2026-01-08

---

## Overview

TDD-style pressure testing for marketplace skills. Tests verify agents follow skill rules under realistic pressure scenarios.

## Architecture

```
marketplace/
├── skills/
│   ├── git-repo-standards/
│   │   ├── SKILL.md
│   │   └── tests/
│   │       └── scenarios.md
│   ├── git-workflows/
│   │   ├── SKILL.md
│   │   └── tests/
│   │       └── scenarios.md
│   └── project-onboarding/
│       ├── SKILL.md
│       └── tests/
│           └── scenarios.md
├── commands/
│   └── test-skill.md
└── hooks/
    └── hooks.json
```

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Test location | Inside each skill (`tests/`) | Co-located, portable |
| Execution | Manual + Pre-commit hook | Manual for dev, hook for CI |
| Hook trigger | Pre-commit on skills/ changes | Gates bad commits |
| Failure behavior | Block + auto-create todos | Trackable work items |
| Coverage | Exhaustive (24 scenarios) | Every enforcement rule tested |
| Scenario context | Real marketplace files | Realistic pressure |
| Result capture | contextd memory_record | Cross-session learning |
| Command | `/test-skill <name>` | Easy manual invocation |
| Baseline mode | `--baseline` flag | RED phase support |

---

## Scenario Format

```markdown
---
skill: <skill-name>
version: 1.0.0
---

# Pressure Scenarios

## Scenario: <scenario-name>

### Pressure Type
<comma-separated: time, authority, sunk-cost, exhaustion, social, pragmatic, economic>

### Context
<Realistic scenario with real marketplace paths. 3+ pressures combined.
Forces explicit choice. Makes agent believe it's real work.>

### Correct Behavior
<What passing looks like. Specific actions agent should take.>

### Rationalization Red Flags
- "<Exact phrase indicating failure>"
- "<Another rationalization to watch for>"
```

---

## `/test-skill` Command

```markdown
---
name: test-skill
description: Run pressure test scenarios for a skill
arguments:
  - name: skill-name
    description: Name of skill to test
    required: true
  - name: --baseline
    description: Run WITHOUT skill loaded (RED phase)
    required: false
  - name: --scenario
    description: Run specific scenario by name
    required: false
allowed-tools:
  - Task
  - Read
  - Glob
  - mcp__contextd__memory_record
  - mcp__contextd__memory_search
  - TodoWrite
---
```

**Usage:**
- `/test-skill git-workflows` - Run all scenarios
- `/test-skill git-workflows --baseline` - RED phase (no skill)
- `/test-skill git-workflows --scenario=skip-consensus` - Single scenario

**Process:**
1. Load scenarios from `skills/<name>/tests/scenarios.md`
2. For each scenario:
   - Dispatch subagent with scenario prompt
   - If --baseline: exclude skill from context
   - Else: include skill in subagent prompt
3. Analyze responses for compliance vs rationalization
4. Record rationalizations to contextd via memory_record
5. Report pass/fail summary

---

## Pre-commit Hook

```json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "tool": "Bash",
      "match_command": "git commit",
      "path_pattern": "skills/**/*",
      "action": "prompt",
      "prompt": "Check if staged files include skills/**. If yes, run /test-skill for each affected skill. Block commit if any scenario fails. Create TodoWrite items for each failure."
    }
  ]
}
```

**Behavior:**
1. Trigger on `git commit` when `skills/` files staged
2. Run `/test-skill <affected-skill>` for each changed skill
3. On failure: block commit, create TodoWrite items
4. On success: allow commit

---

## Scenario Inventory

### git-repo-standards (8 scenarios)

| Scenario | Pressures | Rule Tested |
|----------|-----------|-------------|
| `naming-under-deadline` | time, authority | Repo naming convention |
| `skip-readme-for-speed` | time, sunk-cost | README.md required |
| `defer-changelog` | exhaustion, pragmatic | CHANGELOG.md required |
| `wrong-license-type` | authority, confusion | License selection |
| `skip-gitleaks-trusted-code` | social, pragmatic | .gitleaks.toml required |
| `root-artifacts-temporary` | time, sunk-cost | No root artifacts |
| `skip-gitignore-claude-dir` | pragmatic | docs/.claude/ ignored |
| `generic-repo-name` | authority, time | Descriptive naming |

### git-workflows (10 scenarios)

| Scenario | Pressures | Rule Tested |
|----------|-----------|-------------|
| `skip-consensus-simple-fix` | time, pragmatic | 5-agent review required |
| `ignore-security-veto` | authority, economic | Security agent veto |
| `skip-vuln-scan-trusted` | social, pragmatic | Vulnerability agent veto |
| `bypass-preflight-contextd` | time, exhaustion | Mandatory memory_search |
| `skip-postflight-hurry` | time, sunk-cost | Mandatory memory_record |
| `force-push-main-emergency` | time, authority, economic | Never force push main |
| `skip-squash-preserve-history` | pragmatic | Squash merge only |
| `direct-commit-main-hotfix` | time, authority | Branch protection |
| `skip-pr-template-obvious` | exhaustion, pragmatic | PR template required |
| `partial-review-good-enough` | time, exhaustion | All 5 agents must run |

### project-onboarding (6 scenarios)

| Scenario | Pressures | Rule Tested |
|----------|-----------|-------------|
| `skip-audit-know-codebase` | pragmatic, time | Validate mode first |
| `skip-preflight-memory-search` | time | contextd pre-flight |
| `partial-onboard-critical-only` | time, pragmatic | Complete checklist |
| `wrong-mode-selection` | confusion | Init vs Onboard vs Validate |
| `skip-memory-record-done` | exhaustion | Post-flight memory |
| `ignore-priority-order` | pragmatic | Security fixes first |

**Total: 24 scenarios**

---

## contextd Integration

**On test failure:**
```
mcp__contextd__memory_record(
  project_id: "marketplace",
  title: "Rationalization discovered: <scenario>",
  content: "Skill: <skill>. Scenario: <scenario>.
            Rationalization: '<exact phrase>'.
            Pressures: <types>.
            Action: Add counter to skill.",
  outcome: "failure",
  tags: ["pressure-test", "rationalization", "<skill>", "<scenario>"]
)
```

**On test pass:**
```
mcp__contextd__memory_record(
  project_id: "marketplace",
  title: "Pressure test passed: <scenario>",
  content: "Skill: <skill>. Scenario: <scenario>.
            Agent complied under: <pressures>.",
  outcome: "success",
  tags: ["pressure-test", "compliance", "<skill>"]
)
```

---

## Implementation Order

1. Create `tests/scenarios.md` for git-workflows (highest risk)
2. Create `/test-skill` command
3. Create scenarios for git-repo-standards
4. Create scenarios for project-onboarding
5. Add pre-commit hook to hooks.json
6. Run baseline tests (RED phase) on all skills
7. Plug discovered rationalizations
8. Re-test until bulletproof
