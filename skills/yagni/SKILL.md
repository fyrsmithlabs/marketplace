---
name: yagni
description: YAGNI/KISS enforcement with structured nudges. Use when discussing code complexity, over-engineering concerns, or to understand a yagni nudge.
---

# yagni

Enforces YAGNI (You Aren't Gonna Need It) and KISS (Keep It Simple, Stupid) principles through structured, non-blocking nudges.

## Core Principles

### YAGNI — You Aren't Gonna Need It
- Only implement features when actually needed
- Speculative features accumulate technical debt
- "YAGNI violations look smart and prepared. That's why they're dangerous."

### KISS — Keep It Simple, Stupid
- Simplest solution that works is usually best
- Complexity is cost, not feature
- Direct code beats clever code

## Commands

| Command | Purpose |
|---------|---------|
| `/yagni` | Show status and recent nudges |
| `/yagni config` | Adjust sensitivity |
| `/yagni why` | Explain the last nudge |
| `/yagni off` | Disable for session |
| `/yagni principles` | Review YAGNI/KISS guidelines |

## Patterns Detected

| Pattern | Trigger |
|---------|---------|
| `abstraction` | Filename: Factory, Manager, Provider, Handler, Helper, Utils, Base, Abstract, Wrapper, Builder, Coordinator, Orchestrator |
| `config-addiction` | Feature flag/env var for single-use behavior |
| `scope-creep` | "Fix typo" task touches 5+ files |
| `dead-code` | 10+ commented lines, unused imports |

## Nudge Format

```
⚠️ YAGNI: [pattern]
├─ Trigger: [what triggered]
├─ Concern: [why it matters]
└─ Simpler: [alternative]

Options: Dismiss | Snooze | /yagni config
```

## When You See a Nudge

Nudges are **suggestions, not blocks**:

1. **Pause** — Is the complexity serving the current goal?
2. **Consider** — Could this be done more directly?
3. **Dismiss if valid** — Sometimes abstraction is warranted

## Configuration

### Project Override (`.claude/yagni.local.md`)

```yaml
---
sensitivity: conservative  # conservative | moderate | aggressive
exclude:
  - "*Factory*"  # Legitimate DI framework
---
```

## Red Flags

- Abstractions before 2+ concrete uses
- Configuration for one-place behavior
- Plugin systems for single implementations
- Optimizing before profiling proves need
- "Future-proofing" against non-existent requirements

## The Simple Test

1. **What's the simplest thing that works?** — Start there
2. **Solving today's problem or tomorrow's guess?** — Solve today's
3. **Hard to delete if requirements change?** — Too coupled
4. **New team member understand in 5 minutes?** — If not, simplify
