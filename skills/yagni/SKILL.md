---
name: yagni
description: YAGNI/KISS enforcement with structured nudges. Use when discussing code complexity, over-engineering concerns, or to understand a yagni nudge.
---

# yagni

Enforces YAGNI (You Aren't Gonna Need It) and KISS (Keep It Simple, Stupid) principles through structured, non-blocking nudges with severity scoring and real-time detection.

## Core Principles

### YAGNI — You Aren't Gonna Need It
- Only implement features when actually needed
- Speculative features accumulate technical debt
- "YAGNI violations look smart and prepared. That's why they're dangerous."

### KISS — Keep It Simple, Stupid
- Simplest solution that works is usually best
- Complexity is cost, not feature
- Direct code beats clever code

---

## Commands

| Command | Purpose |
|---------|---------|
| `/yagni` | Show status and recent nudges |
| `/yagni config` | Adjust sensitivity |
| `/yagni why` | Explain the last nudge |
| `/yagni off` | Disable for session |
| `/yagni on` | Re-enable for session |
| `/yagni status` | Show session stats, patterns, snoozed items |
| `/yagni principles` | Review YAGNI/KISS guidelines |
| `/yagni whitelist <pattern>` | Add pattern to project allowlist |
| `/yagni dashboard` | Show technical debt summary |

---

## Pattern Detection

### Core Patterns

| Pattern | Trigger | Severity Weight |
|---------|---------|-----------------|
| `abstraction` | Filename: Factory, Manager, Provider, Handler, Helper, Utils, Base, Abstract, Wrapper, Builder, Coordinator, Orchestrator | 2 |
| `config-addiction` | Feature flag/env var for single-use behavior | 2 |
| `scope-creep` | Task touches 5+ files beyond original scope | 3 |
| `dead-code` | 10+ commented lines, unused imports | 1 |
| `speculative-generality` | Interface with single implementation | 2 |
| `swiss-army-knife` | Plugin system for single implementation | 3 |
| `premature-optimization` | Caching/memoization before profiling | 2 |
| `file-explosion` | 5+ new files in single session | 2 |

### Enhanced Detection — Complexity Metrics

| Metric | Threshold | Description |
|--------|-----------|-------------|
| **Cyclomatic Complexity** | >10 per function | Control flow paths indicating testability issues |
| **Cognitive Complexity** | >15 per function | Mental effort to understand code |
| **Nesting Depth** | >4 levels | Deep nesting indicates extraction opportunity |
| **Parameter Count** | >5 parameters | Function doing too much |
| **File Length** | >300 lines | File may need splitting |
| **Method Count** | >20 per class | Class has too many responsibilities |

### Code Smell Detection

| Smell | Indicator | Nudge |
|-------|-----------|-------|
| **God Object** | Class with 10+ dependencies | Split responsibilities |
| **Feature Envy** | Method uses other class more than own | Move method |
| **Data Clump** | Same 3+ params passed together | Extract to object |
| **Primitive Obsession** | Using primitives instead of small objects | Create value object |
| **Long Method** | Method >20 lines | Extract sub-methods |
| **Shotgun Surgery** | Change requires touching 5+ files | Consolidate logic |

### Design Pattern Library

Patterns have appropriate vs. premature contexts:

| Pattern | Appropriate When | Premature When |
|---------|------------------|----------------|
| **Factory** | 3+ concrete types, runtime selection | Single implementation |
| **Strategy** | Behavior varies at runtime | Single algorithm |
| **Observer** | Many-to-many relationships | Single subscriber |
| **Decorator** | Combinations of behaviors | Single wrapper |
| **Singleton** | Truly global state (rare) | Convenience access |
| **Repository** | Multiple data sources, complex queries | Simple CRUD |
| **Mediator** | Complex object interactions | 2 components |
| **Command** | Undo/redo, queuing | Simple function call |

---

## Severity Scoring

### Severity Calculation

Each violation receives a weighted severity score:

```
Severity = BaseWeight × ImpactMultiplier × FrequencyFactor

Where:
- BaseWeight: Pattern weight (1-3)
- ImpactMultiplier: Scope of impact (1.0-2.0)
- FrequencyFactor: How often this pattern recurs (1.0-1.5)
```

### Impact Scope Multipliers

| Scope | Multiplier | Description |
|-------|------------|-------------|
| **Local** | 1.0 | Single function/component |
| **Module** | 1.3 | Affects multiple files in module |
| **Cross-cutting** | 1.5 | Spans multiple modules |
| **Architectural** | 2.0 | System-wide implications |

### Severity Thresholds

| Total Score | Level | Action |
|-------------|-------|--------|
| 1-3 | **Low** | Informational nudge |
| 4-6 | **Medium** | Warning nudge, suggest simpler path |
| 7-9 | **High** | Strong nudge, provide refactoring guidance |
| 10+ | **Critical** | Escalate to code review, flag technical debt |

### Technical Debt Quantification

Estimate refactoring cost in time:

| Severity | Estimated Effort | Debt Category |
|----------|------------------|---------------|
| Low | 15-30 minutes | Cleanup |
| Medium | 1-2 hours | Minor refactor |
| High | 4-8 hours | Significant refactor |
| Critical | 1-3 days | Architectural change |

---

## Nudge Format

### Standard Nudge

```
┌─ YAGNI: [pattern] ─────────────────────────────────────
│ Severity: [Low|Medium|High|Critical] (score: N)
│
│ Trigger: [what triggered]
│ Concern: [why it matters]
│ Simpler: [alternative approach]
│
│ Debt Estimate: ~[time] to refactor later
│ Related: complexity-assessment score if available
│
└─ [Dismiss] [Snooze 1h] [Whitelist] [/yagni why]
```

### Minimal Nudge (Relaxed Mode)

```
YAGNI [pattern]: [one-line concern] → [Dismiss]
```

---

## When You See a Nudge

Nudges are **suggestions, not blocks**:

1. **Pause** — Is the complexity serving the current goal?
2. **Consider** — Could this be done more directly?
3. **Check score** — High severity warrants more attention
4. **Dismiss if valid** — Sometimes abstraction is warranted (document why)

---

## Interactive Controls

### Sensitivity Levels

| Level | Description | Use Case |
|-------|-------------|----------|
| **strict** | Fire on any pattern match | Learning projects, code reviews |
| **standard** | Balanced detection (default) | Normal development |
| **relaxed** | Only fire on high-severity patterns | Rapid prototyping, time-boxed work |

### Toggle Mechanism

```
/yagni on          # Enable detection (default)
/yagni off         # Disable for session
/yagni status      # Show current state

State persists for session only.
Global default: enabled at standard sensitivity.
```

### Project-Specific Overrides

Create `.claude/yagni.local.md`:

```yaml
---
# Sensitivity: strict | standard | relaxed
sensitivity: standard

# Patterns to always allow (legitimate uses)
whitelist:
  - "*Factory*"      # DI framework requirement
  - "*Repository*"   # Project architecture standard
  - "Abstract*"      # Base classes for plugin system

# Patterns to always flag (project-specific concerns)
escalate:
  - "*Manager*"      # Team prefers explicit naming
  - "*Helper*"       # Discouraged in this codebase

# Complexity thresholds (override defaults)
thresholds:
  cyclomatic_complexity: 15    # Allow higher for legacy code
  cognitive_complexity: 20
  file_length: 500             # Larger files acceptable

# Ignore paths (auto-generated, vendor code)
ignore:
  - "**/generated/**"
  - "**/vendor/**"
  - "**/*.g.dart"
---
```

### Pattern Whitelisting

Add legitimate patterns interactively:

```
/yagni whitelist "*Factory*"
> Added *Factory* to .claude/yagni.local.md whitelist
> Reason required: [DI framework requirement]
```

---

## Hook Integration

### PreToolUse Hook (Real-time Detection)

YAGNI detection fires via PreToolUse hooks on Write and Edit operations:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Analyze the file being written/edited for YAGNI violations:\n\n1. Check filename against abstraction patterns\n2. Assess complexity metrics if code is substantial\n3. Look for code smells (god object, feature envy, etc.)\n4. Check against project whitelist in .claude/yagni.local.md\n\nIf violation detected and not whitelisted:\n- Calculate severity score\n- Format structured nudge\n- ALLOW with nudge (non-blocking)\n\nIf no violation or whitelisted: ALLOW silently."
          }
        ]
      }
    ]
  }
}
```

### Hook Behavior

- **Non-blocking**: Hooks ALLOW the operation but display nudge
- **Whitelist-aware**: Checks `.claude/yagni.local.md` before firing
- **Severity-gated**: In relaxed mode, only fires on High/Critical

### Integration with Commit Hooks

Optional pre-commit integration for CI:

```bash
# In .husky/pre-commit or similar
# Summarize session YAGNI violations
claude --skill yagni --action summary --format json
```

---

## Complexity Assessment Integration

YAGNI integrates with the `complexity-assessment` skill for comprehensive analysis.

### Cross-Skill Data Flow

```
complexity-assessment              yagni
       │                            │
       ├─ Scope score ──────────────┤
       │                            │
       ├─ Risk score ───────────────┤ → Severity multiplier
       │                            │
       └─ Tier (SIMPLE/STANDARD/    │
          COMPLEX) ─────────────────┘ → Sensitivity adjustment
