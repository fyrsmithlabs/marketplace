---
name: consensus-review
description: Run a multi-agent consensus code review. Dispatches 5+ parallel agents and synthesizes findings. All agents have veto power unless --ignore-vetos is set.
arguments:
  - name: path
    description: "File path, directory, PR reference, or scope description to review"
    required: true
  - name: ignore-vetos
    description: "Ignore veto verdicts and show findings as advisory only"
    required: false
  - name: agents
    description: "Comma-separated list of agents to run (default: all)"
    required: false
---

# /consensus-review

Run a multi-agent consensus code review using fs-dev reviewer agents.

## Usage

```bash
/consensus-review <path-or-scope>
/consensus-review <path> --ignore-vetos
/consensus-review <path> --agents security,code-quality,go
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `path` | Yes | File, directory, PR #, commit, or description |
| `--ignore-vetos` | No | Treat all verdicts as advisory |
| `--agents` | No | Subset of agents to run |

## Workflow

### 1. Parallel Initialization

Run scope detection and file indexing concurrently:

```
┌──────────────────────────┐  ┌──────────────────────────┐
│   Scope Detection        │  │   File Indexing          │
│   - Resolve file list    │  │   - Index to contextd    │
│   - Detect languages     │  │   - Get token counts     │
│   - Select agents        │  │   - Branch metadata      │
└───────────┬──────────────┘  └───────────┬──────────────┘
            └──────────────┬──────────────┘
                           ▼
              Budget Calculation & Isolation Decision
```

**Scope Resolution:**
```bash
git diff --name-only              # "unstaged"
git diff --cached --name-only     # "staged"
git show <ref> --name-only        # commit
gh pr diff <num> --name-only      # PR #123
```

**File Indexing (if contextd available):**
```
repository_index(
  path: <project_path>,
  include_patterns: <changed_files>
)
→ Returns: total_tokens, per_file_tokens, branch
```

### 2. Budget Calculation

See `includes/consensus-review/budget.md` for the full formula.

```
scale = min(4.0, 1.0 + total_tokens / 16384)

per_agent_budget = base_budget[agent] * scale
```

**Base budgets:**
| Agent | Base | Max (4x) |
|-------|------|----------|
| security-reviewer | 8,192 | 32,768 |
| vulnerability-reviewer | 8,192 | 32,768 |
| go-reviewer | 8,192 | 32,768 |
| code-quality-reviewer | 6,144 | 24,576 |
| documentation-reviewer | 4,096 | 16,384 |
| user-persona-reviewer | 4,096 | 16,384 |

### 3. Isolation Mode Decision

| Total Tokens | Mode | Behavior |
|--------------|------|----------|
| ≤16,384 | **Shared** | Agents run in parent context |
| >16,384 | **Branch** | Each agent gets isolated contextd branch |

**Branch mode (large scopes):**
```
For each agent:
  branch_create(description: "{agent} review", budget: calculated_budget)
  → Agent executes in isolated context
  → branch_return(findings_json)
```

### 4. Detect Language & Select Agents

Analyze file extensions to determine primary language(s) and select appropriate agents:

| Language | Additional Agent |
|----------|------------------|
| Go (`.go`) | `go-reviewer` (uses effective-go skill) |
| TypeScript/JavaScript | Check for frontend-design skill |
| Python | Standard reviewers |
| Other | Standard reviewers only |

**Standard agents (always included unless filtered):**
- `security-reviewer`
- `vulnerability-reviewer`
- `code-quality-reviewer`
- `documentation-reviewer`
- `user-persona-reviewer`

**Language-specific agents (added based on file types):**
- `go-reviewer` - for Go code

### 5. Dispatch Parallel Agents

Launch all selected reviewers with calculated budgets:

**Shared mode (≤16K tokens):**
```
Task(
  subagent_type: "fs-dev:security-reviewer",
  prompt: "Review {scope}. Budget: {calculated_budget} tokens. {progressive_protocol}",
  run_in_background: true
)
// ... repeat for each agent
```

**Branch mode (>16K tokens):**
```
For each agent:
  branch_id = branch_create(description: "{agent} review", budget: {calculated_budget})
  Task(
    subagent_type: "fs-dev:{agent}",
    prompt: "Review {scope}. Budget: {calculated_budget} tokens. {progressive_protocol}",
    run_in_background: true
  )
  // Collect result, then branch_return()
```

Each agent receives:
- File list and contents/diff
- Language context
- **Calculated budget** (scaled based on scope)
- Progressive summarization protocol reference

### 6. Synthesize Findings

1. Collect JSON outputs from all agents
2. **Check for partial results** - agents with `partial: true` hit budget limits
3. Check veto status (all agents can veto by default)
4. If `--ignore-vetos`: treat vetoes as advisory warnings
5. Tally by severity, identify consensus (2+ agents)
6. De-duplicate similar findings
7. **Calculate coverage** - show files reviewed vs skipped per agent

**Partial Result Handling:**
```python
for agent_output in results:
    if agent_output.partial:
        warnings.append(f"⚠️ {agent_output.agent}: {agent_output.files_reviewed}/{total_files} files (budget limit)")
        skipped_files.extend(agent_output.skipped_files)

if skipped_files:
    suggestions.append(f"Consider: /consensus-review {' '.join(skipped_files)}")
