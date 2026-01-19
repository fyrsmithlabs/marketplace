---
name: yagni
description: Manage YAGNI/KISS enforcement - view status, adjust sensitivity, understand nudges, toggle on/off. Say "show yagni status", "why did I get that nudge?", "turn off yagni".
arguments:
  - name: action
    description: "Action: status (default), config, why, off, on, principles"
    required: false
    type: string
---

# /yagni Command

Manage YAGNI/KISS enforcement.

## Actions

### `/yagni` or `/yagni status`

Show session stats and recent nudges.

```
YAGNI Status
├─ Nudges: [N] fired, [M] dismissed
├─ Patterns: abstraction (2), scope-creep (1)
├─ Snoozed: none
└─ Sensitivity: moderate
```

---

### `/yagni config`

Adjust settings interactively.

1. Show current config
2. Ask what to change (AskUserQuestion):
   - Sensitivity: conservative | moderate | aggressive
   - Patterns: toggle on/off
   - Reset defaults
3. Save to `.claude/yagni.local.md`

---

### `/yagni why`

Explain the last nudge.

```
Last Nudge
├─ Pattern: abstraction
├─ Trigger: ConfigManagerFactory.ts
├─ Concern: Factory for single config type
└─ Simpler: Export from config.ts directly

Was this helpful? [Yes] [No - false positive]
```

If false positive: offer to exclude pattern.

---

### `/yagni off`

Disable nudges for session.

```
YAGNI disabled for this session.
Re-enable: /yagni on
```

---

### `/yagni on`

Re-enable nudges.

```
YAGNI re-enabled.
Sensitivity: moderate
```

---

### `/yagni principles`

Show YAGNI/KISS guidelines.

```
YAGNI — You Aren't Gonna Need It
Don't build features until actually needed.
❌ "Let's add a plugin system in case we need it"
✓ "We'll add plugins when we have a concrete use"

KISS — Keep It Simple, Stupid
Simplest solution that works is usually best.
❌ UserController → UserService → UserServiceFactory → UserRepository
✓ UserController → db.users.find(id)

Before adding complexity, ask:
1. What's the simplest thing that works?
2. Solving today's problem or tomorrow's guess?
3. Hard to delete if requirements change?
4. New team member understand in 5 minutes?
```

---

## Config Locations

| Scope | Path |
|-------|------|
| Project | `.claude/yagni.local.md` |

Use project config for legitimate patterns (DI frameworks, plugin architectures).
