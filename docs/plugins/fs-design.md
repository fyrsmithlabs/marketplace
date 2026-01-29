# fs-design Plugin

**Version:** 1.0.0
**Category:** Design System Compliance
**Author:** fyrsmithlabs

---

## Overview

The fs-design plugin provides design system compliance checking for FyrsmithLabs products. It audits CSS, templates, and documentation for compliance with the **Terminal Elegance** design system (v2.0.0 - 2026 Tech Minimal).

### Key Capabilities

- Scan CSS files for hardcoded colors, spacing, fonts, z-index values
- Check templates for accessibility issues (missing alt text, ARIA labels)
- Validate brand name consistency in documentation
- Generate structured compliance reports with severity levels
- Provide auto-fix suggestions for simple violations
- Support CI pipeline integration with JSON output

---

## Design System Concepts

### What is Terminal Elegance?

Terminal Elegance is the FyrsmithLabs design system that combines:

- **Terminal nostalgia** - Monospace fonts, command-line aesthetics
- **2026 Tech Minimalism** - Ultra-dark themes with restrained intentionality
- **Developer-first UX** - Clean, functional interfaces
- **Purposeful restraint** - Motion should be felt, not seen

### Design Tokens

Design tokens are named values that replace hardcoded CSS values. They ensure consistency across all FyrsmithLabs products.

#### Colors

| Category | Token | Value | Usage |
|----------|-------|-------|-------|
| Primary | `--color-primary` | `#ea580c` | Interactive elements, links, CTAs |
| Primary | `--color-primary-hover` | `#f97316` | Hover states on primary |
| Accent | `--color-accent` | `#c026d3` | Secondary actions, highlights |
| Background | `--bg-void` | `#050505` | Page background (deepest) |
| Background | `--bg-surface` | `#0a0a0a` | Cards, panels, containers |
| Background | `--bg-elevated` | `#111111` | Headers, elevated surfaces |
| Text | `--text-primary` | `#fafafa` | Main text, headings |
| Text | `--text-secondary` | `#a3a3a3` | Secondary text, labels |
| Text | `--text-muted` | `#525252` | Disabled, placeholder |

#### Spacing (4px Grid)

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Minimal spacing |
| `--space-2` | 8px | Tight spacing |
| `--space-4` | 16px | Standard spacing |
| `--space-6` | 24px | Comfortable spacing |
| `--space-8` | 32px | Section spacing |
| `--space-12` | 48px | Large spacing |
| `--space-16` | 64px | Extra large spacing |

#### Font Sizes

| Token | Value |
|-------|-------|
| `--text-xs` | 12px |
| `--text-sm` | 14px |
| `--text-base` | 16px |
| `--text-lg` | 18px |
| `--text-xl` | 20px |
| `--text-2xl` | 24px |
| `--text-3xl` | 32px |

#### Z-Index Scale

| Token | Value | Usage |
|-------|-------|-------|
| `--z-dropdown` | 10 | Dropdown menus |
| `--z-sticky` | 20 | Sticky elements |
| `--z-fixed` | 30 | Fixed position |
| `--z-modal-backdrop` | 40 | Modal overlays |
| `--z-modal` | 50 | Modal content |
| `--z-popover` | 60 | Popovers |
| `--z-tooltip` | 70 | Floating tooltips |

**Exception:** Header uses hardcoded `z-index: 100`.

#### Animation

| Token | Value | Usage |
|-------|-------|-------|
| `--duration-fast` | 150ms | Micro-interactions |
| `--duration-normal` | 200ms | Standard transitions |
| `--ease-out` | `cubic-bezier(0.33, 1, 0.68, 1)` | Standard easing |

### Compliance Rules

1. **No hardcoded colors** outside `:root` - Use `var(--color-*)`, `var(--bg-*)`, `var(--text-*)`
2. **No hardcoded spacing** - Use `var(--space-*)` on 4px grid
3. **No hardcoded font sizes** - Use `var(--text-*)` (exception: 16px for iOS zoom prevention)
4. **No arbitrary z-index** - Use `var(--z-*)` scale
5. **Minimal motion** - Only hover/focus micro-transitions, no decorative animations
6. **Accessibility required** - Focus states, ARIA labels, alt text mandatory

---

## Skills

