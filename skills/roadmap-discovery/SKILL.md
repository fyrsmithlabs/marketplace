---
name: roadmap-discovery
description: Use when analyzing codebase for improvements, running discovery, finding issues, auditing security/quality/performance, identifying tech debt, or scanning for problems. Autonomous non-interactive analysis with lens filtering (security, quality, perf, docs) and severity classification (CRITICAL, MAJOR, MINOR, SUGGESTION).
---

# Roadmap Discovery

Autonomous codebase analysis to identify improvement opportunities without user interaction.

## When to Use

- **Pre-session:** Run before brainstorming for context
- **Onboarding:** Part of `/onboard --discover` flow
- **On-demand:** Via `/discover` command

## Lenses

Filter analysis by concern:

| Lens | Focus Area |
|------|------------|
| `security` | Auth gaps, injection risks, secrets exposure |
| `quality` | Test coverage, complexity, duplication |
| `perf` | N+1 queries, missing indices, unbounded operations |
| `docs` | Missing README sections, outdated comments, API gaps |
| `all` | Run all lenses (default) |

## Severity Framework

Classify findings by impact:

| Severity | Description | Action |
|----------|-------------|--------|
| CRITICAL | Security vulnerabilities, data loss risks | Immediate attention |
| MAJOR | Performance bottlenecks, significant UX issues | High priority |
| MINOR | Code smell, minor gaps | Normal priority |
| SUGGESTION | Nice-to-haves, polish items | Backlog |

## Execution Flow

### 1. Index Repository

```
mcp__contextd__repository_index(
  path: ".",
  exclude_patterns: ["node_modules/**", "vendor/**", ".git/**"]
)
```

### 2. Run Lens Analyzers

**Security:** `Grep: password|secret|api_key|eval\(|exec\(|innerHTML` → Check auth, secrets, injection
**Quality:** `Grep: catch\s*\(\w*\)\s*\{\s*\}` + test file ratio → Check coverage, complexity, error handling
**Perf:** `Grep: for.*SELECT|\.find\(\)(?!.*limit)` → Check N+1, unbounded queries
**Docs:** `Glob: README.md` + section check → Check completeness, API docs

### 3. Aggregate Findings

Combine results across lenses:

```json
{
  "project": {
    "name": "<project>",
    "path": "<path>",
    "analyzed_at": "<timestamp>"
  },
  "summary": {
    "total_findings": <count>,
    "by_severity": {
      "CRITICAL": <count>,
      "MAJOR": <count>,
      "MINOR": <count>,
      "SUGGESTION": <count>
    },
    "by_lens": {
      "security": <count>,
      "quality": <count>,
      "perf": <count>,
      "docs": <count>
    }
  },
  "findings": [
    {
      "id": "find_001",
      "lens": "security",
      "severity": "MAJOR",
      "title": "<short title>",
      "description": "<detailed description>",
      "location": "<file:line or pattern>",
      "recommendation": "<how to fix>",
      "effort": "low|medium|high",
      "references": ["<links to docs/standards>"]
    }
  ]
}
```

### 4. Store in contextd

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Discovery: <lens> analysis",
  content: "Found <total> issues. CRITICAL: <n>, MAJOR: <n>.
            Top findings: <list top 3>.",
  outcome: "success",
  tags: ["roadmap-discovery", "<lens>", "<date>"]
)
```

### 5. Create GitHub Issues (Optional)

If `--create-issues` flag:

For each finding (filtered by min-severity):
```bash
gh issue create \
  --title "[<severity>] <title>" \
  --label "<lens>,discovery" \
  --body "<description + recommendation>"
```

## Integration Points

### With /brainstorm
Run discovery before brainstorming to inform design:
```
1. /discover --lens all
2. Review findings
3. /brainstorm with context
```

### With /onboard
Run discovery during onboarding:
```
/onboard --discover security,quality
```

### Pre-session Hook
Can be configured as SessionStart hook for automatic context.

## Output Options

| Flag | Output |
|------|--------|
| (default) | Summary to terminal |
| `--create-issues` | Create GitHub Issues |
| `--json` | Full JSON output |
| `--contextd-only` | Store only, no terminal output |

## Limitations

- Non-interactive: Cannot ask clarifying questions
- Pattern-based: May have false positives
- Point-in-time: Reflects current state only

## Attribution

Adapted from Auto-Claude roadmap_discovery and ideation agents.
See CREDITS.md for full attribution.

---

## Pre-Flight (MANDATORY)

**BEFORE running ANY analysis:**

```
1. Check repository index freshness:
   - If no index exists: mcp__contextd__repository_index(path: ".")
   - If HEAD changed since last index: re-index
   - Never skip indexing - stale data = stale findings

2. mcp__contextd__memory_search(
     project_id: "<project>",
     query: "discovery analysis <date>"
   )
   → Load recent discovery results to avoid duplicate work

3. Determine lenses:
   - Default: all (run security, quality, perf, docs)
   - If --lens specified: parse comma-separated list
   - NEVER ask user which lens - use default or argument

4. Set finding caps:
   - Max 10 findings per lens per severity
   - Prioritize by confidence and impact
