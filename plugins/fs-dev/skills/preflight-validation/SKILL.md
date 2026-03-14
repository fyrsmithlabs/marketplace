---
name: preflight-validation
description: Use when starting a new session, before beginning work, or when encountering environment errors. Validates git config, branch state, tool availability, and project dependencies. Auto-remediates common issues.
---

# Preflight Validation

Multi-layer environment validation at session start with auto-remediation. Eliminates environment configuration errors by checking git identity, branch state, toolchain availability, and integration health before any work begins.

## Contextd Integration

If contextd MCP is available:
- `memory_search` to find past preflight failures for this project
- `memory_record` to store preflight results for cross-session comparison
- `remediation_search` to find known fixes for detected issues

If contextd is NOT available:
- Validation runs inline (still works)
- No persistence of preflight results
- No cross-session comparison available

---

## When to Use

- At the start of every new session
- Before beginning any task
- When encountering environment errors (missing tools, auth failures, wrong branch)
- After switching projects or worktrees
- When a command fails unexpectedly due to environment issues

---

## Validation Tiers

Run tiers in order. Each tier gates the next -- do not proceed to T1 until T0 passes, and do not proceed to T2 until T1 passes.

### T0 - Hard Gates (Deterministic, Fast)

These checks are non-negotiable. Failures here block all work.

| Check | Command | Pass Criteria | Failure Action |
|-------|---------|---------------|----------------|
| Git identity (name) | `git config user.name` | Non-empty string | Prompt user, run `git config user.name "<value>"` |
| Git identity (email) | `git config user.email` | Non-empty string | Prompt user, run `git config user.email "<value>"` |
| Current branch | `git branch --show-current` | Not `main` or `master` | Warn, suggest creating feature branch |
| Git state clean | `git status --porcelain` | No merge conflicts | Block if merge conflict or rebase in progress |
| Merge conflict check | Look for `MERGE_HEAD`, `REBASE_HEAD` | Neither exists | Instruct user to resolve before proceeding |

**T0 Auto-Remediation:**

- **Missing git identity:** Use `AskUserQuestion` to prompt for name and email, then run:
  ```
  git config user.name "<provided name>"
  git config user.email "<provided email>"
  ```
- **On protected branch (main/master):** Suggest branch name based on task context:
  ```
  git checkout -b feat/<task-description>
  ```
  Use `AskUserQuestion` to confirm branch name before creating.
- **Merge conflict / rebase in progress:** Do NOT auto-remediate. Inform user of state and wait for manual resolution.

### T1 - Context Gates (Project Inspection)

These checks adapt to the detected project type.

| Check | Detection Method | Pass Criteria | Failure Action |
|-------|-----------------|---------------|----------------|
| Project type | Check for `go.mod`, `package.json`, `Cargo.toml`, `pyproject.toml`, `Gemfile` | At least one detected | Warn: unknown project type, proceed with generic checks |
| Go toolchain | `go version` | Exits 0, version reported | Provide install guidance |
| Go formatter | `which gofmt` | Found in PATH | Included with Go toolchain |
| gitleaks | `which gitleaks` | Found in PATH | Suggest: `brew install gitleaks` or `go install github.com/gitleaks/gitleaks/v8/cmd/gitleaks@latest` |
| Node runtime | `node --version` | Exits 0 (Node projects only) | Suggest: `brew install node` or use nvm |
| Package manager | `which npm` or `which bun` or `which pnpm` | At least one found (Node projects only) | Suggest install for detected lock file type |
| Rust toolchain | `rustc --version` | Exits 0 (Rust projects only) | Suggest: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh` |
| Uncommitted changes | `git status --porcelain` | Empty or warn | Warn with file count, do NOT block |

**T1 Project Type Detection:**

| File Present | Project Type | Required Tools |
|-------------|-------------|----------------|
| `go.mod` | Go | `go`, `gofmt`, `gitleaks` |
| `package.json` | Node/JS/TS | `node`, `npm`/`bun`/`pnpm`, `gitleaks` |
| `Cargo.toml` | Rust | `rustc`, `cargo`, `gitleaks` |
| `pyproject.toml` or `requirements.txt` | Python | `python3`, `pip`/`uv`, `gitleaks` |
| `Gemfile` | Ruby | `ruby`, `bundler`, `gitleaks` |
| None detected | Generic | `gitleaks` |

**T1 Auto-Remediation:**

- **Missing tool:** Provide platform-appropriate install command. Do NOT auto-install without user confirmation.
- **Uncommitted changes:** Warn with summary (e.g., "3 modified, 1 untracked"). Suggest stashing if starting unrelated work.

### T2 - Integration Gates (External Checks)

These checks verify external service connectivity. Failures here are warnings, not blockers.

| Check | Command | Pass Criteria | Failure Action |
|-------|---------|---------------|----------------|
| GitHub CLI auth | `gh auth status` | Authenticated | Suggest: `gh auth login` |
| GitHub CLI available | `which gh` | Found in PATH | Suggest: `brew install gh` |
| contextd MCP | Check if contextd tools are available | Tools respond | Note: contextd unavailable, proceeding without memory |
| Docker (if needed) | `docker info` | Daemon running | Warn if project has Dockerfile/docker-compose |

**T2 Auto-Remediation:**

- **GitHub CLI not authenticated:** Suggest `gh auth login` and wait for user.
- **GitHub CLI missing:** Suggest `brew install gh` (macOS) or platform-appropriate install.
- **contextd unavailable:** Note in output. No action needed -- all skills have contextd fallbacks.
- **Docker not running:** Warn only if project contains Dockerfile or docker-compose.yml.

---

## Output Format

Present results as a table after all tiers complete:

```
## Preflight Check Results

