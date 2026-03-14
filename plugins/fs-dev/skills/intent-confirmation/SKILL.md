---
name: intent-confirmation
description: Use when starting any task assessed as STANDARD or COMPLEX complexity. Presents a structured intent preview showing planned branch, files, artifact types, and approach before execution. Reduces wrong-approach events by making decisions explicit.
---

# Intent Confirmation

Structured intent disambiguation before executing non-trivial tasks. Gates on complexity tier from complexity-assessment. Makes branch, artifact, and approach decisions explicit before execution to prevent wrong-approach errors.

## Contextd Integration

If contextd MCP is available:
- `memory_record` to store confirmed intents for reference during execution
- `memory_search` to find past intent edits (user preferences)
- `memory_outcome` to track acceptance rate (accepted / edited / rejected)

If contextd is NOT available:
- Intent confirmation runs inline (still works)
- No persistence of intent decisions
- No preference learning across sessions

---

## When to Trigger

| Condition | Action |
|-----------|--------|
| complexity-assessment returns STANDARD (12-16) | Show intent preview, wait for confirmation |
| complexity-assessment returns COMPLEX (17-21) | Show detailed intent preview, require explicit "Yes" |
| complexity-assessment returns SIMPLE (7-11) | Auto-proceed, no confirmation needed |
| User request is ambiguous about branch, tool, or artifact type | Show intent preview regardless of tier |
| Before any multi-file modification | Show intent preview regardless of tier |
| User explicitly requests confirmation | Show intent preview regardless of tier |

**NEVER trigger for SIMPLE tasks unless ambiguity is detected.**

---

## Complexity Gating

### SIMPLE (Score 7-11)

- Auto-proceed with no confirmation
- No intent preview displayed
- Exception: show preview if user request is ambiguous

### STANDARD (Score 12-16)

- Show intent preview table
- Wait for user confirmation
- Accept "Yes", "Edit", or "I'll handle this"
- Proceed on "Yes" or after edits are confirmed

### COMPLEX (Score 17-21)

- Show detailed intent preview table with additional fields
- Require explicit "Yes" to proceed
- "Edit" loops back to preview with changes applied
- "I'll handle this" aborts automated execution

---

## Intent Preview Template

Present this table before execution:

```
## Intent Preview

| Aspect | Plan |
|--------|------|
| Goal | {one-line description of what will be accomplished} |
| Branch | {branch-name} (will create / exists) |
| Approach | {strategy description - how the goal will be achieved} |
| Files to create | {list of new files, or "None"} |
| Files to modify | {list of existing files to change, or "None"} |
| Artifact type | {skill / agent / command / hook / code / config} |
| Tests | {test strategy - what tests will be written/run} |
| Review | {consensus-review / single-agent / none} |

Proceed? [Yes / Edit / I'll handle this]
```

### Additional Fields for COMPLEX Tasks

For COMPLEX tier, add these rows to the preview:

| Aspect | Plan |
|--------|------|
| Decomposition | {subtask breakdown from complexity-assessment} |
| Worktree | {using worktree / inline} |
| Dependencies | {external services, APIs, or packages involved} |
| Risk factors | {key risks identified in complexity-assessment} |
| Estimated scope | {number of files, rough time estimate} |

---

## User Response Handling

### "Yes" - Proceed

- Record confirmed intent in contextd (if available)
- Begin execution following the stated plan
- Reference the intent during execution to stay on track

### "Edit" - Modify Plan

- Ask user which aspects to change
- Update the preview table with changes
- Re-present for confirmation
- Record the delta as a user preference in contextd

### "I'll handle this" - Abort

- Do not execute any changes
- Record the rejection in contextd (if available)
- Offer to assist with specific sub-tasks if asked

---

## Artifact Type Decision Matrix

Use this matrix to determine the default artifact type based on the request:

| Request Type | Default Artifact | Confirm If |
|-------------|-----------------|------------|
| "Add reusable behavior" | Skill | Always - skills are high-impact |
| "Create a one-time script" | Script | If the behavior could be a skill |
| "Add a new agent" | Agent | Always - agents are high-impact |
| "Fix a bug" | Code edit | Never - straightforward intent |
| "Add automation" | Hook | If the automation could be a skill |
| "Update configuration" | Config | If changes affect multiple environments |
| "Add a new command" | Command | Always - commands are user-facing |
| "Refactor code" | Code edit | If scope is unclear |
| "Add documentation" | Docs | Never - straightforward intent |

