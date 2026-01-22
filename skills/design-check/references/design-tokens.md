# Design Tokens Quick Reference

Extracted from FyrsmithLabs Terminal Elegance Design System v2.0.0.

## Hardcoded Values to Token Mapping

Use this reference to convert hardcoded values to design tokens.

### Colors

#### Primary (Burnt Orange)
| Hardcoded | Token | Usage |
|-----------|-------|-------|
| `#ea580c` | `var(--color-primary)` | Interactive elements, links, focus states |
| `#f97316` | `var(--color-primary-hover)` | Hover states on primary |
| `#9a3412` | `var(--color-primary-muted)` | Subtle primary backgrounds |
| `rgba(234, 88, 12, 0.35)` | `var(--color-primary-glow)` | Glow effects, focus rings |
| `rgba(234, 88, 12, 0.12)` | `var(--color-primary-grid)` | Grid patterns, subtle lines |
| `rgba(234, 88, 12, 0.2)` | `var(--color-primary-ambient)` | Ambient glow, radial gradients |
| `rgba(234, 88, 12, 0.1)` | `var(--color-primary-subtle-bg)` | Subtle backgrounds, badges |

#### Accent (Fuchsia)
| Hardcoded | Token | Usage |
|-----------|-------|-------|
| `#c026d3` | `var(--color-accent)` | Secondary actions, highlights |
| `#d946ef` | `var(--color-accent-hover)` | Hover on accent |
| `#86198f` | `var(--color-accent-muted)` | Subtle accent backgrounds |

#### Backgrounds
| Hardcoded | Token | Usage |
|-----------|-------|-------|
| `#050505` | `var(--bg-void)` | Page background, deepest |
| `#080808` | `var(--bg-alt)` | Alternate section backgrounds |
| `#0a0a0a` | `var(--bg-surface)` | Cards, panels, containers |
| `#111111` | `var(--bg-elevated)` | Headers, elevated surfaces |
| `#161616` | `var(--bg-hover)` | Hover backgrounds |

#### Text
| Hardcoded | Token | Usage |
|-----------|-------|-------|
| `#fafafa` | `var(--text-primary)` | Main text, headings |
| `#a3a3a3` | `var(--text-secondary)` | Secondary text, labels |
| `#525252` | `var(--text-muted)` | Disabled, placeholder |
| `#000` | `var(--text-on-primary)` | Text on primary buttons |

#### Borders
| Hardcoded | Token | Usage |
|-----------|-------|-------|
| `rgba(255, 255, 255, 0.06)` | `var(--border-subtle)` | Section dividers |
| `rgba(255, 255, 255, 0.1)` | `var(--border-default)` | Standard borders |
| `rgba(255, 255, 255, 0.15)` | `var(--border-hover)` | Borders on hover |

#### Status/Semantic
| Hardcoded | Token | Usage |
|-----------|-------|-------|
| `#ef4444` | `var(--color-error)` | Errors, destructive |
| `#7f1d1d` | `var(--color-error-muted)` | Error backgrounds |
| `#f59e0b` | `var(--color-warning)` | Warnings |
| `#78350f` | `var(--color-warning-muted)` | Warning backgrounds |
| `#22c55e` | `var(--color-success)` | Success states |
| `#14532d` | `var(--color-success-muted)` | Success backgrounds |
| `#3b82f6` | `var(--color-info)` | Informational |
| `#1e3a8a` | `var(--color-info-muted)` | Info backgrounds |

### Spacing

Based on 4px grid (0.25rem base):

| Hardcoded | Token | Pixels |
|-----------|-------|--------|
| `0.25rem` / `4px` | `var(--space-1)` | 4px |
| `0.5rem` / `8px` | `var(--space-2)` | 8px |
| `0.75rem` / `12px` | `var(--space-3)` | 12px |
| `1rem` / `16px` | `var(--space-4)` | 16px |
| `1.5rem` / `24px` | `var(--space-6)` | 24px |
| `2rem` / `32px` | `var(--space-8)` | 32px |
| `2.5rem` / `40px` | `var(--space-10)` | 40px |
| `3rem` / `48px` | `var(--space-12)` | 48px |
| `4rem` / `64px` | `var(--space-16)` | 64px |
| `5rem` / `80px` | `var(--space-20)` | 80px |
| `6rem` / `96px` | `var(--space-24)` | 96px |

### Font Sizes

