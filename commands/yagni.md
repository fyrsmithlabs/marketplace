---
name: yagni
description: Manage YAGNI/KISS enforcement - view status, adjust sensitivity, understand nudges, toggle on/off, manage whitelist, view debt dashboard. Say "show yagni status", "why did I get that nudge?", "turn off yagni", "whitelist a pattern".
arguments:
  - name: action
    description: "Action: status (default), config, why, off, on, principles, whitelist, dashboard"
    required: false
    type: string
  - name: pattern
    description: "Pattern to whitelist (only used with whitelist action)"
    required: false
    type: string
---

# /yagni Command

Manage YAGNI/KISS enforcement with severity scoring and technical debt tracking.

## Actions

### `/yagni` or `/yagni status`

Show session stats, recent nudges, and current settings.

```
YAGNI Status
├─ Enabled: yes
├─ Sensitivity: standard
├─ Session Stats
│   ├─ Nudges fired: [N]
│   ├─ Dismissed: [M] (with reasons)
│   ├─ Addressed: [P]
│   └─ Ignored: [Q]
├─ Patterns Detected
│   ├─ abstraction (2) - Severity: Medium
│   ├─ scope-creep (1) - Severity: High
│   └─ Total debt estimate: ~3 hours
├─ Snoozed: none
└─ Project whitelist: *Factory*, *Repository*
```

---

### `/yagni config`

Adjust settings interactively.

1. Show current config
2. Ask what to change (AskUserQuestion):
   - Sensitivity: strict | standard | relaxed
   - Patterns: toggle on/off
   - Thresholds: complexity limits
   - contextd: enable/disable learning
   - Reset defaults
3. Save to `.claude/yagni.local.md`

---

### `/yagni why`

Explain the last nudge with full context.

```
Last Nudge
├─ Pattern: abstraction
├─ Severity: Medium (score: 4.2)
├─ Trigger: ConfigManagerFactory.ts
├─ Concern: Factory pattern with single implementation
├─ Simpler: Export config functions directly from config.ts
├─ Debt Estimate: ~1-2 hours to refactor later
└─ Refactoring Guide: skills/yagni/examples/simpler-paths.md#abstraction-creep

Was this helpful?
[Yes] [No - false positive] [Add to whitelist]
```

If false positive:
- Record in contextd (if available)
- Offer to exclude pattern from project

---

### `/yagni off`

Disable nudges for session.

```
YAGNI disabled for this session.
├─ Active violations preserved for review
├─ Hooks will not fire new nudges
└─ Re-enable: /yagni on
```

---

### `/yagni on`

Re-enable nudges.

```
YAGNI re-enabled.
├─ Sensitivity: standard
├─ Checking against: 8 patterns + 6 code smells
└─ Project whitelist loaded: 2 patterns
```

---

### `/yagni principles`

Show YAGNI/KISS guidelines with examples.

```
YAGNI — You Aren't Gonna Need It
Don't build features until actually needed.
❌ "Let's add a plugin system in case we need it"
✓ "We'll add plugins when we have a concrete use"

KISS — Keep It Simple, Stupid
Simplest solution that works is usually best.
❌ UserController → UserService → UserServiceFactory → UserRepository
✓ UserController → db.users.find(id)

Design Pattern Guide:
├─ Factory: 3+ types needed before using
├─ Strategy: Runtime variation required
├─ Repository: Multiple data sources
└─ Observer: Many-to-many relationships

Before adding complexity, ask:
1. What's the simplest thing that works?
2. Solving today's problem or tomorrow's guess?
3. Hard to delete if requirements change?
4. New team member understand in 5 minutes?
5. Does severity score justify this pattern?
```

---

### `/yagni whitelist <pattern>`

Add a pattern to the project allowlist.

```
/yagni whitelist "*Factory*"
```

Output:
```
Adding to whitelist: *Factory*

Reason required (for documentation):
> [User provides: DI framework requirement]

Added to .claude/yagni.local.md:
whitelist:
  - "*Factory*"  # DI framework requirement

Future files matching *Factory* will not trigger abstraction nudges.
```

If no pattern provided, show current whitelist and offer to add/remove.

---

### `/yagni dashboard`

Show technical debt summary and recommendations.

```
┌─ Technical Debt Dashboard ──────────────────────────────
│
│ Current Session
│ ├─ Active violations: 3
│ ├─ Estimated debt: ~2.5 hours
│ ├─ Highest severity: Medium (score 5)
│ └─ Patterns: abstraction (2), config-addiction (1)
│
│ Project History (last 30 days) [contextd]
│ ├─ Total violations: 47
│ ├─ Addressed: 31 (66%)
│ ├─ Accumulated debt: ~18 hours
│ └─ Top patterns: abstraction (18), scope-creep (12)
│
│ False Positive Analysis [contextd]
│ ├─ Rate: 12% (6 of 47)
│ ├─ Suggested whitelist: *Repository* (4 occurrences)
│ └─ Pattern learning: enabled
│
│ Recommendations
│ ├─ Consider whitelisting: *Repository* (high false positive rate)
│ ├─ Escalate for review: payment-service.ts (Critical severity)
│ └─ Schedule debt paydown: ~4 hours/week to stay current
│
└─────────────────────────────────────────────────────────
```

If contextd unavailable, show session-only data with note.

---

## Config Locations

| Scope | Path |
|-------|------|
| Project | `.claude/yagni.local.md` |

Use project config for:
- Legitimate patterns (DI frameworks, plugin architectures)
- Complexity threshold adjustments for legacy code
- Path exclusions for generated code
- contextd integration settings

---

## Severity Levels

| Level | Score | Action |
|-------|-------|--------|
| Low | 1-3 | Informational nudge |
| Medium | 4-6 | Warning with simpler path |
| High | 7-9 | Strong nudge + refactoring guide |
| Critical | 10+ | Escalate to code review |

---

## Integration

- **complexity-assessment**: Auto-adjusts sensitivity based on task tier
- **contextd**: Records violations, tracks false positives, learns patterns
- **Hooks**: Real-time detection on Write/Edit operations
- **brainstorm**: Early YAGNI check during design phase