```

### Automatic Sensitivity Adjustment

| Complexity Tier | YAGNI Sensitivity |
|-----------------|-------------------|
| SIMPLE | Standard (quick tasks shouldn't over-engineer) |
| STANDARD | Standard |
| COMPLEX | Relaxed (architectural decisions may require patterns) |

### Linking to Refactoring Guidance

When severity is High or Critical, link to examples:

```
┌─ YAGNI: abstraction ──────────────────────────────────
│ ...
│ Refactoring Guide: skills/yagni/examples/simpler-paths.md#abstraction-creep
└─────────────────────────────────────────────────────────
```

---

## contextd Integration (Optional)

When contextd MCP is available, YAGNI learns from project history.

### Recording Violations

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "YAGNI: <pattern> in <filename>",
  content: "Pattern: <pattern>. Severity: <score>. Trigger: <trigger>.
            Dismissed: <yes/no>. Reason: <user reason if dismissed>.",
  outcome: "<dismissed|addressed|ignored>",
  tags: ["yagni", "<pattern>", "<severity-level>"]
)
```

### Tracking False Positives

```
# When user marks nudge as false positive
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "YAGNI False Positive: <pattern>",
  content: "Pattern <pattern> on <filename> was false positive.
            User reason: <reason>. Consider adding to whitelist.",
  outcome: "false-positive",
  tags: ["yagni", "false-positive", "<pattern>"]
)
```

