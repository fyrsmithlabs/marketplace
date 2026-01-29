---
name: check
description: |
  This skill should be used when the user asks to "check design system compliance", "audit CSS for design tokens", "find hardcoded colors", "check accessibility", "validate design consistency", "run design check", "check files against the design system", "validate WCAG compliance", "check a11y", "audit dark mode", or "validate design tokens". Use this skill to scan CSS, template (.templ, .html), and documentation (.md) files for violations of the FyrsmithLabs Terminal Elegance design system. Supports WCAG 2.2 compliance, W3C Design Tokens (DTCG format), and modern CSS patterns. Reports violations with auto-fix suggestions for simple issues. Say "design check", "audit styles", "check design tokens", "a11y audit", or "find design violations".
version: 2.0.0
---

# Design System Compliance Checker

Audit files for FyrsmithLabs Terminal Elegance design system compliance. This skill identifies violations, reports them with severity levels, and provides auto-fix suggestions for simple issues.

## Supported Standards

- **W3C Design Tokens Community Group (DTCG)** format (2025.10 specification)
- **WCAG 2.2** Level AA compliance
- **Modern CSS** custom properties and component patterns
- **Terminal Elegance** design system v2.0.0

## Tool Integration

This skill integrates with industry-standard tools for comprehensive validation:

| Tool | Purpose | Integration |
|------|---------|-------------|
| **Stylelint** | CSS linting and rule enforcement | Recommends `stylelint-config-standard` rules |
| **axe-core** | Accessibility testing engine | WCAG 2.2 AA compliance checking |
| **Design Token Validator** | DTCG format validation | W3C Design Tokens spec compliance |

### Recommended Stylelint Rules

When violations are found, suggest these Stylelint rules for CI enforcement:

```json
{
  "rules": {
    "color-no-hex": true,
    "declaration-property-value-disallowed-list": {
      "z-index": ["/^(?!var\\(--z-).*/"],
      "font-size": ["/^(?!var\\(--text-|16px).*/"]
    },
    "custom-property-pattern": "^(color|bg|text|space|z|radius|duration|font)-",
    "selector-pseudo-class-no-unknown": [true, { "ignorePseudoClasses": ["focus-visible"] }]
  }
}
```

### axe-core Integration

For automated accessibility testing, recommend:

```javascript
// axe-core configuration for Terminal Elegance
{
  rules: {
    'color-contrast': { enabled: true },
    'focus-visible': { enabled: true },
    'image-alt': { enabled: true },
    'button-name': { enabled: true },
    'link-name': { enabled: true }
  }
}
```

## Invocation

```
/design-check [path] [--fix-suggestions] [--ci] [--format=json|text]
```

- `path` (optional): Specific file or directory to check. Defaults to scanning common locations.
- `--fix-suggestions`: Include auto-fix code snippets for simple violations
- `--ci`: Output in CI-friendly format (non-zero exit on CRITICAL/ERROR)
- `--format`: Output format (default: text)

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
2. Check `tokens.json` or `design-tokens.json` for DTCG format tokens
3. Check `.claude/plugins/fyrsmithlabs/skills/design-check/references/design-tokens.md`

If no design system found, report error and exit.

### 2a. W3C Design Tokens (DTCG) Validation

If a `tokens.json` file exists, validate against W3C Design Tokens Community Group format (2025.10 specification):

**Token File Structure Validation**
```json
{
  "$schema": "https://design-tokens.github.io/community-group/format/",
  "color": {
    "primary": {
      "$value": "#ea580c",
      "$type": "color",
      "$description": "Primary brand color - burnt orange"
    }
  }
}
```

**DTCG Compliance Checks:**

| Check | Severity | Requirement |
|-------|----------|-------------|
| `$value` property present | ERROR | All tokens must have `$value` |
| `$type` specified | WARNING | Type should be explicit for tooling |
| Valid `$type` values | ERROR | Must be: `color`, `dimension`, `fontFamily`, `fontWeight`, `duration`, `cubicBezier`, `number`, `strokeStyle`, `border`, `transition`, `shadow`, `gradient`, `typography`, `fontStyle` |
| Token naming convention | WARNING | Use kebab-case for token names |
| Hierarchy depth | INFO | Max 4 levels recommended |
| `$description` present | INFO | Helps documentation generation |

**Token Hierarchy Validation:**
```
color/
  primary/       (group)
    base/        (token) -> $value required
    hover/       (token) -> $value required
  accent/        (group)
    base/        (token)
```

**Cross-Platform Token Usage:**
Validate tokens can generate valid output for:
- CSS custom properties
- iOS (Swift/UIKit)
- Android (Kotlin/Compose)
- JavaScript/TypeScript constants

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

**CRITICAL - CSS Custom Properties Audit**
```
Check: All var(--*) references resolve to defined properties
Pattern: var\(--[a-z-]+\) without matching :root definition
Auto-fix: Suggest nearest matching token
```