| Name | Purpose | Triggers |
|------|---------|----------|
| `fs-design:check` | Audit files for Terminal Elegance design system compliance. Checks CSS, templates, and documentation for hardcoded values, accessibility issues, and brand consistency. | "check design system compliance", "audit CSS for design tokens", "find hardcoded colors", "check accessibility", "validate design consistency", "run design check", "a11y audit" |

### fs-design:check

The core skill that performs design system compliance audits.

**Supported Standards:**
- W3C Design Tokens Community Group (DTCG) format (2025.10 specification)
- WCAG 2.2 Level AA compliance
- Modern CSS custom properties and component patterns
- Terminal Elegance design system v2.0.0

**File Types Checked:**
- CSS files (`.css`)
- Template files (`.templ`, `.html`)
- Documentation files (`.md`)

**Default Scan Locations:**
- `static/css/` or `css/`
- `internal/templates/` or `templates/`
- `*.md` files in project root

---

## Agents

| Name | Capabilities | Modifies Files? |
|------|--------------|-----------------|
| `fs-design:consistency-reviewer` | Audits CSS, templates, and documentation for design system compliance. Generates detailed compliance reports with violations grouped by file and severity. | No (read-only) |
| `fs-design:task-executor` | Generates new UI components following the design system. Refactors existing CSS to use design tokens. Makes code design-system compliant. | Yes (with permission) |

### fs-design:consistency-reviewer

A read-only audit agent that performs comprehensive design system compliance checks.

**Tools Used:** Glob, Grep, LS, Read, NotebookRead

**Process:**
1. Identifies scope (specific path or default locations)
2. Locates design system reference (DESIGN_SYSTEM.md)
3. Executes file-type-specific checks
4. Generates structured compliance report

**Use Cases:**
- PR reviews touching CSS or templates
- Auditing new FyrsmithLabs products
- Checking design token usage before release

### fs-design:task-executor

An execution agent that can generate and refactor code to comply with the design system.

**Tools Used:** All tools

**Permission Model:**
- Requests explicit approval before modifying files
- Shows proposed changes before applying
- Permission can be bypassed if user grants it upfront

**Workflows:**
1. **Generate**: Create new UI components using design tokens
2. **Refactor**: Convert hardcoded values to design tokens
3. **Compliance Fix**: Make existing code design-system compliant

---

## Commands

| Command | Purpose | Arguments |
|---------|---------|-----------|
| `/fs-design:check [path]` | Audit files for Terminal Elegance design system compliance | `path` (optional): Specific file or directory to audit. Defaults to scanning common locations. |

### Usage Examples

```
/fs-design:check                           # Scan default locations
/fs-design:check static/css/main.css       # Check specific file
/fs-design:check internal/templates/       # Check directory
```

---

## Violation Types

The plugin detects the following violation types, organized by severity.

### CRITICAL

| Violation | Description | Fix |
|-----------|-------------|-----|
| Hardcoded colors | Hex colors (`#ea580c`) outside `:root` | Use `var(--color-*)`, `var(--bg-*)`, `var(--text-*)` |
| Color contrast failure | Text/background below 4.5:1 ratio | Adjust colors per WCAG 1.4.3 |
| ARIA invalid values | Incorrect aria-* attribute values | Use valid ARIA values |
| Missing focus visible | Interactive elements without focus styles | Add `:focus-visible` styles |

### ERROR

| Violation | Description | Fix |
|-----------|-------------|-----|
| Hardcoded spacing | `margin`, `padding`, `gap` with pixel values | Use `var(--space-*)` |
| Hardcoded font sizes | `font-size` with pixel values (except 16px) | Use `var(--text-*)` |
| Missing alt text | `<img>` without `alt` attribute | Add descriptive `alt` text |
| Non-semantic structure | `<div>` where semantic element is appropriate | Use `<header>`, `<nav>`, `<main>`, etc. |
| Brand name inconsistency | "Fyrsmith Labs", "fyrsmithlabs", etc. | Use "FyrsmithLabs" (PascalCase) |
| Missing reduced motion | Animations without `prefers-reduced-motion` check | Wrap in media query |

### WARNING

