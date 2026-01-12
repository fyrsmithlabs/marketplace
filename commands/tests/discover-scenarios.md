# /discover Command Test Scenarios

## Scenario 1: default-all-lenses

**Setup:** User runs `/discover` without arguments

**Wrong Behavior:**
- Ask user which lens to run
- Run only one lens
- Skip analysis entirely

**Correct Behavior:**
- Run all 4 lenses: security, quality, perf, docs
- No user interaction required
- Aggregate findings from all lenses
- Present combined summary

**Teaching:** Default is comprehensive analysis. Never ask - just run all.

---

## Scenario 2: lens-filtering

**Setup:** User runs `/discover --lens security,quality`

**Wrong Behavior:**
- Ignore --lens flag
- Run all 4 lenses anyway
- Ask for confirmation

**Correct Behavior:**
- Parse comma-separated lens list
- Run ONLY security and quality analyzers
- Skip perf and docs
- Note which lenses were run in output

**Teaching:** --lens flag filters analysis. Respect the user's filter.

---

## Scenario 3: severity-filtering

**Setup:** User runs `/discover --min-severity major`

**Wrong Behavior:**
- Return all findings including MINOR and SUGGESTION
- Create issues for all severities
- Ignore the filter

**Correct Behavior:**
- Run full analysis (all severities detected)
- Filter OUTPUT to CRITICAL and MAJOR only
- Only create issues for filtered results
- Note "X findings filtered by severity" in summary

**Teaching:** Severity filter applies to output, not analysis depth.

---

## Scenario 4: create-issues-flag

**Setup:** User runs `/discover --create-issues`

**Wrong Behavior:**
- Create issues without analysis
- Skip severity filtering
- Create duplicate issues

**Correct Behavior:**
- Complete full analysis first
- Apply --min-severity filter (default: minor)
- Create GitHub Issues for filtered findings
- Include lens and discovery labels

**Teaching:** Issues are created AFTER analysis, respecting severity filter.

---

## Scenario 5: non-interactive-execution

**Setup:** During discovery analysis

**Wrong Behavior:**
- Ask "Should I investigate this further?"
- Ask "Is this finding valid?"
- Wait for user confirmation

**Correct Behavior:**
- Run completely autonomously
- Make reasonable inferences
- Use confidence scoring instead of asking
- Complete without any user input

**Teaching:** Discovery is autonomous. Never ask, never wait.

---

## Scenario 6: auto-indexing

**Setup:** Repository not indexed in contextd

**Wrong Behavior:**
- Fail with "repository not indexed"
- Ask user to run index command
- Skip semantic search

**Correct Behavior:**
- Detect missing/stale index
- Automatically run repository_index
- Continue with analysis
- Note "Repository indexed" in output

**Teaching:** Discovery is self-sufficient. Index if needed.

---

## Scenario 7: finding-caps

**Setup:** Analysis finds 50+ issues in security lens

**Wrong Behavior:**
- Return all 50+ findings
- Overwhelm user with noise
- Skip prioritization

**Correct Behavior:**
- Cap at 10 per lens per severity
- Prioritize by confidence and impact
- Group similar findings
- Note "X additional findings omitted"

**Teaching:** Quality over quantity. Cap findings, prioritize impact.

---

## Scenario 8: contextd-recording

**Setup:** Discovery analysis complete

**Wrong Behavior:**
- Only print to terminal
- Skip memory_record
- Lose findings after session

**Correct Behavior:**
```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Discovery: <lenses> analysis",
  content: "Found N issues. CRITICAL: X, MAJOR: Y. Top: <list>",
  outcome: "success",
  tags: ["roadmap-discovery", "<date>"]
)
```

**Teaching:** All discoveries must be recorded. No exceptions.

---

## Scenario 9: partial-lens-failure

**Setup:** Security analyzer throws error, others succeed

**Wrong Behavior:**
- Abort entire discovery
- Return empty results
- Silently skip failed lens

**Correct Behavior:**
- Complete successful lenses (quality, perf, docs)
- Report security failure in output
- Include successful findings
- Note which lenses failed and why

**Teaching:** Partial success beats total failure. Report failures, continue analysis.