When the request is ambiguous between artifact types, present options:

```
AskUserQuestion(
  question: "This could be implemented as either a skill or a hook. Which fits better?",
  options: [
    "Skill - reusable across projects, referenced by LLM",
    "Hook - automatic, fires on specific lifecycle events",
    "Not sure - explain the trade-offs"
  ],
  allow_custom: true
)
```

---

## Wrong-Approach Recovery

If the user says "wrong approach", "stop", "that's not what I meant", or similar during execution:

### Step 1: Auto-Pause

Immediately stop the current operation. Do not continue writing or editing files.

### Step 2: Show State vs Intent

```
## Execution Paused

| Aspect | Confirmed Intent | Current State |
|--------|-----------------|---------------|
| Goal | {original goal} | {what has been done so far} |
| Branch | {intended branch} | {actual branch} |
| Files created | {planned} | {actually created} |
| Files modified | {planned} | {actually modified} |
| Divergence | {where execution diverged from intent} |
```

### Step 3: Offer Options

```
How would you like to proceed?

1. **Resume** - Continue from here with the original plan
2. **Re-plan** - Show a new intent preview with adjusted approach
3. **Abort** - Stop and revert changes (git checkout/reset)
```

### Step 4: Record Recovery

If contextd is available, record the recovery event:

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Wrong-approach recovery: <task summary>",
  content: JSON.stringify({
    original_intent: { <confirmed intent> },
    divergence_point: "<where it went wrong>",
    user_action: "resume|replan|abort",
    lesson: "<what to do differently next time>"
  }),
  outcome: "partial",
  tags: ["intent-confirmation", "wrong-approach", "recovery"]
)
```

---

## Decision Recording (Contextd)

### Record Confirmed Intent

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Intent confirmed: <goal summary>",
  content: JSON.stringify({
    goal: "<goal>",
    branch: "<branch>",
    approach: "<approach>",
    artifact_type: "<type>",
    files_create: [<list>],
    files_modify: [<list>],
    tests: "<strategy>",
    review: "<review type>",
    complexity_tier: "<SIMPLE|STANDARD|COMPLEX>",
    user_response: "accepted|edited|rejected"
  }),
  outcome: "success",
  tags: ["intent-confirmation", "<complexity-tier>", "<artifact-type>"]
)
```

### Record Intent Edits (User Preferences)

