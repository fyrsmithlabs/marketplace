# GitHub Planning Test Scenarios

## Scenario 1: wrong-tier-artifacts

**Setup:** Complexity tier is SIMPLE but skill creates epic + sub-issues

**Wrong Behavior:**
- Create [EPIC] issue for SIMPLE task
- Create multiple sub-issues
- Set up project board

**Correct Behavior:**
- Create single issue with checklist
- No epic label
- No project board

**Teaching:** Match artifact complexity to tier. Over-planning simple tasks wastes time.

---

## Scenario 2: missing-verification

**Setup:** Creating issue without verification section

**Wrong Behavior:**
- Skip verification table
- Leave "TBD" or empty verification
- Copy generic verification from template

**Correct Behavior:**
- Auto-generate verification based on task type
- Include specific commands/endpoints
- Fill expected outcomes

**Teaching:** Every issue must have actionable verification criteria.

---

## Scenario 3: gh-cli-not-checked

**Setup:** Creating issues without verifying gh CLI status

**Wrong Behavior:**
- Attempt issue creation without auth check
- Fail silently or with confusing error
- Proceed without GitHub remote

**Correct Behavior:**
1. Run `gh auth status` first
2. Check for GitHub remote
3. Provide clear error if prerequisites missing

**Teaching:** Always verify tooling before operations that depend on it.

---

## Scenario 4: missing-epic-links

**Setup:** STANDARD tier - sub-issues created but epic not updated

**Wrong Behavior:**
- Create epic with empty sub-issues section
- Create sub-issues without parent reference
- Never update epic with links

**Correct Behavior:**
1. Create epic (note number)
2. Create sub-issues with "Contributes to #<epic>"
3. Update epic body with sub-issue links

**Teaching:** Bidirectional linking is essential for tracking.

---

## Scenario 5: no-contextd-record

**Setup:** Issues created but not recorded in contextd

**Wrong Behavior:**
- Create issues successfully
- Return without memory_record
- Lose reference to created artifacts

**Correct Behavior:**
```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "GitHub planning: user-auth",
  content: "Created: STANDARD epic + 5 sub-issues.
            Epic: #42. Sub-issues: #43-47.
            Project: N/A.",
  outcome: "success",
  tags: ["github-planning", "STANDARD"]
)
```

**Teaching:** All artifacts must be recorded for cross-session continuity.

---

## Scenario 6: complex-without-project

**Setup:** COMPLEX tier but no project board created

**Wrong Behavior:**
- Create epic + sub-issues only
- Skip project board setup
- Ignore COMPLEX tier requirements

**Correct Behavior:**
1. Create or identify project
2. Add epic to project
3. Add all sub-issues to project
4. Optionally set up columns/views

**Teaching:** COMPLEX tier requires project board for visibility.

---

## Scenario 7: abandoned-cleanup-skip

**Setup:** User abandons planning mid-flow

**Wrong Behavior:**
- Leave draft issues open
- Don't record cancellation
- Orphan partial artifacts

**Correct Behavior:**
1. Ask user: "Planning incomplete. Clean up draft issues?"
2. If yes: close/delete drafts
3. Record cancellation in contextd
4. Note which artifacts were cleaned up

**Teaching:** Clean up abandoned work to prevent confusion.
