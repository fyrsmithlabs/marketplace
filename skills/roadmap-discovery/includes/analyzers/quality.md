# Quality Analyzer

Identify code quality issues and technical debt.

## Analysis Categories

### 1. Test Coverage

**Patterns to Check:**
- Missing test files for modules
- Low test coverage percentage
- Missing edge case tests
- No integration tests

**Search Patterns:**
```
Glob: **/*.test.{js,ts}|**/*_test.{go,py}
Glob: **/tests/**/*
Compare: source files vs test files ratio
```

**Commands:**
```bash
npm test -- --coverage --json 2>/dev/null
go test -cover ./... 2>/dev/null
pytest --cov --cov-report=json 2>/dev/null
```

### 2. Code Complexity

**Patterns to Check:**
- Functions over 50 lines
- Deep nesting (>4 levels)
- High cyclomatic complexity
- Too many parameters (>5)

**Search Patterns:**
```
Grep: ^(function|def|func)\s+\w+.*\{$ (count lines until closing)
Analyze: indentation depth
```

### 3. Code Duplication

**Patterns to Check:**
- Copy-pasted code blocks
- Similar function implementations
- Repeated error handling patterns
- Duplicate constants/config

**Tools:**
```bash
npx jscpd --format json 2>/dev/null
```

### 4. Error Handling

**Patterns to Check:**
- Empty catch blocks
- Swallowed errors
- Missing error boundaries
- Inconsistent error patterns

**Search Patterns:**
```
Grep: catch\s*\(\w*\)\s*\{\s*\}
Grep: \.catch\(\s*\(\)\s*=>\s*\{\s*\}\s*\)
Grep: if err != nil \{[\s\S]*?\}
```

### 5. Code Organization

**Patterns to Check:**
- Files over 500 lines
- Circular dependencies
- God objects/modules
- Mixed concerns in single file

**Search Patterns:**
```
Analyze: file line counts
Analyze: import/require patterns for cycles
```

## Severity Classification

| Finding | Severity |
|---------|----------|
| No tests for critical path | MAJOR |
| Cyclomatic complexity >20 | MAJOR |
| >30% code duplication | MAJOR |
| Empty catch blocks | MAJOR |
| File >1000 lines | MINOR |
| Function >100 lines | MINOR |
| Missing JSDoc on public API | MINOR |
| TODO/FIXME comments | SUGGESTION |

## Output Format

```json
{
  "id": "qual_001",
  "lens": "quality",
  "severity": "MAJOR",
  "title": "No tests for auth module",
  "description": "Auth module has 0% test coverage. Contains login, logout, password reset.",
  "location": "src/auth/",
  "recommendation": "Add unit tests for auth handlers, integration tests for flows",
  "effort": "medium",
  "references": ["https://testing-library.com/"]
}
```
