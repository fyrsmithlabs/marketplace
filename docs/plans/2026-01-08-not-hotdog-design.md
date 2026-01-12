# not-hotdog: YAGNI/KISS Enforcement Design

**Date**: 2026-01-08
**Status**: Approved
**Author**: dahendel + Claude

---

## Overview

**Name**: `not-hotdog`

**Purpose**: A skill + hook combo that provides gentle, humorous nudges when development starts drifting toward over-engineering. Non-blocking, configurable, personality-driven.

**Philosophy**:
- Nudge, don't block — preserve developer autonomy
- Humor disarms defensiveness — Silicon Valley characters make feedback memorable
- Show, don't just tell — include "simpler path" examples
- Diminishing returns — avoid warning fatigue with backoff

**Inspiration**: Named after Pied Piper's "not-hotdog compression" algorithm — the elegant simple solution that beat Hooli's bloated approach.

---

## Components

| Component | Purpose |
|-----------|---------|
| **Skill** (`not-hotdog/SKILL.md`) | Principles reference, commands for config/control |
| **Hooks** (`PostToolUse`) | Pattern detection triggering nudges in real-time |
| **Config** | Global (`~/.claude/not-hotdog.yaml`) + project (`.claude/not-hotdog.local.md`) |

---

## Detection Patterns

### Pattern-Based Triggers (PostToolUse for Write/Edit)

| Pattern | Detection | Character |
|---------|-----------|-----------|
| **Abstraction creep** | New files matching `*Factory*`, `*Manager*`, `*Handler*`, `*Provider*`, `*Base*`, `*Abstract*`, `*Helper*`, `*Utils*` | Gilfoyle |
| **Config-driven everything** | Adding feature flags, env vars, or config for single-use behavior | Gavin Belson |
| **Speculative generality** | Interface/type with single implementation, unused generic parameters | Dinesh |
| **Premature optimization** | Caching, lazy loading, memoization before profiling shows need | Richard |
| **Dead code signals** | Commented-out code blocks, `// TODO: remove`, unused imports | Jian-Yang |
| **Swiss Army Knife** | Plugin systems, extensibility layers for simple features | Russ Hanneman |

### Scope-Based Triggers

| Signal | Threshold (Moderate) | Character |
|--------|---------------------|-----------|
| Files touched vs. task complexity | 5+ files for "simple" task keywords | Monica |
| New files created | 3+ new files in single session | Big Head |
| Inheritance/nesting depth | > 2 levels deep | Gilfoyle |

### Time-Based Triggers (with diminishing frequency)

| Signal | First trigger | Backoff | Character |
|--------|---------------|---------|-----------|
| Context usage | 50% | +25% each | Jared |
| Tool calls | 30 calls | +20 calls | Jared |
| Todos completed | Each completion | Once per todo | Monica |

---

## Character Mapping

| Character | Personality | Used For |
|-----------|-------------|----------|
| **Gilfoyle** | Deadpan, sardonic, technical superiority | Abstraction creep, deep nesting |
| **Gavin Belson** | Corporate pseudo-profound, enterprise brain | Config-driven everything |
| **Jared** | Earnest concern with unsettling undertones | Time-based check-ins |
| **Russ Hanneman** | "This guy fucks" bro energy | Swiss Army Knife syndrome |
| **Jian-Yang** | Blunt dismissal | Dead code, unused features |
| **Monica** | Exasperated voice of reason | Scope creep, todo completion |
| **Dinesh** | Insecure, projecting | Speculative generality |
| **Richard** | Anxious perfectionist, panic spirals | Premature optimization |
| **Big Head** | Genuine confused obliviousness | File explosion |

---

## Message Format

Each nudge follows: **Character quote → Problem → Simpler path example**

### Example: Gilfoyle (Abstraction creep)

```
"Oh, a UserServiceFactoryProvider. Because directly calling the database
was mass-market. Very pedestrian."

You created: src/factories/UserServiceFactoryProvider.ts
Task stated: "add user lookup"

Simpler path:
- Before: UserController → UserService → UserServiceFactory → UserRepository
- After:  UserController → UserRepository.findById(id)

Dismiss with: "I know what I'm doing" | Adjust sensitivity: ~/.claude/not-hotdog.yaml
```

### Example: Jared (Time check-in)

