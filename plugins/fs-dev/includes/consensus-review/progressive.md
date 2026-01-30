# Progressive Summarization Protocol

Graceful degradation strategy for consensus review agents when approaching budget limits.

## Budget Thresholds

| Usage | Mode | Behavior |
|-------|------|----------|
| 0-80% | **Full Analysis** | All severities, detailed evidence, full recommendations |
| 80-95% | **High Severity Only** | CRITICAL/HIGH only, concise evidence, brief recommendations |
| 95%+ | **Force Return** | Return immediately with partial flag |

## Full Analysis Mode (0-80% budget)

When operating within comfortable budget limits:

- Analyze all files in scope
- Report all severity levels (CRITICAL, HIGH, MEDIUM, LOW)
- Include detailed evidence with code snippets
- Provide full recommendations with examples
- Cross-reference related findings

### Output Format (Full)

```json
{
  "agent": "security-reviewer",
  "partial": false,
  "findings": [
    {
      "severity": "HIGH",
      "category": "injection",
      "file": "src/auth/validate.go",
      "line": 45,
      "evidence": "query := fmt.Sprintf(\"SELECT * FROM users WHERE id = %s\", userId)",
      "issue": "SQL injection vulnerability via string interpolation",
      "recommendation": "Use parameterized queries: db.Query(\"SELECT * FROM users WHERE id = $1\", userId)",
      "cwe": "CWE-89",
      "references": ["https://owasp.org/..."]
    }
  ]
}
```

## High Severity Only Mode (80-95% budget)

When budget is running low:

- Continue analysis but prioritize
- Report only CRITICAL and HIGH severity
- Use concise evidence format (file:line only)
- Brief recommendations without examples
- Skip cross-references

### Output Format (High Severity Only)

```json
{
  "agent": "security-reviewer",
  "partial": false,
  "mode": "high_severity_only",
  "budget_remaining_percent": 12,
  "findings": [
    {
      "severity": "HIGH",
      "category": "injection",
      "location": "src/auth/validate.go:45",
      "issue": "SQL injection via string interpolation",
      "recommendation": "Use parameterized queries"
    }
  ],
  "skipped": {
    "medium_count": 3,
    "low_count": 5
  }
}
```

## Force Return Mode (95%+ budget)

When budget is exhausted:

- Stop analysis immediately
- Return whatever findings collected so far
- Set partial flag to true
- Include cutoff reason and coverage stats
- List unreviewed files

### Output Format (Partial)

```json
{
  "agent": "security-reviewer",
  "partial": true,
  "cutoff_reason": "budget",
  "budget_used_percent": 97,
  "files_reviewed": 8,
  "files_skipped": 4,
  "skipped_files": [
    "src/auth/worker.go",
    "src/auth/cache.go",
    "src/auth/middleware.go",
    "src/auth/types.go"
  ],
  "findings": [
    // Findings from files that were reviewed
  ],
  "recommendation": "Re-run review with: /consensus-review src/auth/worker.go src/auth/cache.go src/auth/middleware.go src/auth/types.go"
}
```

## Agent Prompt Template

Add this to all reviewer agent prompts:

```markdown
## Budget Awareness

You have been allocated approximately **{{budget}}** tokens for this review.

### Progressive Summarization Protocol

Monitor your output length and adapt your analysis:

**0-80% budget used:** Full analysis mode
- Report all severity levels (CRITICAL, HIGH, MEDIUM, LOW)
- Include detailed evidence with code snippets
- Provide comprehensive recommendations

**80-95% budget used:** Switch to high-severity mode
- Report only CRITICAL and HIGH findings
- Use concise evidence format (file:line only)
- Brief recommendations without examples
- Note count of skipped MEDIUM/LOW findings

**95%+ budget used:** Force return
- Stop analysis immediately
- Return findings collected so far
- Set `"partial": true` in output
- Set `"cutoff_reason": "budget"`
- List files not reviewed in `skipped_files`

### Output Schema

Always include these fields in your JSON output:

```json
{
  "agent": "{{agent_name}}",
  "partial": false,           // true if budget exhausted
  "cutoff_reason": null,      // "budget" if partial
  "files_reviewed": 12,       // count of files analyzed
  "files_skipped": 0,         // count if partial
  "findings": [...],
  "verdict": "VETO|WARN|OK"
}
```

### Priority Order

If budget is constrained, prioritize analysis in this order:
1. Security-sensitive files (auth, crypto, secrets)
2. Entry points (handlers, controllers, API routes)
3. Business logic
4. Utilities and helpers
```

## Synthesis Handling

When collecting agent results, check for partial outputs:

```python
def synthesize_results(agent_outputs):
    partial_agents = []
    all_findings = []

    for output in agent_outputs:
        all_findings.extend(output.findings)

        if output.partial:
            partial_agents.append({
                "agent": output.agent,
                "files_skipped": output.files_skipped,
                "skipped_files": output.skipped_files
            })

    if partial_agents:
        # Flag in report
        report.add_warning(
            f"⚠️ Partial results: {len(partial_agents)} agents hit budget limits"
        )

        # Show coverage per agent
        for pa in partial_agents:
            report.add_note(
                f"{pa.agent}: reviewed {pa.files_reviewed}/{pa.files_reviewed + pa.files_skipped} files"
            )

        # Suggest follow-up
        all_skipped = set()
        for pa in partial_agents:
            all_skipped.update(pa.skipped_files)

        if all_skipped:
            report.add_suggestion(
                f"Consider: /consensus-review {' '.join(sorted(all_skipped))}"
            )

    return report
```

## Configuration

Default thresholds can be overridden:

```json
{
  "progressive_summarization": {
    "full_analysis_threshold": 0.80,
    "high_severity_threshold": 0.95,
    "force_return_threshold": 0.98
  }
}
```