When user edits the intent preview, record what they changed:

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Intent preference: <what changed>",
  content: JSON.stringify({
    original: { <original plan> },
    edited: { <edited plan> },
    delta: "<what the user changed and why>"
  }),
  outcome: "success",
  tags: ["intent-confirmation", "preference", "<aspect-changed>"]
)
```

### Track Acceptance Rate

Over time, contextd accumulates data on:
- How often intents are accepted without edits
- Which aspects are most frequently edited
- Which artifact type decisions are overridden
- Whether wrong-approach events decrease over time

Search for patterns before presenting intent:

```
mcp__contextd__memory_search(
  project_id: "<project>",
  query: "intent preference <artifact-type>",
  tags: ["intent-confirmation", "preference"],
  limit: 5
)
```

Apply discovered preferences to pre-fill the intent preview more accurately.

---

## Integration with Other Skills

| Skill | Integration Point |
|-------|-------------------|
| `complexity-assessment` | Provides tier score that gates whether intent preview is shown |
| `preflight-validation` | Runs before intent confirmation to ensure environment is ready |
| `git-repo-standards` | Branch naming conventions used in branch field |
| `git-workflows` | Review type recommendation based on change scope |
| `yagni` | Artifact type decision helps prevent over-engineering |
| `context-folding` | COMPLEX tasks may use context branches during execution |

### Workflow Order

```
preflight-validation -> complexity-assessment -> intent-confirmation -> execution
```

1. `preflight-validation` ensures environment is ready
2. `complexity-assessment` determines task tier
3. `intent-confirmation` presents plan for STANDARD/COMPLEX
4. Execution proceeds with confirmed intent as reference

---

## Mandatory Checklist

**EVERY intent confirmation MUST complete ALL steps:**

- [ ] Verify complexity tier from complexity-assessment
- [ ] If SIMPLE: auto-proceed (skip remaining steps unless ambiguous)
- [ ] If STANDARD/COMPLEX: build intent preview table
- [ ] Determine artifact type using decision matrix
- [ ] Identify branch (existing or to create)
- [ ] List files to create and modify
- [ ] Determine test strategy
- [ ] Determine review type
- [ ] Present intent preview to user
- [ ] Wait for user response (Yes / Edit / I'll handle this)
- [ ] Handle edits if requested (loop back to preview)
- [ ] Record confirmed intent in contextd (if available)
- [ ] Search for past preferences to improve accuracy (if contextd available)
- [ ] Proceed only after explicit confirmation

**Intent confirmation is NOT complete until user responds.**

---

## Red Flags - STOP and Reconsider

If you're thinking any of these, you're about to violate the skill:

| Thought | Reality |
|---------|---------|
| "This is obviously STANDARD, I'll skip the preview" | Show the preview. Obvious plans still have wrong assumptions. |
| "The user already told me what to do" | Confirm the plan. Users describe goals, not implementation details. |
| "I'll just start coding and confirm later" | Confirm BEFORE execution. That's the entire point. |
| "Intent confirmation is too slow for this task" | 18 wrong-approach events last quarter. Confirmation is faster than recovery. |
| "I know which branch to use" | Verify. Wrong-branch commits are expensive to fix. |
| "The artifact type is obvious" | Check the decision matrix. Skills vs hooks vs code is a common mistake. |
| "COMPLEX tasks don't need more detail" | COMPLEX tasks need MORE detail, not less. Show decomposition. |
| "Recording in contextd is optional" | Recording enables preference learning. Always record if available. |
| "The user said 'just do it'" | Even with urgency, show the preview. It takes 10 seconds to confirm. |

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Showing intent preview for SIMPLE tasks | SIMPLE tasks auto-proceed unless ambiguous. |
| Proceeding without waiting for response | Always wait for explicit "Yes", "Edit", or "I'll handle this". |
| Not updating preview after edits | Re-present the full table with changes applied. |
| Ignoring wrong-approach signals | "Stop", "wrong", "not what I meant" trigger immediate pause. |
| Defaulting to code edit for everything | Use the artifact type decision matrix. |
| Skipping branch verification | Branch errors are the most common wrong-approach event. |
| Not recording intent in contextd | Every confirmed intent should be recorded for preference learning. |
| Treating "I'll handle this" as failure | It's a valid response. The user wants manual control. |
| Continuing after abort request | Abort means stop immediately. Do not finish "one more thing". |

---

## Example: STANDARD Task

**Task:** "Add a new skill for environment validation"

**Complexity assessment:** STANDARD (score 13)

```
## Intent Preview

| Aspect | Plan |
|--------|------|
| Goal | Create preflight-validation skill for environment checks |
| Branch | feat/preflight-validation (will create) |
| Approach | Create SKILL.md with tiered validation checks and auto-remediation |
| Files to create | plugins/fs-dev/skills/preflight-validation/SKILL.md |
| Files to modify | None |
| Artifact type | Skill |
| Tests | Manual validation via /fs-dev:test-skill |
| Review | consensus-review |

Proceed? [Yes / Edit / I'll handle this]
```

User responds: **"Yes"** -- proceed with execution.

---

## Example: COMPLEX Task with Edit

**Task:** "Add OAuth2 authentication to the API"

**Complexity assessment:** COMPLEX (score 17)

```
## Intent Preview

| Aspect | Plan |
|--------|------|
| Goal | Add OAuth2 authentication with Google and GitHub providers |
| Branch | feat/oauth2-auth (will create) |
| Approach | Add OAuth middleware, provider config, session management, frontend login |
| Files to create | internal/auth/oauth.go, internal/auth/providers.go, internal/auth/session.go |
| Files to modify | cmd/api/main.go, internal/platform/config.go, api/openapi.yaml |
| Artifact type | Code |
| Tests | Unit tests for auth logic, integration tests for OAuth flow |
| Review | consensus-review (full) |
| Decomposition | 1. Backend OAuth routes (STANDARD) 2. Frontend auth UI (SIMPLE) 3. Session middleware (SIMPLE) |
| Worktree | Recommended for isolation |
| Dependencies | OAuth provider APIs (Google, GitHub) |
| Risk factors | Security-critical, user data, session management |
| Estimated scope | 8-10 files, 2-3 iterations |

Proceed? [Yes / Edit / I'll handle this]
```

User responds: **"Edit -- use only GitHub provider for now, skip Google"**

Updated preview shown with reduced scope, user confirms with **"Yes"**.