| Violation | Description | Fix |
|-----------|-------------|-----|
| Hardcoded z-index | `z-index` with numeric values (except 0, 100) | Use `var(--z-*)` |
| Missing ARIA labels | Icon-only buttons without accessible name | Add `aria-label` |
| Non-standard border radius | Values other than 2px, 4px, 8px | Use `var(--radius-*)` |
| Non-standard durations | Values other than 150ms, 200ms | Use `var(--duration-*)` |
| Missing focus indicator contrast | Focus ring below 3:1 contrast | Ensure visible focus |

### INFO

| Violation | Description | Fix |
|-----------|-------------|-----|
| Decorative animations | `@keyframes` or `animation-name` usage | Consider if motion is essential |
| Form accessibility | Inputs without associated labels | Add `<label>` or `aria-label` |
| Design token references in docs | Pixel values mentioned in documentation | Reference token names instead |

---

## Example Output

### Text Format (Default)

```
================================================================================
                    DESIGN SYSTEM COMPLIANCE REPORT
================================================================================
Project: website
Checked: 2026-01-29T10:30:00Z
Scope: default scan
Design System: Terminal Elegance v2.0.0

--------------------------------------------------------------------------------
SUMMARY
--------------------------------------------------------------------------------
Files Scanned: 15
  - CSS: 3
  - Templates: 8
  - Documentation: 4

Violations Found: 12
  - Critical: 2
  - Error: 5
  - Warning: 3
  - Info: 2

CI Status: FAIL (FAIL if Critical > 0 or Error > 0)

--------------------------------------------------------------------------------
VIOLATIONS BY FILE
--------------------------------------------------------------------------------

static/css/main.css
  Line 45: [CRITICAL] Hardcoded color #ea580c
           Found: background: #ea580c;
           Should be: background: var(--color-primary);
           Auto-fix: Replace #ea580c with var(--color-primary)

  Line 72: [ERROR] Hardcoded spacing
           Found: padding: 24px;
           Should be: padding: var(--space-6);
           Auto-fix: Replace 24px with var(--space-6)

  Line 103: [WARNING] Non-standard z-index
            Found: z-index: 999;
            Should be: var(--z-modal) or similar

internal/templates/hero.templ
  Line 15: [ERROR] Missing alt text on image
           Found: <img src="/logo.png">
           Should be: <img src="/logo.png" alt="FyrsmithLabs logo">
           Auto-fix: Add alt="" attribute (fill in description)

  Line 42: [WARNING] Missing aria-label on icon button
           Found: <button><svg>...</svg></button>
           Should be: <button aria-label="Close menu"><svg>...</svg></button>

README.md
  Line 8: [ERROR] Brand name inconsistency
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

================================================================================
```

### JSON Format (CI Integration)

```json
{
  "project": "website",
  "timestamp": "2026-01-29T10:30:00Z",
  "designSystem": "Terminal Elegance v2.0.0",
  "summary": {
    "filesScanned": 15,
    "violations": {
      "critical": 2,
      "error": 5,
      "warning": 3,
      "info": 2
    },
    "pass": false
  },
  "violations": [
    {
      "file": "static/css/main.css",
      "line": 45,
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

---

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
          npx @fyrsmithlabs/design-check --ci --format=json > report.json
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: design-system-report
          path: report.json
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

---

## Recommended Tooling

For automated enforcement beyond this plugin:

| Tool | Purpose | Integration |
|------|---------|-------------|
| **Stylelint** | CSS linting and rule enforcement | `stylelint-config-standard` |
| **axe-core** | Accessibility testing engine | WCAG 2.2 AA compliance |
| **Design Token Validator** | DTCG format validation | W3C Design Tokens spec |

### Suggested Stylelint Rules

```json
{
  "rules": {
    "color-no-hex": true,
    "declaration-property-value-disallowed-list": {
      "z-index": ["/^(?!var\\(--z-).*/"],
      "font-size": ["/^(?!var\\(--text-|16px).*/"]
    },
    "custom-property-pattern": "^(color|bg|text|space|z|radius|duration|font)-"
  }
}
```

---

## Cross-Product Scope

The fs-design plugin applies to all FyrsmithLabs products:

| Product | Stack | Notes |
|---------|-------|-------|
| **Website** | Go + Templ | Single CSS file at `static/css/styles.css` |
| **DevPilot** | Electron/React | Component-based architecture (future) |
| **Other** | Various | Adapt file patterns as needed |
