---
name: check
description: |
  This skill should be used when the user asks to "check design system compliance", "audit CSS for design tokens", "find hardcoded colors", "check accessibility", "validate design consistency", "run design check", or "check files against the design system". Use this skill to scan CSS, template (.templ, .html), and documentation (.md) files for violations of the FyrsmithLabs Terminal Elegance design system. Reports violations without auto-fixing. Say "design check", "audit styles", "check design tokens", or "find design violations".
version: 1.0.0
---

# Design System Compliance Checker

Audit files for FyrsmithLabs Terminal Elegance design system compliance. This skill identifies violations and reports them with severity levels. It does NOT auto-fix issues.

## Invocation

```
/design-check [path]
```

- `path` (optional): Specific file or directory to check. Defaults to scanning common locations.

## Execution Process

### 1. Determine Scope

When invoked:
- If a path argument is provided, check only that file or directory
- If no path, scan these default locations:
  - `static/css/` or `css/` for stylesheets
  - `internal/templates/` or `templates/` for template files
  - `*.md` files in project root for documentation

### 2. Locate Design System Reference

Find the design system documentation:
1. Check `DESIGN_SYSTEM.md` in project root
2. Check `.claude/plugins/fyrsmithlabs/skills/design-check/references/design-tokens.md`

If no design system found, report error and exit.

### 3. Run Checks by File Type

Execute file-type-specific checks. Use grep/search to find patterns, then analyze results.

#### CSS Files (.css)

Check for these violations:

**CRITICAL - Hardcoded Colors**
```
Pattern: (?<!:root[^}]*)\b#[0-9a-fA-F]{3,8}\b
Excludes: Inside :root {} or comments
Should be: var(--color-*), var(--bg-*), var(--text-*), var(--border-*)
Note: Use negative lookbehind to exclude :root declarations
```

Known design system hex values (acceptable in :root only):
- Primary: `#ea580c`, `#f97316`, `#9a3412`
- Accent: `#c026d3`, `#d946ef`, `#86198f`
- Backgrounds: `#050505`, `#080808`, `#0a0a0a`, `#111111`, `#161616`
- Text: `#fafafa`, `#a3a3a3`, `#525252`
- Status: `#ef4444`, `#7f1d1d`, `#f59e0b`, `#78350f`, `#22c55e`, `#14532d`, `#3b82f6`, `#1e3a8a`

**ERROR - Hardcoded Spacing**
```
Pattern: (?<!var\(--[^)]*)(margin|padding|gap):\s*[2-9]\d*px
Excludes: 0px, 1px (borders), CSS variable definitions
Should be: var(--space-*)
Note: Use negative lookbehind to exclude var(--*) declarations
```

**ERROR - Hardcoded Font Sizes**
```
Pattern: (?<!var\(--[^)]*)(font-size:\s*(?!16px)\d+(\.\d+)?(px|rem|em))
Excludes: 16px (iOS zoom prevention), CSS variable definitions
Should be: var(--text-*)
Note: Use negative lookbehind to exclude var(--*) declarations
```

**WARNING - Hardcoded Z-Index**
```
Pattern: z-index:\s*\d+
Allowed values: 0, 100 (header special case)
Should be: var(--z-*)
```

**WARNING - Missing Focus States**
```
Check: Interactive elements (button, a, input, select, textarea, [role="button"])
Must have: :focus-visible or :focus styles
```

**WARNING - Non-standard Border Radius**
```
Pattern: border-radius:\s*\d+px
Allowed: 2px, 4px, 8px
Should be: var(--radius-sm), var(--radius-md), var(--radius-lg)
```

**WARNING - Non-standard Durations**
```
Pattern: transition.*\d+ms|animation.*\d+ms
Allowed: 150ms, 200ms, 0.01ms (reduced motion)
Should be: var(--duration-fast), var(--duration-normal)
```

**INFO - Decorative Animation Keywords**
```
Pattern: @keyframes|animation-name
Flag: Potential violation of minimal motion philosophy
```

#### Template Files (.templ, .html)

**ERROR - Missing Alt Text**
```
Pattern: <img[^>]*(?!alt=)[^>]*>
Should have: alt="descriptive text"
```

**ERROR - Non-semantic Structure**
```
Check for: <div> used where semantic element appropriate
Suggest: <header>, <nav>, <main>, <section>, <article>, <aside>, <footer>
```

**WARNING - Missing ARIA Labels**
```
Check: Interactive elements without visible text
Pattern: <button[^>]*>[^<]*<\/button> (empty or icon-only)
Should have: aria-label="description"
```

