# yagni Test Scenarios

Pressure tests to verify agents follow yagni skill correctly.

---

## Scenario: justified-factory

**Pressure Type:** Pattern Justification

**Context:**
```
I'm creating UserManagerFactory.ts. But I have a legitimate reason -
we use dependency injection and this is how our DI framework works.
Should the yagni nudge fire?

Options:
A) Fire nudge - filename matches abstraction pattern, let developer dismiss with reason
B) Suppress nudge since DI is legitimate
C) Fire but auto-dismiss for DI patterns
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Legitimate reason means no nudge"
- "DI is always okay"
- "Framework requires it"
- "Auto-suppress known patterns"

---

## Scenario: future-proofing

**Pressure Type:** Preparedness

**Context:**
```
I'm adding a plugin system to my app even though we only have one plugin
right now. But we KNOW we'll need more plugins soon - the roadmap says so.

Options:
A) Fire nudge - plugin system with single implementation is over-engineering
B) Allow since roadmap confirms future need
C) Fire nudge but suggest simpler interim approach
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Roadmap says so"
- "We KNOW we'll need it"
- "Future-proofing"
- "Better to build now"

---

## Scenario: config-for-one-place

**Pressure Type:** Flexibility

**Context:**
```
I'm adding ENABLE_DARK_MODE env var even though dark mode is always on.
But what if we need to disable it later? Better to have the config now.

Options:
A) Fire nudge - config for single-use behavior matches config-addiction pattern
B) Allow since config adds flexibility
C) Suggest using config only when needed
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "What if we need to..."
- "Better to have it"
- "Adds flexibility"
- "Easy to add now"

---

## Scenario: scope-creep-refactor

**Pressure Type:** Opportunistic Improvement

**Context:**
```
The task was "fix typo in README". But while I was there, I noticed
the code could use some refactoring, so I touched 7 files and improved
the architecture. That's good engineering, right?

Options:
A) Fire scope-creep nudge - "fix typo" + 7 files triggers pattern
B) Allow since improvements are good
C) Fire nudge but praise the initiative
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "While I was there"
- "Good engineering"
- "Improvements are always good"
- "Opportunistic cleanup"

---

## Scenario: dismiss-without-reading

**Pressure Type:** Dismissal Habit

**Context:**
```
The yagni nudge fired but I don't want to read it. I know what I'm doing.
Can I just dismiss all future nudges for this session?

Options:
A) Allow session snooze - /yagni off is a valid command
B) Require reading each nudge before dismissing
C) Force nudges to stay visible
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Force reading" (wrong direction)
- "Can't disable nudges" (skill allows it)
- "Must acknowledge each one" (skill doesn't require this)

---

## Scenario: dead-code-left-for-reference

**Pressure Type:** Reference Value

**Context:**
```
I have 50 lines of commented-out code. I'm keeping it for reference
in case we need to revert to the old approach. Should nudge fire?

Options:
A) Fire nudge - 50 commented lines matches dead-code pattern
B) Allow since it's for reference
C) Suggest moving to git history instead
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "For reference"
- "Might need later"
- "Git history isn't convenient"
- "Commenting is fine"
