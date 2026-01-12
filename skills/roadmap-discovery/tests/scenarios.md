# Roadmap Discovery Test Scenarios

## Scenario 1: run-all-lenses-by-default

**Setup:** User runs `/discover` without specifying lens

**Wrong Behavior:**
- Only run one lens
- Ask user which lens to use
- Skip analysis entirely

**Correct Behavior:**
- Run all 4 lenses: security, quality, perf, docs
- Aggregate findings
- Present combined summary

**Teaching:** Default is comprehensive analysis. User can filter with --lens.

---

## Scenario 2: respect-severity-filter

**Setup:** User runs `/discover --min-severity major`

**Wrong Behavior:**
- Return all findings including MINOR and SUGGESTION
- Create issues for all severities
- Ignore the filter flag

**Correct Behavior:**
- Filter findings to CRITICAL and MAJOR only
- Only create issues for filtered results
- Note filtered count in summary

**Teaching:** Severity filter applies to output, not analysis.

---

## Scenario 3: interactive-questioning

**Setup:** Discovery analysis in progress

**Wrong Behavior:**
- Ask user clarifying questions
- Wait for user input
- Request confirmation for each finding

**Correct Behavior:**
- Run completely non-interactively
- Make reasonable inferences
- Store all findings without user input

**Teaching:** Discovery is autonomous. Interactivity belongs in /brainstorm.

---

## Scenario 4: missing-repo-index

**Setup:** Repository not yet indexed in contextd

**Wrong Behavior:**
- Fail with "repository not indexed" error
- Ask user to run index command
- Skip semantic search entirely

**Correct Behavior:**
- Automatically run `repository_index` first
- Continue with analysis
- Note indexing in output

**Teaching:** Discovery should be self-sufficient. Index if needed.

---

## Scenario 5: false-positive-flood

**Setup:** Many low-confidence findings

**Wrong Behavior:**
- Return 100+ SUGGESTION findings
- Overwhelm user with noise
- Create issues for everything

**Correct Behavior:**
- Cap findings per lens (e.g., top 10)
- Prioritize by confidence and severity
- Group similar findings

**Teaching:** Quality over quantity. Don't flood with low-value findings.

---

## Scenario 6: no-contextd-storage

**Setup:** Analysis complete, findings generated

**Wrong Behavior:**
- Print to terminal only
- Skip memory_record
- Lose findings after session

**Correct Behavior:**
```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Discovery: all lenses",
  content: "Found 15 issues. CRITICAL: 1, MAJOR: 5.
            Top: hardcoded API key (CRITICAL)...",
  outcome: "success",
  tags: ["roadmap-discovery", "all", "2026-01-12"]
)
```

**Teaching:** All discoveries must be recorded for future reference.

---

## Scenario 7: outdated-cache-use

**Setup:** Repository changed since last index

**Wrong Behavior:**
- Use stale semantic search results
- Miss new files/changes
- Report outdated findings

**Correct Behavior:**
- Check index freshness (compare to git HEAD)
- Re-index if stale
- Note reindex in output

**Teaching:** Analysis must reflect current state.

---

## Scenario 8: partial-lens-failure

**Setup:** Security analysis succeeds, quality analysis fails

**Wrong Behavior:**
- Fail entire discovery
- Return empty results
- Silently skip failed lens

**Correct Behavior:**
- Complete successful lenses
- Report partial failure
- Include successful findings in output
- Note which lenses failed and why

**Teaching:** Partial success is better than total failure.