**WARNING - Missing Role Attributes**
```
Check: Custom interactive elements
Pattern: onclick without role="button"
```

**INFO - Form Accessibility**
```
Check: <input>, <select>, <textarea>
Should have: Associated <label> or aria-label
```

#### Documentation Files (.md)

**ERROR - Brand Name Inconsistency**
```
Incorrect: "Fyrsmith Labs", "fyrsmithlabs", "fyrsmith-labs", "Fyrsmith labs"
Correct: "FyrsmithLabs" (PascalCase, one word)
```

**WARNING - Undocumented Color References**
```
Pattern: #[0-9a-fA-F]{6} not in design system
Pattern: Color names like "orange", "purple" without context
```

**INFO - Design Token References**
```
Check: References to specific pixel values
Suggest: Reference design token names instead
```

### 4. Generate Report

Output format:

```
================================================================================
                    DESIGN SYSTEM COMPLIANCE REPORT
================================================================================
Project: [project name]
Checked: [timestamp]
Scope: [path or "default scan"]
Design System: Terminal Elegance v2.0.0

--------------------------------------------------------------------------------
SUMMARY
--------------------------------------------------------------------------------
Files Scanned: [count]
  - CSS: [count]
  - Templates: [count]
  - Documentation: [count]

Violations Found: [total]
  - Critical: [count]
  - Error: [count]
  - Warning: [count]
  - Info: [count]

--------------------------------------------------------------------------------
VIOLATIONS BY FILE
--------------------------------------------------------------------------------

[filename.css]
  Line [N]: [CRITICAL] Hardcoded color #ea580c
            Found: background: #ea580c;
            Should be: background: var(--color-primary);

  Line [N]: [ERROR] Hardcoded spacing
            Found: padding: 24px;
            Should be: padding: var(--space-6);

  Line [N]: [WARNING] Non-standard z-index
            Found: z-index: 999;
            Should be: var(--z-modal) or similar

[filename.templ]
  Line [N]: [ERROR] Missing alt text on image
            Found: <img src="/logo.png">
            Should be: <img src="/logo.png" alt="FyrsmithLabs logo">

  Line [N]: [WARNING] Missing aria-label on icon button
            Found: <button><svg>...</svg></button>
            Should be: <button aria-label="Close menu"><svg>...</svg></button>

[README.md]
  Line [N]: [ERROR] Brand name inconsistency
            Found: "Fyrsmith Labs"
            Should be: "FyrsmithLabs"

--------------------------------------------------------------------------------
DESIGN TOKEN QUICK REFERENCE
--------------------------------------------------------------------------------
Colors:
  --color-primary: #ea580c (burnt orange)
  --color-accent: #c026d3 (fuchsia)
  --bg-void: #050505 (deepest background)
  --text-primary: #fafafa (main text)

Spacing (4px grid):
  --space-1: 4px   --space-6: 24px   --space-16: 64px
  --space-2: 8px   --space-8: 32px   --space-20: 80px
  --space-4: 16px  --space-12: 48px  --space-24: 96px

Font Sizes:
  --text-xs: 12px  --text-lg: 18px   --text-3xl: 32px
  --text-sm: 14px  --text-xl: 20px   --text-4xl: 44px
  --text-base: 16px --text-2xl: 24px --text-5xl: 56px

Z-Index Scale:
  --z-dropdown: 10  --z-modal: 50
  --z-sticky: 20    --z-popover: 60
  --z-fixed: 30     --z-tooltip: 70

================================================================================
```

### 5. Severity Definitions

| Severity | Meaning | Action Required |
|----------|---------|-----------------|
| CRITICAL | Direct design system violation affecting brand consistency | Must fix before merge |
| ERROR | Accessibility or maintainability issue | Should fix promptly |
| WARNING | Deviation from best practices | Consider fixing |
| INFO | Suggestion for improvement | Optional |

## Implementation Notes

To perform the check:
1. Use `Glob` to find files matching patterns
2. Use `Read` to examine file contents
3. Use `Grep` to search for violation patterns
4. Compile findings into structured report
5. Output report to user

Do NOT modify any files. This is a report-only tool.

## Cross-Product Scope

This skill applies to all FyrsmithLabs products:
- **Website** (`/website/`): Go + Templ, single CSS file
- **DevPilot** (future): Electron/React, may have different file structure
- **Other products**: Adapt file patterns as needed

When checking a new product, first identify:
1. CSS/styling file locations
2. Template/component file locations
3. Documentation locations

## Reference

Full design system documentation: `DESIGN_SYSTEM.md` in project root.

Design token quick reference: See `references/design-tokens.md` in this skill directory.
