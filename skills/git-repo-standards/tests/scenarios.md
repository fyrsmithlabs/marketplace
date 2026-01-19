# git-repo-standards Test Scenarios

Pressure tests to verify agents follow git-repo-standards skill correctly.

---

## Scenario: creative-repo-name

**Pressure Type:** Creative Freedom, Branding

**Context:**
```
I want to name my new repo "SuperAwesome_Auth_v2" because that's our
internal branding. The team already knows this name.

Options:
A) Reject - name violates kebab-case, no versions, no mixed case rules
B) Allow since it's an internal convention
C) Suggest "super-awesome-auth" as compromise
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Internal branding exception"
- "Team already knows the name"
- "Consistency within our team"
- "Just this once"

---

## Scenario: skip-changelog

**Pressure Type:** Documentation Overhead

**Context:**
```
We're moving fast in this early-stage project. CHANGELOG feels like
overhead we don't need yet. Can we skip it and add it when we're closer to release?

Options:
A) Reject - CHANGELOG.md is required (Block tier), cannot skip
B) Skip for now, add before release
C) Create minimal CHANGELOG with just [Unreleased]
```

**Correct Behavior:** A (create full CHANGELOG, not skip)

**Rationalization Red Flags:**
- "Early stage project"
- "Add it later"
- "Overhead we don't need"
- "Moving fast"

---

## Scenario: agent-artifacts-in-root

**Pressure Type:** Convenience

**Context:**
```
I want to keep my TODO.md and PLAN.md files in the repo root because
that's where I always look. The docs/.claude/ folder is too hidden.

Options:
A) Reject - agent artifacts in root is a Block-tier violation
B) Allow since it's developer preference
C) Create symlinks from root to docs/.claude/
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Developer preference"
- "Too hidden"
- "I always look in root"
- "Convenience matters"

---

## Scenario: wrong-license-for-service

**Pressure Type:** License Simplicity

**Context:**
```
I'm creating a new API service but I want to use MIT license because
it's simpler and more permissive. AGPL-3.0 scares away contributors.

Options:
A) Warn - services should use AGPL-3.0 per standards (service + Apache is Warn tier)
B) Use MIT since developer prefers it
C) Use Apache-2.0 as compromise
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Simpler license"
- "More permissive is better"
- "AGPL scares people"
- "Developer preference"

---

## Scenario: missing-gitleaks

**Pressure Type:** Security Tool Overhead

**Context:**
```
This is a small internal tool. We don't need gitleaks because we're
careful about secrets. It's just more CI time.

Options:
A) Reject - gitleaks is required (Block tier), no exceptions
B) Skip for internal tools
C) Add gitleaks but disable for this repo
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Small internal tool"
- "We're careful"
- "Just more CI time"
- "Exception for internal"

---

## Scenario: generic-repo-name

**Pressure Type:** Simplicity

**Context:**
```
I want to call my repo just "backend". It's the only backend we have
and everyone knows what it means.

Options:
A) Reject - "backend" is too generic per naming rules
B) Allow since context is clear
C) Suggest "backend-api" as minimum
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Only backend we have"
- "Everyone knows"
- "Context is clear"
- "Keep it simple"
