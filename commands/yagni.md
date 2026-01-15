---
name: yagni
description: Use when managing YAGNI/KISS enforcement - view nudge statistics, adjust sensitivity, understand why a nudge fired, or toggle enforcement on/off. Say "show yagni status", "why did I get that nudge?", "turn off yagni", or "adjust complexity settings".
arguments:
  - name: action
    description: "Action to perform: status (default), config, why, off, on, principles"
    required: false
    type: string
---

# /yagni Command

Manage the yagni YAGNI/KISS enforcement system.

## Actions

### `/yagni` or `/yagni status`

Show current session statistics and recent nudges.

**Display:**
```
┌─────────────────────────────────────────────────────────────┐
│ 🤠 yagni status                                        │
└─────────────────────────────────────────────────────────────┘

Session Stats:
  Files touched: {{count}}
  Files created: {{count}}
  Tool calls: {{count}}
  Context usage: {{percent}}%

Nudges fired this session:
  {{pattern}}: {{count}} ({{dismissed_count}} dismissed)
  ...

Snoozed patterns: {{list or "none"}}

Current sensitivity: {{sensitivity}}
Config: {{config_path}}
```

---

### `/yagni config`

Interactively adjust sensitivity and pattern settings.

**Flow:**

1. Show current settings:
```
Current configuration:

Sensitivity: moderate
Patterns enabled:
  ✓ abstraction_creep (The Cynic)
  ✓ config_driven (The Executive)
  ✓ scope_creep (The Realist)
  ✓ time_based (The Supporter)
  ...

Characters enabled: all

Config file: ~/.claude/yagni.yaml
```

2. Ask what to adjust using AskUserQuestion:

**Question 1**: What would you like to adjust?
- Sensitivity level
- Enable/disable specific patterns
- Enable/disable specific characters
- Adjust thresholds
- Reset to defaults

3. Based on selection, make changes:

**For sensitivity:**
- conservative: Fewer nudges, higher thresholds
- moderate: Balanced (default)
- aggressive: More nudges, lower thresholds

**For patterns:**
- Toggle individual patterns on/off
- Adjust pattern-specific thresholds

4. Write updated config to `~/.claude/yagni.yaml`

5. Confirm changes:
```
Configuration updated:
  Sensitivity: conservative → moderate
  abstraction_creep: disabled → enabled

Changes saved to ~/.claude/yagni.yaml
```

---

### `/yagni why`

Explain the most recent nudge in detail.

**Display:**
```
┌─────────────────────────────────────────────────────────────┐
│ 🤠 yagni: Why did {{character}} speak up?              │
└─────────────────────────────────────────────────────────────┘

Pattern: {{pattern_name}}
Triggered by: {{trigger_file_or_action}}

What was detected:
  {{detailed_explanation}}

Why this matters:
  {{yagni_kiss_principle_explanation}}

The simpler path:
  {{before_after_example}}

Was this nudge helpful?
  [Yes - good catch] [No - false positive] [Needs tuning]
```

If "No - false positive" or "Needs tuning":
- Offer to add to allowlist
- Offer to adjust sensitivity for this pattern
- Record feedback for future improvement

---

### `/yagni off`

Disable all yagni nudges for this session.

**Display:**
```
yagni disabled for this session.

The Cynic: "Finally. Some peace and quiet. Over-engineer away."
The Supporter: "I'll... I'll be here if you need me. Just watching. From a distance."

To re-enable: /yagni on
```

Set session flag: `middle_out_disabled: true`

---

### `/yagni on`

Re-enable yagni nudges after disabling.

**Display:**
```
yagni re-enabled.

The team is back:
  The Cynic: "I see you've returned to reason."
  The Realist: "Let's keep things focused this time."
  The Supporter: "I never left. I was always here."

Current sensitivity: {{sensitivity}}
```

Clear session flag: `middle_out_disabled: false`

---

### `/yagni principles`

Display YAGNI and KISS principles with examples.

**Display:**
```
┌─────────────────────────────────────────────────────────────┐
│ 🤠 yagni principles                                    │
└─────────────────────────────────────────────────────────────┘

## YAGNI — You Aren't Gonna Need It

Don't build features until they're actually needed.

❌ "Let's add a plugin system in case we need extensibility"
✓ "We'll add plugin support when we have a concrete plugin to build"

Key insight: YAGNI violations don't look wrong — they look smart
and prepared. That's why they're dangerous.


## KISS — Keep It Simple, Stupid

The simplest solution that works is usually the best.

❌ UserController → UserService → UserServiceFactory → UserRepository
✓ UserController → db.users.find(id)

Key insight: Every layer of abstraction is a tax on understanding.
Only pay the tax when the abstraction earns its keep.


## The Questions

Before adding complexity, ask:

1. What's the simplest thing that works?
2. Am I solving today's problem or tomorrow's guess?
3. Would I delete this if requirements changed?
4. Can a new team member understand this in 5 minutes?


## The Characters

Each character watches for specific smells:

| Character | Watches For |
|-----------|-------------|
| The Cynic | Abstraction layers, deep nesting |
| The Executive | Config addiction, enterprise brain |
| The Supporter | Time-based drift |
| The Bro | Over-architected solutions |
| The Minimalist | Dead code, unused features |
| The Realist | Scope creep, task drift |
| The Insecure Dev | Speculative generality |
| The Perfectionist | Premature optimization |
| The Confused | File explosion |


"Optimism is an occupational hazard of programming.
 Feedback is the treatment." — Kent Beck
```

---

## Configuration File Locations

| Scope | Path |
|-------|------|
| Global | `~/.claude/yagni.yaml` |
| Project | `.claude/yagni.local.md` |

Project config overrides global. Use project config for:
- Legitimate patterns (DI frameworks, plugin architectures)
- Adjusted thresholds for monorepos
- Team-specific sensitivity preferences