| Hardcoded | Token | Pixels |
|-----------|-------|--------|
| `0.625rem` | `var(--text-2xs)` | 10px |
| `0.75rem` | `var(--text-xs)` | 12px |
| `0.875rem` | `var(--text-sm)` | 14px |
| `1rem` | `var(--text-base)` | 16px |
| `1.125rem` | `var(--text-lg)` | 18px |
| `1.25rem` | `var(--text-xl)` | 20px |
| `1.5rem` | `var(--text-2xl)` | 24px |
| `2rem` | `var(--text-3xl)` | 32px |
| `2.75rem` | `var(--text-4xl)` | 44px |
| `3.5rem` | `var(--text-5xl)` | 56px |

### Border Radius

| Hardcoded | Token | Usage |
|-----------|-------|-------|
| `2px` | `var(--radius-sm)` | Small elements, badges |
| `4px` | `var(--radius-md)` | Buttons, inputs |
| `8px` | `var(--radius-lg)` | Cards, panels |

### Z-Index Scale

| Hardcoded | Token | Usage |
|-----------|-------|-------|
| `10` | `var(--z-dropdown)` | Dropdown menus |
| `20` | `var(--z-sticky)` | Sticky elements |
| `30` | `var(--z-fixed)` | Fixed position |
| `40` | `var(--z-modal-backdrop)` | Modal overlays |
| `50` | `var(--z-modal)` | Modal content |
| `60` | `var(--z-popover)` | Popovers, tooltips |
| `70` | `var(--z-tooltip)` | Floating tooltips |
| `100` | (hardcoded exception) | Header only |

### Animation Durations

| Hardcoded | Token | Usage |
|-----------|-------|-------|
| `150ms` | `var(--duration-fast)` | Micro-interactions |
| `200ms` | `var(--duration-normal)` | Standard transitions |

### Easing

| Hardcoded | Token |
|-----------|-------|
| `cubic-bezier(0.33, 1, 0.68, 1)` | `var(--ease-out)` |

## Violation Patterns

### CSS Patterns to Flag

```regex
# Hardcoded colors (outside :root)
# Use negative lookbehind to exclude :root context
(?<!:root[^}]*)\b#[0-9a-fA-F]{3,8}\b
(?<!:root[^}]*)rgb\(\d+,\s*\d+,\s*\d+\)
(?<!:root[^}]*)rgba\(\d+,\s*\d+,\s*\d+,\s*[\d.]+\)

# Hardcoded spacing (not 0 or 1px)
# Use negative lookbehind to exclude CSS variable definitions
(?<!var\(--[^)]*)(margin|padding|gap):\s*[2-9]\d*px
(?<!var\(--[^)]*)(margin|padding|gap):\s*\d+rem

# Hardcoded font sizes (not 16px iOS exception)
# Use negative lookbehind to exclude CSS variable definitions
(?<!var\(--[^)]*)(font-size:\s*(?!16px)\d+px)
(?<!var\(--[^)]*)(font-size:\s*\d+(\.\d+)?rem)

# Hardcoded z-index (not 0 or 100)
z-index:\s*(?!0|100)\d+

# Hardcoded border radius (not 2, 4, or 8)
border-radius:\s*(?!2px|4px|8px)\d+px

# Hardcoded durations (not 150ms, 200ms, or 0.01ms)
\d+ms(?<!150ms|200ms|0\.01ms)
```

### Template Patterns to Flag

```regex
# Missing alt on images
<img[^>]+(?!alt=)[^>]*>

# Empty buttons (potential icon-only without aria-label)
<button[^>]*>\s*<(svg|i|span class="icon")[^>]*>

# Divs that could be semantic
<div[^>]*class="[^"]*(?:header|nav|main|footer|section|article|aside)[^"]*"
```

### Documentation Patterns to Flag

```regex
# Brand name variations (case insensitive)
(?i)fyrsmith\s+labs
(?i)fyrsmith-labs
(?i)fyrsmithlabs(?<!FyrsmithLabs)

# Raw hex colors in docs
#[0-9a-fA-F]{6}
```

## Accessibility Requirements

### Focus States
All interactive elements MUST have `:focus-visible` styles:
```css
.element:focus-visible {
  outline: var(--focus-ring-width) solid var(--focus-ring-color);
  outline-offset: var(--focus-ring-offset);
}
```

### Disabled States
```css
.element:disabled,
.element[aria-disabled="true"] {
  opacity: var(--opacity-disabled);
  cursor: not-allowed;
  pointer-events: none;
}
```

### Color Contrast Minimums
- Text on backgrounds: 4.5:1 (AA)
- Large text: 3:1 (AA)
- UI components: 3:1 (AA)

### Touch Targets
Minimum 48px height on mobile for:
- Buttons
- Form inputs
- Navigation links
