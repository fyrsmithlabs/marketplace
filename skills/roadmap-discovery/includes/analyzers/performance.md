# Performance Analyzer

Identify performance issues and optimization opportunities.

## Analysis Categories

### 1. Database Queries

**Patterns to Check:**
- N+1 query patterns
- Missing indices
- Unbounded queries (no LIMIT)
- Inefficient JOINs

**Search Patterns:**
```
Grep: for.*\{[\s\S]*?(SELECT|find|query)
Grep: SELECT \* FROM
Grep: \.find\(\)(?!\.[^;]*limit)
```

### 2. API Efficiency

**Patterns to Check:**
- Over-fetching data
- Missing pagination
- No caching headers
- Synchronous blocking calls

**Search Patterns:**
```
Grep: await.*await.*await (sequential awaits)
Grep: \.all\(\)|\*|SELECT \*
```

### 3. Frontend Performance

**Patterns to Check:**
- Large bundle size
- Missing code splitting
- Unoptimized images
- Render-blocking resources

**Commands:**
```bash
npm run build --stats 2>/dev/null
npx bundlephobia <package> 2>/dev/null
```

**Search Patterns:**
```
Glob: **/*.{png,jpg,gif} (check sizes)
Grep: import.*from ['"][^'"]+['"] (static imports)
```

### 4. Memory & Resources

**Patterns to Check:**
- Memory leaks (unclosed connections)
- Unbounded caches
- Large in-memory operations
- Missing cleanup

**Search Patterns:**
```
Grep: new Map\(\)|new Set\(\) (without size limits)
Grep: setInterval|setTimeout (without cleanup)
Grep: addEventListener (without removeEventListener)
```

### 5. Concurrency

**Patterns to Check:**
- Blocking operations in async context
- Missing parallelization
- Race conditions
- Deadlock patterns

**Search Patterns:**
```
Grep: for await.*of (could be parallelized)
Grep: await fetch.*\n.*await fetch (sequential)
```

## Severity Classification

| Finding | Severity |
|---------|----------|
| N+1 query in hot path | CRITICAL |
| Unbounded query returning >1000 rows | MAJOR |
| Missing index on frequently queried column | MAJOR |
| Bundle size >1MB | MAJOR |
| Sequential async when parallel possible | MINOR |
| Missing pagination on list endpoint | MINOR |
| Unoptimized images | SUGGESTION |

## Output Format

```json
{
  "id": "perf_001",
  "lens": "perf",
  "severity": "MAJOR",
  "title": "N+1 query in user list",
  "description": "Each user fetch triggers separate query for profile. 100 users = 101 queries.",
  "location": "src/api/users.ts:45",
  "recommendation": "Use eager loading: User.findAll({ include: Profile })",
  "effort": "low",
  "references": ["https://sequelize.org/docs/v6/advanced-association-concepts/eager-loading/"]
}
```
