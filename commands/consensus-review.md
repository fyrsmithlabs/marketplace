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

### 1. Resolve Scope

```bash
git diff --name-only              # "unstaged"
git diff --cached --name-only     # "staged"
git show <ref> --name-only        # commit
gh pr diff <num> --name-only      # PR #123
```

### 2. Detect Language & Select Agents

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

### 3. Dispatch Parallel Agents

Launch all selected reviewers using Task tool with `run_in_background: true`:

```
Task(subagent_type: "fs-dev:security-reviewer", run_in_background: true)
Task(subagent_type: "fs-dev:vulnerability-reviewer", run_in_background: true)
Task(subagent_type: "fs-dev:code-quality-reviewer", run_in_background: true)
Task(subagent_type: "fs-dev:documentation-reviewer", run_in_background: true)
Task(subagent_type: "fs-dev:user-persona-reviewer", run_in_background: true)
Task(subagent_type: "fs-dev:go-reviewer", run_in_background: true)  # if Go files
```

Each agent receives: file list, contents/diff, language context.

### 4. Synthesize Findings

1. Collect JSON outputs from all agents
2. Check veto status (all agents can veto by default)
3. If `--ignore-vetos`: treat vetoes as advisory warnings
4. Tally by severity, identify consensus (2+ agents)
5. De-duplicate similar findings

### 5. Store Results

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
  ❌ Security: CRITICAL injection vulnerability
  ❌ Go: HIGH goroutine leak detected

┌────────────────┬─────────┬────┬────┬────┬────┐
│ Agent          │ Verdict │ C  │ H  │ M  │ L  │
├────────────────┼─────────┼────┼────┼────┼────┤
│ Security       │ VETO    │ 1  │ 0  │ 2  │ 0  │
│ Vulnerability  │ OK      │ 0  │ 0  │ 1  │ 0  │
│ Code Quality   │ OK      │ 0  │ 1  │ 1  │ 0  │
│ Documentation  │ OK      │ 0  │ 0  │ 1  │ 3  │
│ User Persona   │ OK      │ 0  │ 0  │ 0  │ 2  │
│ Go             │ VETO    │ 0  │ 1  │ 2  │ 1  │
├────────────────┼─────────┼────┼────┼────┼────┤
│ Total          │         │ 1  │ 2  │ 7  │ 6  │
└────────────────┴─────────┴────┴────┴────┴────┘

Critical (1):
  • [SEC] SQL injection in validate.go:45

High (2):
  • [SEC] Missing auth check on /admin route
  • [GO] Goroutine leak - no exit condition

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