```
"I don't want to overstep. I know boundaries are important. My therapist
says I'm making progress. But... we've been refactoring for 47 minutes
and the original task was 'fix login bug.'

I'm sure there's a reason. There's always a reason. I believe in you.
But also: are we okay? Is the task okay?"

Original goal: Fix login bug
Current trajectory: Restructuring auth module, adding OAuth abstraction layer

[Continue] [Refocus on original task] [Update task scope]
```

### Example: Russ Hanneman (Swiss Army Knife)

```
"BRO. You're building a plugin system? For a TODO APP?
This is exactly the energy that put me in the three comma club.

...Except it didn't. I lost a comma doing stuff like this.
Don't lose a comma, bro."

You created: src/plugins/PluginManager.ts, PluginLoader.ts, PluginRegistry.ts
Task: "add delete button to todo items"

Simpler path:
- Before: PluginManager.register('delete', DeletePlugin) → PluginLoader.init()
- After:  <button onClick={() => deleteTodo(id)}>Delete</button>
```

---

## Configuration

### Global Config (`~/.claude/not-hotdog.yaml`)

```yaml
version: 1
sensitivity: moderate  # conservative | moderate | aggressive

patterns:
  abstraction_creep:
    enabled: true
    triggers:
      - "*Factory*"
      - "*Manager*"
      - "*Provider*"
      - "*Handler*"
      - "*Helper*"
      - "*Utils*"
      - "*Base*"
      - "*Abstract*"

  config_driven:
    enabled: true

  speculative_generality:
    enabled: true

  scope_creep:
    enabled: true
    file_threshold: 5
    new_file_threshold: 3

  time_based:
    enabled: true
    context_threshold: 50
    tool_call_threshold: 30
    backoff_multiplier: 1.5

characters:
  gilfoyle: true
  gavin_belson: true
  jared: true
  russ_hanneman: true
  jian_yang: true
  monica: true
  dinesh: true
  richard: true
  big_head: true

allowlist:
  - "**/generated/**"
  - "**/vendor/**"
  - "**/*.generated.ts"
```

### Project Override (`.claude/not-hotdog.local.md`)

```markdown
---
sensitivity: conservative
patterns:
  abstraction_creep:
    triggers:
      - "!*Factory*"  # This project legitimately uses factories
  scope_creep:
    file_threshold: 10  # Monorepo, touches more files naturally
  time_based:
    enabled: false  # Long refactoring sessions expected
---

# Project Notes

This is a legacy migration project. Higher thresholds appropriate.
```

---

## Implementation Structure

```
marketplace/
├── skills/
│   └── not-hotdog/
│       ├── SKILL.md              # Principles reference + commands
│       ├── templates/
│       │   └── config.yaml       # Default config template
│       └── examples/
│           └── simpler-paths.md  # Before/after examples library
│
├── commands/
│   └── not-hotdog.md             # /not-hotdog command
│
├── hooks/
│   └── hooks.json                # PostToolUse hook registration
│
└── includes/
    └── not-hotdog/
        ├── detector.md           # Pattern detection logic
        ├── characters.md         # Character voice templates
        └── messages.md           # Message assembly logic
```

---

## Rollout Phases

### Phase 1: Core Detection
- Abstraction creep pattern (Gilfoyle)
- Scope creep (Monica)
- Basic config loading
- Character message templates

### Phase 2: Full Pattern Suite
- Remaining patterns: config-driven, speculative generality, dead code
- Remaining characters
- Project-level config override

### Phase 3: Time-Based & Polish
- Jared's time-based check-ins with backoff
- "Simpler path" example generation
- `/not-hotdog config` command
- Session state tracking

---

## Success Criteria

- Nudges feel helpful, not annoying
- Humor lands (subjective, validated via user feedback)
- False positive rate < 20%
- Zero blocked workflows (nudges never prevent action)

---

## Research Sources

- [XP - Wikipedia](https://en.wikipedia.org/wiki/Extreme_programming) - YAGNI origin
- [Digital Nudges for Developer Actions](https://dl.acm.org/doi/10.1109/ICSE-Companion.2019.00082) - Nudge theory applied to dev tools
- [Cognitive Complexity - Axify](https://axify.io/blog/cognitive-complexity) - Threshold approaches
- [SAP Community - Avoid Overengineering](https://community.sap.com/t5/blogs-about-sap-websites/avoid-overengineering-in-software-development-make-it-simple-with-kiss-dry/ba-p/13904909) - YAGNI violations "look smart"
