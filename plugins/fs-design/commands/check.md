---
name: check
description: Audit files for Terminal Elegance design system compliance. Checks CSS, templates, and documentation for hardcoded values, accessibility issues, and brand consistency.
arguments:
  - name: path
    description: File or directory to check (optional, defaults to common locations)
    required: false
---

# /design-check

Run the design-check skill to audit files for Terminal Elegance design system compliance.

## Execution

1. Load the design-check skill from `skills/design-check/SKILL.md`
2. Execute the skill with the provided path argument (or default scan locations)
3. Generate compliance report

## Arguments

- `path` (optional): Specific file or directory to audit
  - If omitted, scans default locations: `static/css/`, `css/`, `internal/templates/`, `templates/`, `*.md`

## Examples

```
/design-check                           # Scan default locations
/design-check static/css/main.css       # Check specific file
/design-check internal/templates/       # Check directory
```

## Output

Generates a compliance report with:
- Summary of files scanned and violations found
- Violations grouped by file with line numbers
- Severity levels: CRITICAL, ERROR, WARNING, INFO
- Design token quick reference for fixes

This is a report-only command - it does not auto-fix issues.