```

### 7. Store Results

**If contextd MCP is available:**
```
mcp__contextd__memory_record(
  title: "Consensus Review: <scope>",
  content: "<summary>",
  tags: ["consensus-review", "<verdict>"]
)
```

**If contextd is NOT available:**
```
Write results to: .claude/consensus-reviews/<name>.md

Naming convention:
- PR: pr-123.md
- Commit: commit-abc1234.md
- Branch: branch-feature-name.md
- Path: review-src-auth.md
- Timestamp fallback: review-2024-01-15-1420.md
```

## Output Format

### Terminal Output (Concise)

```
═══ Consensus Review: src/auth/ ═══

Verdict: BLOCKED (2 vetoes)
⚠️  Partial results: security-reviewer hit budget limit (8/12 files)

  ❌ Security: CRITICAL injection vulnerability
  ❌ Go: HIGH goroutine leak detected

┌────────────────┬─────────┬────┬────┬────┬────┬──────────┐
│ Agent          │ Verdict │ C  │ H  │ M  │ L  │ Coverage │
├────────────────┼─────────┼────┼────┼────┼────┼──────────┤
│ Security       │ VETO    │ 1  │ 0  │ 2  │ 0  │ 67% ⚠️   │
│ Vulnerability  │ OK      │ 0  │ 0  │ 1  │ 0  │ 100%     │
│ Code Quality   │ OK      │ 0  │ 1  │ 1  │ 0  │ 100%     │
│ Documentation  │ OK      │ 0  │ 0  │ 1  │ 3  │ 100%     │
│ User Persona   │ OK      │ 0  │ 0  │ 0  │ 2  │ 100%     │
│ Go             │ VETO    │ 0  │ 1  │ 2  │ 1  │ 100%     │
├────────────────┼─────────┼────┼────┼────┼────┼──────────┤
│ Total          │         │ 1  │ 2  │ 7  │ 6  │          │
└────────────────┴─────────┴────┴────┴────┴────┴──────────┘

Critical (1):
  • [SEC] SQL injection in validate.go:45

High (2):
  • [SEC] Missing auth check on /admin route
  • [GO] Goroutine leak - no exit condition

Files not reviewed by security-reviewer: worker.go, cache.go, middleware.go, types.go
→ Consider: /consensus-review src/auth/worker.go src/auth/cache.go

→ Full report: .claude/consensus-reviews/review-src-auth.md
```

### File Output (Detailed)

Written to `.claude/consensus-reviews/<name>.md`:

```markdown
# Consensus Review: src/auth/

**Scope**: src/auth/
**Date**: 2024-01-15 14:20
**Verdict**: BLOCKED
**Veto Agents**: Security, Go

## Summary

| Agent | Verdict | Critical | High | Medium | Low |
|-------|---------|----------|------|--------|-----|
| Security | VETO | 1 | 0 | 2 | 0 |
| Go | VETO | 0 | 1 | 2 | 1 |
| ... | ... | ... | ... | ... | ... |

## Veto Issues

### [CRITICAL] SQL Injection in User Validation
- **Agent**: Security
- **File**: `src/auth/validate.go:45`
- **CWE**: CWE-89
- **Evidence**:
  ```go
  query := fmt.Sprintf("SELECT * FROM users WHERE id = %s", userId)
  ```
- **Fix**: Use parameterized queries
  ```go
  query := "SELECT * FROM users WHERE id = $1"
  rows, err := db.Query(query, userId)
  ```

### [HIGH] Goroutine Leak
- **Agent**: Go
- **File**: `src/auth/worker.go:78`
- **Issue**: Goroutine started without exit condition
- **Fix**: Add context cancellation
  ```go
  go func(ctx context.Context) {
      for {
          select {
          case <-ctx.Done():
              return
          case work := <-workChan:
              process(work)
          }
      }
  }(ctx)
  ```

## All Findings

### Security (3 issues)
...

### Go (4 issues)
...
```

## Agent Configuration

All agents have veto power by default:

| Agent | Focus | Veto |
|-------|-------|------|
| Security | Injection, auth, secrets, OWASP | Yes |
| Vulnerability | CVEs, deps, supply chain | Yes |
| Code Quality | Logic, tests, complexity | Yes |
| Documentation | README, API docs, CHANGELOG | Yes |
| User Persona | UX, breaking changes, ergonomics | Yes |
| Go | Effective Go, concurrency, error handling | Yes |

### Veto Override

Use `--ignore-vetos` to treat all findings as advisory:

```bash
/consensus-review src/auth/ --ignore-vetos
```

Output changes:
- Verdict shows `ADVISORY` instead of `BLOCKED`
- Vetoes shown as warnings, not blockers
- Still highlights critical issues

## Language-Aware Reviews

The command auto-detects languages and includes relevant agents:

| Files Detected | Agents Added |
|----------------|--------------|
| `*.go` | go-reviewer |
| `*.ts`, `*.tsx`, `*.js`, `*.jsx` | (standard only) |
| `*.py` | (standard only) |
| Mixed | All applicable |

## Error Handling

| Error | Behavior |
|-------|----------|
| Scope not found | Show suggestions, abort |
| Agent fails | Continue with others, note failure |
| No issues found | Show success message |
| contextd unavailable | Fall back to file storage |

## Related

- `/discover` - Broader codebase analysis
- Individual agents via Task tool for single-focus review
- `effective-go` skill for Go development guidance