**ERROR - Dark Mode Support**
```
Check: @media (prefers-color-scheme: dark) or .dark class support
Pattern: Color tokens without dark mode variants
Should have: Both light and dark values defined
```

**WARNING - Component Library Consistency**
```
Check: Repeated patterns that should be componentized
Pattern: Same CSS block (>3 properties) appearing 3+ times
Suggest: Extract to shared component class
```

**WARNING - Modern CSS Compatibility**
```
Check: Browser support for used features
Pattern: Features requiring fallbacks (container queries, :has(), etc.)
Suggest: Add @supports or fallback values
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

### WCAG 2.2 Accessibility Checks (a11y)

These checks ensure WCAG 2.2 Level AA compliance:

#### Color & Contrast

**CRITICAL - Color Contrast (WCAG 1.4.3)**
```
Check: Text color against background color
Normal text: Minimum 4.5:1 contrast ratio
Large text (18px+ or 14px bold): Minimum 3:1 contrast ratio
Tool: Use axe-core or color-contrast npm package
```

**ERROR - Non-Text Contrast (WCAG 1.4.11)**
```
Check: UI components and graphical objects
Minimum: 3:1 contrast ratio against adjacent colors
Applies to: Borders, icons, focus indicators, form controls
```

**WARNING - Focus Indicator Contrast (WCAG 2.4.13 - New in 2.2)**
```
Check: Focus indicators must have 3:1 contrast
Pattern: :focus-visible styles without sufficient contrast
Should have: Visible 2px+ outline or equivalent
```

#### Keyboard & Focus

**CRITICAL - Focus Visible (WCAG 2.4.7)**
```
Check: All interactive elements have visible focus state
Pattern: outline: none without alternative focus style
Auto-fix: Add outline: 2px solid var(--color-primary); outline-offset: 2px;
```

**ERROR - Focus Not Obscured (WCAG 2.4.11 - New in 2.2)**
```
Check: Focused element not hidden by sticky headers/footers
Pattern: position: sticky or position: fixed elements
Should have: Scroll margin or z-index management
```

**ERROR - Target Size (WCAG 2.5.8 - New in 2.2)**
```
Check: Interactive targets minimum 24x24 CSS pixels
Pattern: button, a, input with smaller dimensions
Exceptions: Inline links in text, browser-rendered controls
Auto-fix: min-width: 44px; min-height: 44px; (recommended)
```

#### ARIA & Semantics

**CRITICAL - ARIA Valid Values (WCAG 4.1.2)**
```
Check: aria-* attributes have valid values
Pattern: aria-expanded="yes" (should be "true")
Pattern: aria-level="high" (should be number)
```

**ERROR - ARIA Hidden Focus (WCAG 4.1.2)**
```
Check: Elements with aria-hidden="true" not focusable
Pattern: <div aria-hidden="true"><button>...</button></div>
Auto-fix: Add tabindex="-1" to focusable descendants
```

**WARNING - Redundant ARIA (WCAG 4.1.2)**
```
Check: ARIA roles that duplicate native semantics
Pattern: <button role="button">
Pattern: <nav role="navigation">
Auto-fix: Remove redundant role attribute
```

#### Motion & Animation

**ERROR - Motion Preference (WCAG 2.3.3)**
```
Check: Animations respect prefers-reduced-motion
Pattern: @keyframes or transition without media query check
Should have: @media (prefers-reduced-motion: reduce) { animation: none; }
Auto-fix: Wrap animations in motion preference query
```

### 3a. Terminal Elegance Specific Checks

#### Brand Color Validation

**CRITICAL - Primary Color Context**
```
var(--color-primary) = #ea580c
Usage: CTAs, active states, links, primary actions
Violation: Using accent color for primary actions
```

**ERROR - Background Hierarchy**
```
Layer order (darkest to lightest):
  Void (#050505) < Base (#080808) < Surface (#0a0a0a) < Elevated (#111111) < Overlay (#161616)
Check: Proper z-order layering maintained
```

#### Typography Scale Compliance

**ERROR - Font Size Validation**
```
Allowed: 12px, 14px, 16px, 18px, 20px, 24px, 32px, 44px, 56px
Use: var(--text-xs) through var(--text-5xl)
Violation: 15px, 22px, or other off-scale values
```

#### Spacing System Adherence

**ERROR - 4px Grid Compliance**
```
Allowed: 4, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64, 80, 96 (pixels)
Use: var(--space-1) through var(--space-24)
Violation: 10px, 15px, 18px, or other off-grid values
```

#### Animation/Transition Standards

**WARNING - Duration Values**
```
Allowed: 0ms, 150ms, 200ms, 300ms
Use: var(--duration-instant|fast|normal|slow)
```

**WARNING - Easing Functions**
```
Use: var(--ease-out|ease-in|ease-in-out)
Exception: linear for progress indicators
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

CI Status: [PASS/FAIL] (FAIL if Critical > 0 or Error > 0)

--------------------------------------------------------------------------------
VIOLATIONS BY FILE
--------------------------------------------------------------------------------

[filename.css]
  Line [N]: [CRITICAL] Hardcoded color #ea580c
            Found: background: #ea580c;
            Should be: background: var(--color-primary);
            Auto-fix: Replace #ea580c with var(--color-primary)

  Line [N]: [ERROR] Hardcoded spacing
            Found: padding: 24px;
            Should be: padding: var(--space-6);
            Auto-fix: Replace 24px with var(--space-6)

  Line [N]: [WARNING] Non-standard z-index
            Found: z-index: 999;
            Should be: var(--z-modal) or similar

[filename.templ]
  Line [N]: [ERROR] Missing alt text on image
            Found: <img src="/logo.png">
            Should be: <img src="/logo.png" alt="FyrsmithLabs logo">
            Auto-fix: Add alt="" attribute (fill in description)

  Line [N]: [WARNING] Missing aria-label on icon button
            Found: <button><svg>...</svg></button>
            Should be: <button aria-label="Close menu"><svg>...</svg></button>

[README.md]
  Line [N]: [ERROR] Brand name inconsistency
            Found: "Fyrsmith Labs"
            Should be: "FyrsmithLabs"

--------------------------------------------------------------------------------
AUTO-FIX SUGGESTIONS (--fix-suggestions)
--------------------------------------------------------------------------------
The following violations have auto-fix suggestions available:

1. [filename.css:15] Replace: background: #ea580c;
                     With:    background: var(--color-primary);

2. [filename.css:42] Replace: padding: 24px;
                     With:    padding: var(--space-6);

3. [filename.css:78] Replace: outline: none;
                     With:    outline: 2px solid var(--color-primary);
                              outline-offset: 2px;

To apply: Review each suggestion and update manually, or use Stylelint --fix

--------------------------------------------------------------------------------
CI PIPELINE INTEGRATION
--------------------------------------------------------------------------------
Exit code: [0 = pass, 1 = fail]

For GitHub Actions:
  - name: Design System Check
    run: npx @fyrsmithlabs/design-check --ci
    continue-on-error: false

For GitLab CI:
  design-check:
    script: npx @fyrsmithlabs/design-check --ci --format=json

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

### 4a. JSON Output Format (--format=json)

For CI integration and tooling:

```json
{
  "project": "project-name",
  "timestamp": "2025-01-28T12:00:00Z",
  "designSystem": "Terminal Elegance v2.0.0",
  "summary": {
    "filesScanned": 15,
    "violations": {
      "critical": 2,
      "error": 5,
      "warning": 8,
      "info": 3
    },
    "pass": false
  },
  "violations": [
    {
      "file": "static/css/main.css",
      "line": 15,
      "severity": "critical",
      "rule": "hardcoded-color",
      "found": "background: #ea580c;",
      "expected": "background: var(--color-primary);",
      "autoFix": {
        "available": true,
        "replacement": "var(--color-primary)"
      }
    }
  ],
  "wcag": {
    "level": "AA",
    "violations": ["1.4.3", "2.4.7"]
  }
}
```

### 5. Severity Definitions

| Severity | Meaning | Action Required | CI Behavior |
|----------|---------|-----------------|-------------|
| CRITICAL | Direct design system violation affecting brand consistency | Must fix before merge | Fails build |
| ERROR | Accessibility or maintainability issue | Should fix promptly | Fails build |
| WARNING | Deviation from best practices | Consider fixing | Warning only |
| INFO | Suggestion for improvement | Optional | Informational |

## Implementation Notes

To perform the check:
1. Use `Glob` to find files matching patterns
2. Use `Read` to examine file contents
3. Use `Grep` to search for violation patterns
4. Compile findings into structured report
5. Output report to user

Do NOT modify any files. This is a report-only tool (auto-fix suggestions are advisory).

## CI Pipeline Integration

### GitHub Actions

```yaml
name: Design System Check
on: [push, pull_request]

jobs:
  design-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Design System Check
        run: |
          # Invoke via Claude Code or custom script
          npx @fyrsmithlabs/design-check --ci --format=json > report.json
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: design-system-report
          path: report.json
```

### GitLab CI

```yaml
design-check:
  stage: lint
  script:
    - npx @fyrsmithlabs/design-check --ci
  allow_failure: false
  artifacts:
    reports:
      codequality: design-report.json
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit
files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(css|templ|html|md)$')
if [ -n "$files" ]; then
  npx @fyrsmithlabs/design-check $files --ci
  exit $?
fi
```

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

W3C Design Tokens specification: https://design-tokens.github.io/community-group/format/

WCAG 2.2 guidelines: https://www.w3.org/TR/WCAG22/

axe-core rules: https://dequeuniversity.com/rules/axe/