```

**Do NOT ask the user any questions during discovery. This is autonomous analysis.**

---

## Mandatory Checklist

**EVERY discovery invocation MUST complete ALL steps:**

### Analysis Phase:
- [ ] Complete pre-flight (index check, memory search)
- [ ] Run ALL specified lenses (default: all 4)
- [ ] For each lens, execute analysis (see Run Lens Analyzers section)
- [ ] Apply severity classification to each finding
- [ ] Apply confidence scoring

### Quality Control:
- [ ] Cap findings (max 10 per lens per severity)
- [ ] Group similar findings
- [ ] Remove duplicates
- [ ] Sort by severity then confidence

### Output Phase:
- [ ] Generate summary with counts by severity and lens
- [ ] List top findings (max 10 total)
- [ ] If --create-issues: create GitHub Issues (respecting --min-severity)
- [ ] **RECORD to contextd** (see Storage section)

### Error Handling:
- [ ] If a lens fails, continue with other lenses
- [ ] Report partial success with failure details
- [ ] Never fail entire discovery for one lens error

**Discovery is NOT complete until contextd recording is done.**

---

## Autonomy Requirements (Critical)

**Discovery is 100% non-interactive. NEVER:**

- Ask "Which lens should I analyze?"
- Ask "Should I create issues for this?"
- Ask "Is this finding valid?"
- Wait for user confirmation
- Request clarification on severity

**ALWAYS:**

- Make reasonable inferences based on patterns
- Use confidence scores instead of asking
- Run with defaults if no arguments provided
- Complete fully without user input
- Record ALL findings (contextd stores everything)

**If you catch yourself about to ask a question: STOP. Make a decision and document it.**

---

## Red Flags - STOP and Reconsider

If you're thinking any of these, you're about to violate the skill:

| Thought | Reality |
|---------|---------|
| "Which lens should I run?" | Default is ALL. Run all 4 lenses. |
| "Should I ask about this finding?" | No. Use confidence scoring, not questions. |
| "Repository isn't indexed" | Index it yourself. mcp__contextd__repository_index. |
| "There are 100+ findings" | Cap at 10 per lens per severity. Quality > quantity. |
| "This lens failed, abort" | Continue other lenses. Partial success is valid. |
| "I'll skip contextd, just terminal output" | contextd recording is MANDATORY. |
| "User didn't specify lens" | Default = all. Don't ask. |
| "Not sure about severity" | Make your best judgment. Document rationale. |

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|------------------|
| Asking user which lens to run | Default is ALL. Use --lens argument if specified. |
| Failing when repo not indexed | Auto-index with repository_index before analysis. |
| Returning 100+ findings | Cap at 10 per lens per severity. Prioritize by impact. |
| Aborting on lens failure | Continue with working lenses. Report partial success. |
| Skipping contextd | memory_record is mandatory for every discovery run. |
| Waiting for user input | Discovery is autonomous. Make decisions, document them. |
| Using stale index | Check if HEAD changed. Re-index if needed. |
| Treating all findings equally | Apply severity AND confidence scoring. |

---

## Self-Sufficiency Protocol

**Discovery must handle its own prerequisites:**

### Missing Index
```
IF mcp__contextd__semantic_search returns no results:
  mcp__contextd__repository_index(
    path: ".",
    exclude_patterns: ["node_modules/**", "vendor/**", ".git/**", "dist/**"]
  )
  THEN proceed with analysis
```

### Stale Index
```
IF git log -1 --format=%H != last_indexed_commit:
  mcp__contextd__repository_index(path: ".")
  THEN proceed with analysis
```

### Partial Lens Failure
```
IF security_analyzer throws error:
  record error in findings: "Security analysis failed: <reason>"
  continue with quality, perf, docs analyzers
  include partial results in output
  note failure in summary
```

---

## Confidence Scoring

**Apply confidence to each finding:**

| Confidence | Meaning | Action |
|------------|---------|--------|
| HIGH (0.8-1.0) | Pattern clearly matches, minimal false positive risk | Include in top findings |
| MEDIUM (0.5-0.79) | Likely issue, but context matters | Include with caveat |
| LOW (0.2-0.49) | Possible issue, may be false positive | Include only if CRITICAL severity |
| VERY LOW (<0.2) | Likely false positive | Exclude from output |

**When in doubt about severity or confidence: bias toward including the finding with documented uncertainty rather than asking the user.**

---

## Finding Caps (Quality Control)

**Maximum findings per category:**

| Level | Cap | Rationale |
|-------|-----|-----------|
| Per lens, per severity | 10 | Prevents flood of minor issues |
| Total per lens | 25 | Focus on most impactful |
| Total output | 50 | Actionable, not overwhelming |
| Top findings summary | 10 | User can digest quickly |

**Prioritization order:**
1. Severity (CRITICAL > MAJOR > MINOR > SUGGESTION)
2. Confidence (HIGH > MEDIUM > LOW)
3. Effort (LOW > MEDIUM > HIGH for same severity)

**If over cap: drop lowest priority items, note "N additional findings omitted"**