| Check | Status | Action |
|-------|--------|--------|
| Git identity | PASS | dahendel <dustin@fyrsmithlabs.com> |
| Branch | WARN | On main - create feature branch? |
| Git state | PASS | Clean, no conflicts |
| Project type | PASS | Go (go.mod detected) |
| Go toolchain | PASS | go1.23.4 |
| gofmt | PASS | Available |
| gitleaks | PASS | v8.22.0 |
| Uncommitted changes | WARN | 2 modified files |
| GitHub CLI | PASS | Authenticated as dahendel |
| contextd | PASS | Available |
```

**Status values:**

| Status | Meaning | Visual |
|--------|---------|--------|
| PASS | Check passed | No action needed |
| WARN | Non-blocking issue | Action suggested but not required |
| FAIL | Blocking issue | Must resolve before proceeding |
| SKIP | Check not applicable | Project type doesn't require this |

---

## Contextd Recording

When contextd is available, record preflight results:

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Preflight validation: <date>",
  content: JSON.stringify({
    date: "<ISO date>",
    tiers: {
      t0: { status: "pass|fail", checks: [...] },
      t1: { status: "pass|warn", checks: [...] },
      t2: { status: "pass|warn", checks: [...] }
    },
    project_type: "<detected type>",
    remediations_applied: ["<list of auto-fixes>"],
    warnings: ["<list of warnings>"]
  }),
  outcome: "success",
  tags: ["preflight-validation", "<project-type>"]
)
```

Search for past failures before running checks:

```
mcp__contextd__memory_search(
  project_id: "<project>",
  query: "preflight-validation failure",
  tags: ["preflight-validation"],
  limit: 3
)
```

If past failures found, proactively check those specific items first.

---

## Integration with Other Skills

| Skill | Integration Point |
|-------|-------------------|
| `complexity-assessment` | Preflight runs before complexity assessment to ensure environment is ready |
| `intent-confirmation` | Preflight runs before intent preview to ensure branch and tools are valid |
| `git-repo-standards` | Branch naming validation aligns with git-repo-standards conventions |
| `git-workflows` | Branch protection awareness (main/master detection) |

---

## Mandatory Checklist

**EVERY preflight validation MUST complete ALL steps:**

- [ ] Check git identity (user.name and user.email)
- [ ] Check current branch (warn if on main/master)
- [ ] Check git state (no merge conflicts, no rebase in progress)
- [ ] Detect project type from manifest files
- [ ] Validate required tools for detected project type
- [ ] Check for uncommitted changes (warn, don't block)
- [ ] Check GitHub CLI authentication status
- [ ] Check contextd availability
- [ ] Present results table with all checks
- [ ] Auto-remediate where possible (git identity, branch creation)
- [ ] Record results in contextd (if available)
- [ ] Confirm all FAIL items are resolved before proceeding

**Preflight is NOT complete until all FAIL items are resolved.**

---

## Red Flags - STOP and Reconsider

If you're thinking any of these, you're about to violate the skill:

| Thought | Reality |
|---------|---------|
| "The user probably has git configured" | Check anyway. 12 errors last quarter from missing config. |
| "I'll skip preflight, the task is simple" | Simple tasks on wrong branch cause merge nightmares. Always run. |
| "T2 checks are optional, I'll skip them" | Run all tiers. External integration failures waste more time later. |
| "I'll auto-install missing tools" | NEVER install without user confirmation. Suggest, don't act. |
| "Merge conflicts can wait" | Merge conflicts block everything. Resolve first. |
| "Uncommitted changes don't matter" | They matter if the user is about to start unrelated work. Warn. |
| "I already know the branch is correct" | Verify. Wrong-branch commits are the #1 avoidable error. |
| "contextd is down, skip recording" | Skip recording, but still run all validation checks. |
| "The user said to skip preflight" | Respect the request, but note that preflight was skipped in output. |

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Running T1 before T0 passes | Tiers are sequential. T0 gates T1 gates T2. |
| Auto-installing tools without asking | Always use `AskUserQuestion` before installing anything. |
| Blocking on T2 failures | T2 failures are warnings, not blockers. |
| Skipping preflight for "quick tasks" | Quick tasks on wrong branch are expensive. Always run. |
| Not recording results in contextd | Record every preflight for cross-session trend analysis. |
| Ignoring past failure patterns | Search contextd first to catch recurring issues. |
| Treating uncommitted changes as failures | Warn, suggest stash, but never block. |
| Not detecting project type | Always check for manifest files to tailor tool validation. |

---

## Example: Full Preflight Run

**Session start, Go project, user on main branch:**

1. **T0 - Hard Gates:**
   - Git identity: PASS (dahendel <dustin@fyrsmithlabs.com>)
   - Branch: WARN (on main)
   - Git state: PASS (clean)

2. **Auto-remediation:** Prompt user for branch name:
   ```
   AskUserQuestion(
     question: "You're on the main branch. What feature branch should I create?",
     options: [
       "feat/<describe your task>",
       "fix/<describe the bug>",
       "chore/<describe the maintenance>"
     ],
     allow_custom: true
   )
   ```

3. **T1 - Context Gates:**
   - Project type: Go (go.mod found)
   - Go: PASS (go1.23.4)
   - gofmt: PASS
   - gitleaks: PASS (v8.22.0)
   - Uncommitted changes: PASS (clean)

4. **T2 - Integration Gates:**
   - GitHub CLI: PASS (authenticated as dahendel)
   - contextd: PASS (available)

5. **Output table and proceed.**