### Learning Project Patterns

Query past violations to improve detection:

```
# Before firing nudge, check history
mcp__contextd__memory_search(
  project_id: "<project>",
  query: "yagni false-positive <pattern>",
  limit: 5
)

# If pattern has high false-positive rate for this project,
# auto-suggest adding to whitelist
```

### Session Summary

At session end (or on `/yagni dashboard`):

```
YAGNI Session Summary
├─ Violations detected: 7
├─ Dismissed: 3 (reasons recorded)
├─ Addressed: 2
├─ Ignored: 2
├─ False positives: 1 (whitelist suggested)
├─ Total debt estimate: ~4 hours
└─ Patterns: abstraction (3), scope-creep (2), config-addiction (2)

Trend: abstraction violations up 20% from last 5 sessions
```

---

## Technical Debt Dashboard

View with `/yagni dashboard`:

```
┌─ Technical Debt Dashboard ──────────────────────────────
│
│ Current Session
│ ├─ Active violations: 3
│ ├─ Estimated debt: ~2.5 hours
│ └─ Highest severity: Medium (score 5)
│
│ Project History (last 30 days)
│ ├─ Total violations: 47
│ ├─ Addressed: 31 (66%)
│ ├─ Accumulated debt: ~18 hours
│ └─ Top patterns: abstraction (18), scope-creep (12)
│
│ Recommendations
│ ├─ Consider whitelisting: *Repository* (8 false positives)
│ ├─ Escalate for review: payment-service.ts (Critical)
│ └─ Schedule debt paydown: ~4 hours/week to stay current
│
└─────────────────────────────────────────────────────────
```

---

## Configuration

### Project Override (`.claude/yagni.local.md`)

Full configuration example:

```yaml
---
# Core settings
sensitivity: standard    # strict | standard | relaxed
enabled: true           # Master toggle

# Pattern configuration
whitelist:
  - "*Factory*"         # Legitimate DI framework
  - "*Repository*"      # Project standard

escalate:
  - "*Manager*"         # Discouraged naming

# Threshold overrides
thresholds:
  cyclomatic_complexity: 15
  cognitive_complexity: 20
  nesting_depth: 5
  parameter_count: 6
  file_length: 400
  method_count: 25

# Ignore paths
ignore:
  - "**/generated/**"
  - "**/vendor/**"
  - "**/migrations/**"
  - "**/*.generated.*"

# contextd integration
contextd:
  record_violations: true
  track_false_positives: true
  learn_patterns: true
---
```

---

## Red Flags

- Abstractions before 2+ concrete uses
- Configuration for one-place behavior
- Plugin systems for single implementations
- Optimizing before profiling proves need
- "Future-proofing" against non-existent requirements
- Cyclomatic complexity >10 without tests
- God objects with 10+ dependencies
- Methods >20 lines without extraction

---

## The Simple Test

1. **What's the simplest thing that works?** — Start there
2. **Solving today's problem or tomorrow's guess?** — Solve today's
3. **Hard to delete if requirements change?** — Too coupled
4. **New team member understand in 5 minutes?** — If not, simplify
5. **Does complexity score justify the pattern?** — Check metrics

---

## Integration Points

| Integration | Purpose |
|-------------|---------|
| `complexity-assessment` | Severity multipliers, tier-based sensitivity |
| `contextd` | Violation history, false positive tracking, pattern learning |
| `git-workflows` | Pre-commit summaries, PR debt reports |
| `brainstorm` | Early YAGNI check during design phase |
| Hooks | Real-time detection on Write/Edit |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Too many nudges | Lower sensitivity to `relaxed` or add patterns to whitelist |
| Missing violations | Raise sensitivity to `strict` |
| False positives | Use `/yagni whitelist <pattern>` with reason |
| Nudges not firing | Check `/yagni status`, ensure not disabled |
| contextd not recording | Verify MCP server is running |
