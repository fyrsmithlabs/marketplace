# Documentation Analyzer

Identify documentation gaps and outdated content.

## Analysis Categories

### 1. README Completeness

**Required Sections:**
- Project description
- Installation instructions
- Usage examples
- Configuration options
- Contributing guidelines
- License

**Search Patterns:**
```
Glob: README.md|README.rst
Grep: ## Installation|# Installation
Grep: ## Usage|# Usage
Grep: ## Contributing|# Contributing
```

### 2. API Documentation

**Patterns to Check:**
- Undocumented endpoints
- Missing request/response examples
- Outdated API docs
- Missing error codes

**Search Patterns:**
```
Glob: **/api/**/*.{js,ts,go,py}
Compare: route definitions vs docs
Grep: @api|@swagger|@openapi
```

### 3. Code Comments

**Patterns to Check:**
- Missing JSDoc/docstrings on public functions
- Outdated comments (TODOs older than 6 months)
- Commented-out code
- Misleading comments

**Search Patterns:**
```
Grep: // TODO|# TODO|// FIXME
Grep: /\*[\s\S]*?\*/|"""[\s\S]*?"""|'''[\s\S]*?'''
Grep: ^//.*$\n^//.*$ (consecutive comment lines without function)
```

### 4. Changelog

**Patterns to Check:**
- Missing CHANGELOG
- Outdated changelog (no recent entries)
- Inconsistent format
- Missing version numbers

**Search Patterns:**
```
Glob: CHANGELOG.md|HISTORY.md|CHANGES.md
Grep: ## \[\d+\.\d+\.\d+\]
```

### 5. Architecture Documentation

**Patterns to Check:**
- Missing architecture overview
- Outdated diagrams
- Undocumented design decisions
- Missing ADRs (Architecture Decision Records)

**Search Patterns:**
```
Glob: docs/architecture*|docs/design*|docs/adr*
Glob: **/*.{mmd,puml,drawio}
```

## Severity Classification

| Finding | Severity |
|---------|----------|
| No README | CRITICAL |
| No installation instructions | MAJOR |
| Public API without docs | MAJOR |
| Outdated API documentation | MAJOR |
| TODO comments >6 months old | MINOR |
| Missing CHANGELOG | MINOR |
| Commented-out code | SUGGESTION |
| Missing architecture docs | SUGGESTION |

## Output Format

```json
{
  "id": "docs_001",
  "lens": "docs",
  "severity": "MAJOR",
  "title": "Undocumented public API endpoints",
  "description": "15 of 23 API endpoints have no documentation. Missing: /api/users/*, /api/orders/*",
  "location": "src/api/",
  "recommendation": "Add OpenAPI/Swagger annotations or separate API docs",
  "effort": "medium",
  "references": ["https://swagger.io/specification/"]
}
```

## README Scoring

Calculate README completeness score:

| Section | Points |
|---------|--------|
| Title & Description | 10 |
| Installation | 20 |
| Usage Examples | 20 |
| Configuration | 15 |
| Contributing | 15 |
| License | 10 |
| Badges | 5 |
| Screenshots/Demo | 5 |

**Total: 100 points**

| Score | Rating |
|-------|--------|
| 80-100 | Good |
| 60-79 | Adequate |
| 40-59 | Needs Work |
| 0-39 | Poor |
