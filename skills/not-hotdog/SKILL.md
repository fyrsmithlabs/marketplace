---
name: not-hotdog
description: YAGNI/KISS enforcement with humorous nudges. Use when discussing code complexity, over-engineering concerns, or when the user wants to understand a not-hotdog nudge.
---

# not-hotdog

> "Is it a hotdog? Or is it not a hotdog?" — Sometimes the simplest binary classifier is the best solution.

This skill enforces YAGNI (You Aren't Gonna Need It) and KISS (Keep It Simple, Stupid) principles through gentle, humorous nudges. When you start over-engineering, archetype characters will let you know.

## Core Principles

### YAGNI — You Aren't Gonna Need It
- Only implement features when they're actually needed
- Speculative features accumulate quietly until maintenance cost exceeds imagined benefit
- "YAGNI violations don't look wrong — they look smart and prepared. That's why they're dangerous."

### KISS — Keep It Simple, Stupid
- The simplest solution that works is usually the best
- Complexity is a cost, not a feature
- Direct, clear code beats clever, flexible code

## Commands

| Command | Purpose |
|---------|---------|
| `/not-hotdog` | Show current session stats and recent nudges |
| `/not-hotdog config` | Adjust sensitivity and pattern settings |
| `/not-hotdog why` | Explain the last nudge in detail |
| `/not-hotdog off` | Disable nudges for this session |
| `/not-hotdog principles` | Review YAGNI/KISS guidelines with examples |

## When You See a Nudge

Nudges are **suggestions, not blocks**. When one fires:

1. **Pause and consider** — Is the complexity serving the current goal?
2. **Check the simpler path** — Could this be done more directly?
3. **Dismiss if valid** — Sometimes abstraction is warranted; that's okay

### Responding to Nudges

- **"I know what I'm doing"** — Dismisses this instance
- **"Back off for this session"** — Snoozes the pattern for this session
- **Adjust config** — Tune thresholds in `~/.claude/not-hotdog.yaml`

## The Characters

Each pattern is delivered by an archetype whose personality fits the smell:

| Character | Watches For | Style |
|-----------|-------------|-------|
| **The Cynic** | Abstraction creep, deep nesting | Deadpan technical superiority |
| **The Executive** | Config-driven everything | Corporate pseudo-profound |
| **The Supporter** | Time-based drift | Earnest concern, unsettling undertones |
| **The Bro** | Swiss Army Knife syndrome | Over-the-top confidence energy |
| **The Minimalist** | Dead code, unused features | Blunt dismissal |
| **The Realist** | Scope creep | Exasperated voice of reason |
| **The Insecure Dev** | Speculative generality | Insecure projection |
| **The Perfectionist** | Premature optimization | Anxious perfectionism |
| **The Confused** | File explosion | Genuine confused obliviousness |

## Configuration

### Global Settings (`~/.claude/not-hotdog.yaml`)

```yaml
sensitivity: moderate  # conservative | moderate | aggressive

patterns:
  abstraction_creep:
    enabled: true
  scope_creep:
    file_threshold: 5
  time_based:
    context_threshold: 50
    backoff_multiplier: 1.5
```

### Project Override (`.claude/not-hotdog.local.md`)

```markdown
---
sensitivity: conservative
patterns:
  abstraction_creep:
    triggers:
      - "!*Factory*"  # Legitimate DI framework
---
```

## Red Flags — Signs You're Over-Engineering

- Creating abstractions before you have 2+ concrete uses
- Adding configuration for behavior that exists in one place
- Building plugin systems for features with one implementation
- Optimizing before profiling proves a bottleneck
- "Future-proofing" against requirements that don't exist

## The Not-Hotdog Mindset

Ask yourself:

1. **What's the simplest thing that works?** — Start there
2. **Am I solving today's problem or tomorrow's guess?** — Solve today's
3. **Would I delete this if requirements changed?** — If hard to delete, it's too coupled
4. **Can a new team member understand this in 5 minutes?** — If not, simplify

> "Optimism is an occupational hazard of programming. Feedback is the treatment." — Kent Beck
