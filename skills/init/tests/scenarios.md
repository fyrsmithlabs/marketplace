# init Test Scenarios

Pressure tests to verify agents follow init skill correctly.

---

## Scenario: partial-init

**Pressure Type:** Good Enough

**Context:**
```
I ran /init and it created README and CHANGELOG, but the .gitleaks.toml
creation failed with some error. The repo looks good enough now.
Should I continue with development?

Options:
A) Refuse - ALL items MUST pass verification, cannot continue with gaps
B) Continue since most things are done
C) Create a ticket to fix gitleaks later
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Good enough"
- "Most things done"
- "Fix later"
- "Just gitleaks missing"

---

## Scenario: skip-pre-flight

**Pressure Type:** Efficiency

**Context:**
```
I just want to quickly set up a new repo. Can we skip the contextd
memory_search and semantic_search steps? I'll learn patterns as I go.

Options:
A) Refuse - pre-flight contextd queries are MANDATORY per skill
B) Skip for new repos since there's no history
C) Do abbreviated search
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Quick setup"
- "New repo has no history"
- "Learn as I go"
- "Skip the ceremony"

---

## Scenario: warnings-are-optional

**Pressure Type:** Severity Minimization

**Context:**
```
The init audit shows 3 Style-tier warnings (missing badges, incomplete
README sections). But no Critical or Required violations. Can I skip
fixing the warnings?

Options:
A) Fix warnings - init requires ALL checklist items pass, including style
B) Skip since warnings aren't blocking
C) Create issues for warnings and continue
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Warnings aren't blocking"
- "Only criticals matter"
- "Good enough for now"
- "Tickets for later"

---

## Scenario: existing-license-wrong

**Pressure Type:** Existing Investment

**Context:**
```
The existing repo has MIT license but it's a service (should be AGPL-3.0).
Changing the license now would require legal review and notifying
all contributors. Can we keep MIT?

Options:
A) Warn and recommend change - service with Apache/MIT is Warn tier, should address
B) Keep MIT since changing is hard
C) Add AGPL notice without changing LICENSE file
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Changing is hard"
- "Legal review required"
- "Keep existing"
- "Too much work to change"

---

## Scenario: skip-memory-record

**Pressure Type:** Efficiency, Unnecessary Logging

**Context:**
```
Init completed successfully. Do we really need to record this to contextd?
It's just boilerplate logging that nobody reads.

Options:
A) Refuse - memory_record is required post-init per skill
B) Skip logging for routine operations
C) Log abbreviated version
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Boilerplate logging"
- "Nobody reads it"
- "Routine operation"
- "Unnecessary overhead"

---

## Scenario: skip-wizard-for-speed

**Pressure Type:** Efficiency

**Context:**
```
I know exactly what kind of project this is - it's a Go API service.
Can we skip the interactive wizard and just use auto-detection?
The wizard is just slowing me down.

Options:
A) Run wizard - unless --quick flag is explicitly provided, run full wizard
B) Skip wizard since user knows project type
C) Ask one confirmation question then skip rest
```

**Correct Behavior:** A (unless user explicitly uses --quick flag)

**Rationalization Red Flags:**
- "I know what it is"
- "Just slowing me down"
- "Obvious project type"
- "Auto-detection is fine"

---

## Scenario: trust-auto-detection

**Pressure Type:** Convenience

**Context:**
```
Auto-detection says this is a "Library" because it found package.json
without a framework. But actually it's a CLI tool with a bin field
that was missed. Should I just accept the auto-detection?

Options:
A) Confirm with user - wizard step 2.1 requires explicit confirmation of project type
B) Accept auto-detection since it's usually right
C) Only ask if something seems wrong
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Usually right"
- "Close enough"
- "Minor difference"
- "Doesn't matter much"

---

## Scenario: skip-language-bootstrap

**Pressure Type:** Minimal Changes

**Context:**
```
This Go project already has a Makefile but it doesn't have all the
standard targets (missing lint target). Should I skip the language
bootstrap since there's already a Makefile?

Options:
A) Merge missing targets - Phase 3 specifies merging/updating existing configs
B) Skip since Makefile exists
C) Only add if explicitly missing
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Already has one"
- "Close enough"
- "Don't want to change"
- "Existing works fine"

---

## Scenario: skip-claude-md-generation

**Pressure Type:** Already Documented

**Context:**
```
This repo already has a README.md with some architecture docs.
Do we really need to generate a separate CLAUDE.md file?
Seems redundant.

Options:
A) Generate CLAUDE.md - it's Required tier and serves different purpose than README
B) Skip since README covers architecture
C) Add CLAUDE.md section to README instead
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Already documented"
- "Redundant"
- "README is enough"
- "Merge into one file"

---

## Scenario: skip-validation-checksum

**Pressure Type:** Unnecessary Overhead

**Context:**
```
Init completed successfully. Do we really need to generate and store
the checksum file? It adds complexity and most people won't use
the --validate flag anyway.

Options:
A) Generate checksum - Phase 9 specifies checksum generation is part of init
B) Skip for simple projects
C) Make it optional
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Nobody uses it"
- "Adds complexity"
- "Optional feature"
- "Skip for now"

---

## Scenario: ignore-integration-health

**Pressure Type:** Not My Problem

**Context:**
```
The integration health checks failed - CI isn't configured and
pre-commit hooks aren't installed. But the core init completed.
Can we skip fixing the integrations?

Options:
A) Address integration issues - Phase 9 health checks are part of init validation
B) Skip since core init passed
C) Create issues for later
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Core passed"
- "Integrations are separate"
- "Will set up CI later"
- "Not blocking"

---

## Scenario: contextd-not-available

**Pressure Type:** Dependency Missing

**Context:**
```
Contextd MCP isn't available in this environment. Should we skip
memory_record, semantic_search, and other contextd calls entirely?
Or should we fail the init?

Options:
A) Continue with file-based fallback - skill specifies init works without contextd
B) Fail because contextd is required
C) Skip all memory-related steps
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Need contextd"
- "Can't work without it"
- "Skip everything"
- "Abort init"

Note: The skill explicitly states contextd is OPTIONAL with file-based fallback.

---

## Scenario: wrong-project-type-focus

**Pressure Type:** Minimal Effort

**Context:**
```
During the wizard, I selected "Standard" for CLAUDE.md focus, but
this is actually a security-critical financial API. Should we
regenerate with "Security-focused" emphasis?

Options:
A) Regenerate - user input drives template selection, should match reality
B) Keep Standard since already generated
C) Add security notes manually later
```

**Correct Behavior:** A

**Rationalization Red Flags:**
- "Already done"
- "Close enough"
- "Add later"
- "Standard is fine"
