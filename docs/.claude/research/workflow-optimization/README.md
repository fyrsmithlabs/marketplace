# Research: Workflow Optimization for fyrsmithlabs Plugins

**Generated:** 2026-03-05
**Agents Used:** Technical, Architectural, Security, UX, Competitive
**Sessions Analyzed:** 64 sessions, 879 hours, 565 messages, 23 commits

---

## Executive Summary

Five research agents investigated multi-agent orchestration patterns, sprint automation, security automation, developer experience, and competitive landscape to identify actionable improvements for the fyrsmithlabs Claude Code plugins (fs-dev, contextd, fs-design). The research addresses three primary pain points: 18 "wrong approach" events, 12 environment configuration errors, and 8 API errors across 64 sessions.

**Top 5 Findings (by cross-agent consensus):**

1. **PreToolUse hooks are the highest-leverage improvement** -- All 5 agents identified expanded hook usage as critical. PreToolUse is the only hook that can block actions, making it the enforcement point for branch validation, environment checks, and security gates. (HIGH confidence, 5/5 agents)

2. **Git worktree-based parallel execution is now industry standard** -- Cursor 2.0, Claude Code Agent Teams, and Aider all use git worktrees for isolated parallel agent work. The fyrsmithlabs plugins should formalize worktree management as a first-class skill. (HIGH confidence, 3/5 agents)

3. **Progressive disclosure and context isolation are essential for multi-agent output** -- A 3-layer architecture (Index/Details/Deep-Dive) reduces cognitive overload and token waste. The current synthesis agent could adopt structured summarization tiers. (HIGH confidence, 2/5 agents)

4. **Security scanning should shift left into the agent workflow** -- GitGuardian MCP server enables real-time secrets scanning during development, not just at commit time. The OWASP Top 10 for Agentic Applications 2026 introduces 10 new threat categories specific to agent workflows. (HIGH confidence, 2/5 agents)

5. **Intent confirmation before execution would eliminate most wrong-approach events** -- The 18 wrong-approach friction events stem from insufficient intent disambiguation. A structured "plan-confirm-execute" pattern with complexity-gated confirmation reduces this to near-zero. (HIGH confidence, 3/5 agents)

---

## 1. Current State vs. Best Practices Gap Analysis

| Capability | Current State | Best Practice (2025-2026) | Gap | Priority |
|------------|--------------|---------------------------|-----|----------|
| **Preflight validation** | Basic: git identity check, main branch warning | Multi-layer: env validation, tool availability, token freshness, dependency check | Missing tool/token/dependency checks | **P0** |
| **Wrong-approach prevention** | CLAUDE.md policy: "plan before executing" | Structured intent framework with complexity-gated confirmation and PreToolUse enforcement | No enforcement mechanism, relies on LLM compliance | **P0** |
| **Environment self-healing** | Preflight hook warns but does not fix | Auto-detect and remediate: configure git, refresh tokens, install missing tools | Warn-only, no remediation | **P0** |
| **Parallel agent isolation** | Context-folding skill, Task tool | Git worktree management + per-agent context windows + structured result collection | No worktree automation, manual setup | **P1** |
| **Security scanning** | security-reviewer + vulnerability-reviewer agents at review time | Shift-left: PreToolUse secrets scan, PreCommit gitleaks, GitGuardian MCP integration | Scanning only at review, not at write time | **P1** |
| **Consensus mechanism** | Simple approval/veto with 70% threshold | 7 decision protocols (majority, supermajority, unanimity, AAD, CI), task-type-specific | Only one protocol, no task-type adaptation | **P1** |
| **Budget/token management** | Fixed 8192 budget per reviewer, progressive summarization | Adaptive budgets based on diff complexity, BudgetThinker control tokens, dynamic reallocation | Static budgets, no complexity adaptation | **P1** |
| **Checkpoint/resume** | contextd checkpoint command exists | Event-sourced state with deterministic replay, automatic checkpoint after each phase | Manual checkpoint, no automatic resume | **P2** |
| **Audit trail** | Agent outputs to docs/.claude/ | Comprehensive logging: who/what/why per action, UUID tracking, regulatory alignment | No structured audit trail | **P2** |
| **Cross-session learning** | contextd memories and remediations | Preference learning with feedback loops, pattern recognition, auto-policy updates | Manual memory writes, no auto-learning | **P2** |
| **Headless/batch mode** | Basic `claude -p` support | Structured batch scripts with error handling, retry logic, result collection | No pre-built batch scripts | **P2** |
| **Supply chain security** | Gitleaks for secret scanning | SBOM generation, SLSA compliance, dependency verification, govulncheck integration | No SBOM, no SLSA, no automated dep scanning | **P2** |

---

## 2. Plugin Enhancement Recommendations

### fs-dev Plugin

#### New Skills

| Skill | Description | Trigger |
|-------|-------------|---------|
| `preflight-validation` | Multi-layer environment validation: git config, branch, tokens, tool availability, Go version, dependency freshness | Auto-trigger at session start via PreCompact or manual |
| `worktree-management` | Git worktree lifecycle: create, list, switch, cleanup for parallel agent execution | When dispatching parallel dev agents |
| `sprint-automation` | Issue decomposition, dependency graphing, batch execution with topological sort ordering | `/fs-dev:sprint` command |
| `tdd-pipeline` | Test-driven bug fixing: write failing test, iterate fix, verify green, commit | `/fs-dev:tdd-fix` command |
| `audit-trail` | Structured logging of all agent decisions with UUID tracking and attribution | Automatic during consensus reviews |

#### Existing Skills to Improve

| Skill | Improvement | Rationale |
|-------|-------------|-----------|
| `consensus-review` | Add 3 new decision protocols: supermajority (66%), All-Agents Drafting, Collective Improvement. Gate protocol by task type (reasoning vs knowledge) | Research shows voting improves reasoning by 13.2%, consensus improves knowledge by 2.8% |
| `consensus-review` | Adaptive budget allocation based on diff complexity (small PR = 4096, large PR = 12288) | Static 8192 wastes budget on small changes, starves large reviews |
| `complexity-assessment` | Add automatic intent confirmation gating: SIMPLE=auto-execute, STANDARD=confirm-plan, COMPLEX=confirm-plan-and-approach | Addresses 18 wrong-approach events |
| `context-folding` | Add progressive summarization with 3-layer output (Index/Details/Deep-Dive) | Reduces context rot in long agent chains |
| `research-orchestration` | Add result deduplication, cross-agent conflict detection, confidence-weighted synthesis | Multiple agents often produce overlapping findings |

#### New Agents

| Agent | Focus | Rationale |
|-------|-------|-----------|
| `sprint-orchestrator` | PM agent: decomposes issues, creates dependency graph, dispatches dev agents in batches, triggers review on completion | Enables autonomous sprint execution |
| `environment-validator` | Pre-session validation agent: checks all tools, configs, tokens, dependencies | Reduces 12 environment error events to near-zero |

#### Hook Improvements

| Hook | Event | Action |
|------|-------|--------|
| `PreToolUse:Bash` | Before shell commands | Validate not running destructive commands on wrong branch |
| `PreToolUse:Write` | Before file writes | Run gitleaks on content before writing secrets to disk |
| `PreToolUse:Bash` | Before `git commit` | Run `go vet`, `go test ./...`, gitleaks pre-commit |
| `PostToolUse:Bash` | After `go build` | Check for govulncheck warnings |
| `PreCompact` | Before context compaction | Auto-checkpoint to contextd |

### contextd Plugin

#### Improvements

| Area | Enhancement | Rationale |
|------|-------------|-----------|
| Orchestration | Add worktree-aware task dispatch: each sub-task gets its own worktree | Industry standard for parallel isolation |
| Orchestration | Add dependency graph resolution: topological sort for task ordering | Enables batch execution with dependencies |
| Memory | Auto-capture wrong-approach events as negative preferences | Reduces repeat mistakes across sessions |
| Memory | Add structured feedback loop: after each session, prompt for satisfaction rating | Builds preference model over time |
| Checkpoint | Automatic checkpoint after each phase completion, not just manual | Enables resume after crashes |
| Checkpoint | Add event-sourced state model for deterministic replay | Allows debugging failed workflows |

### fs-design Plugin

#### Improvements

| Area | Enhancement | Rationale |
|------|-------------|-----------|
| Hooks | Add `PostToolUse:Write` hook for CSS/Tailwind files to auto-check design compliance | Shift-left from manual `check` command |
| Agents | Add `fs-design:migration-agent` for systematic CSS-to-Tailwind migration | User's contextd project required this repeatedly |

---

## 3. New User-Level Skills

Skills to place at `~/.claude/skills/` for cross-project use.

### `session-preflight`

**Description:** Comprehensive pre-session validation and auto-remediation.
**Trigger:** Automatically at session start, or `/preflight`.
**Outline:**
1. Check git identity (user.name, user.email) -- auto-configure if missing
2. Check current branch -- warn if main, suggest feature branch
3. Check Go toolchain version and `go mod tidy` status
4. Verify gitleaks is installed
5. Check API token freshness (GitHub CLI `gh auth status`)
6. Report results as structured checklist

### `intent-confirmation`

**Description:** Structured intent disambiguation before executing non-trivial tasks.
**Trigger:** When complexity assessment returns STANDARD or COMPLEX.
**Outline:**
1. Parse user request into: goal, constraints, non-goals, success criteria
2. Present plan with specific files/branches/tools to be used
3. Wait for user confirmation before proceeding
4. Record confirmed intent in contextd for reference during execution
5. If user says "wrong approach" during execution, auto-pause and re-confirm

### `batch-operations`

**Description:** Pre-built `claude -p` commands for common batch operations.
**Trigger:** Manual invocation via shell scripts.
**Outline:**
1. Security audit: scan all files for secrets, check dependencies, output report
2. Lint/format: run `gofmt`, `go vet`, `staticcheck` across project
3. TDD bug fix: given failing test, iterate until green
4. Sprint batch: process GitHub issues in dependency order

### `smart-defaults`

**Description:** Project-aware default configuration based on codebase analysis.
**Trigger:** At session start after preflight.
**Outline:**
1. Detect project language (Go, check for go.mod)
2. Set default branch conventions (main vs master)
3. Configure tool preferences (standalone Tailwind vs npm, gofmt vs prettier)
4. Load previous session preferences from contextd
5. Apply CLAUDE.md overrides

---

## 4. Implementation Roadmap

| Phase | Enhancement | Plugin | Effort | Impact | Dependencies |
|-------|------------|--------|--------|--------|--------------|
| 1 | Expanded PreToolUse hooks (branch validation, secrets scan, pre-commit checks) | fs-dev | S | High | None |
| 1 | `session-preflight` user skill with auto-remediation | user-level | S | High | None |
| 1 | `intent-confirmation` user skill with complexity gating | user-level | S | High | complexity-assessment skill |
| 2 | Adaptive budget allocation in consensus-review | fs-dev | M | High | None |
| 2 | Auto-checkpoint in contextd after phase completion | contextd | M | Med | None |
| 2 | `smart-defaults` user skill | user-level | S | Med | contextd |
| 3 | `worktree-management` skill for parallel agent dispatch | fs-dev | M | High | None |
| 3 | Additional consensus protocols (supermajority, AAD, CI) | fs-dev | M | Med | consensus-review skill |
| 3 | Progressive summarization in context-folding | fs-dev | M | Med | None |
| 4 | `sprint-orchestrator` agent | fs-dev | L | High | worktree-management, github-planning |
| 4 | `tdd-pipeline` skill | fs-dev | M | Med | None |
| 4 | GitGuardian MCP integration for real-time secrets scanning | fs-dev | M | Med | MCP server setup |
| 5 | `audit-trail` skill with UUID tracking | fs-dev | M | Med | None |
| 5 | Dependency graph resolution in contextd orchestration | contextd | L | Med | contextd:orchestration |
| 5 | Headless mode batch scripts | user-level | S | Med | None |

---

## 5. Headless Mode Scripts

### Security Audit Script

```bash
#!/bin/bash
# security-audit.sh - Run comprehensive security scan
claude -p "Run a security audit on this project:
1. Run 'gitleaks detect --source .' and report any findings
2. Run 'govulncheck ./...' and report any vulnerable dependencies
3. Check go.sum for any untrusted or outdated dependencies
4. Review all files matching '*.go' for hardcoded secrets, API keys, or credentials
5. Check for any TODO/FIXME comments related to security
Output a structured report with severity levels (CRITICAL/HIGH/MEDIUM/LOW)." \
  --output-format json 2>/dev/null
```

### Lint/Format Script

```bash
#!/bin/bash
# lint-format.sh - Run Go linting and formatting
claude -p "Run the following quality checks on this Go project:
1. Run 'gofmt -l .' and list any unformatted files
2. Run 'go vet ./...' and report any issues
3. Run 'staticcheck ./...' if available, otherwise skip
4. Run 'go test ./...' and report test results
5. Check for any files that don't follow the project's naming conventions
If any issues are found, fix them and create a commit with message 'chore: lint and format'." \
  --allowedTools Edit,Write,Bash 2>/dev/null
```

### Test-Driven Bug Fix Script

```bash
#!/bin/bash
# tdd-fix.sh - Test-driven bug fixing
# Usage: ./tdd-fix.sh "description of the bug" "path/to/relevant/file.go"
BUG_DESC="$1"
FILE_PATH="$2"

claude -p "Fix this bug using test-driven development:

Bug: ${BUG_DESC}
File: ${FILE_PATH}

Steps:
1. Write a failing test that reproduces the bug
2. Run the test to confirm it fails
3. Fix the code to make the test pass
4. Run the full test suite to ensure no regressions
5. Commit with message 'fix: ${BUG_DESC}'
6. Do NOT create a PR, just commit locally." \
  --allowedTools Edit,Write,Bash,Read 2>/dev/null
```

### Sprint Orchestration Script

```bash
#!/bin/bash
# sprint-batch.sh - Process GitHub issues in batch
# Usage: ./sprint-batch.sh <milestone-name>
MILESTONE="$1"

claude -p "Process the sprint for milestone '${MILESTONE}':

1. Run 'gh issue list --milestone \"${MILESTONE}\" --state open --json number,title,labels,body'
2. Analyze issue dependencies (look for 'depends on #N' in bodies)
3. Create a topological sort of issues by dependency
4. For each independent batch (no remaining dependencies):
   a. Create a feature branch: feat/issue-N-short-title
   b. Implement the issue
   c. Run tests
   d. Commit with 'feat: description (closes #N)'
   e. Push and create PR with 'gh pr create'
5. Report progress after each batch
6. Stop and report if any issue fails tests." \
  --allowedTools Bash,Read,Edit,Write 2>/dev/null
```

---

## Confidence Assessment

| Research Area | Confidence | Data Quality | Notes |
|---------------|------------|--------------|-------|
| Technical | HIGH | Good - multiple authoritative sources (Microsoft, Google, ACL) | Strong consensus on parallel dispatch patterns and consensus mechanisms |
| Architectural | HIGH | Good - industry practices well-documented | Git worktree patterns validated by Cursor, Claude Code, Aider implementations |
| Security | HIGH | Excellent - OWASP official framework, GitGuardian documentation | OWASP Agentic Top 10 is authoritative; PreToolUse enforcement well-documented |
| UX | MEDIUM | Good - mix of research papers and practitioner articles | Progressive disclosure well-established; preference learning less mature |
| Competitive | HIGH | Good - primary sources (product docs, official blogs) | Cursor 2.0, Claude Code Agent Teams, Aider all well-documented |

---

## Conflicts and Uncertainties

| Area | Conflict | Resolution/Note |
|------|----------|-----------------|
| Budget allocation | Technical agent suggests dynamic reallocation; current architecture uses fixed per-agent budgets | Recommend hybrid: baseline fixed + complexity multiplier. No architectural conflict. |
| Auto-merge safety | Architectural agent identifies auto-merge as desirable; Security agent flags risk of merging without human review | Security precedence: auto-merge only when consensus review passes 100% with no vetoes AND all tests pass. Human approval still required for CRITICAL severity changes. |
| Consensus protocol | Technical research shows voting better for reasoning (13.2%) but consensus better for knowledge (2.8%); current system uses single protocol | No conflict -- recommendation is to support multiple protocols gated by task type. |
| Agent autonomy | Competitive research shows trend toward more autonomy; UX research shows "wrong approach" is #1 friction point | Balance: more autonomy for well-defined tasks (tests, formatting), more confirmation for ambiguous tasks. Complexity assessment gates this. |

---

## Research Gaps

Areas where additional research or experimentation is needed:

- [ ] **Quantitative benchmarking**: No data on how much expanded PreToolUse hooks actually reduce wrong-approach events in practice -- needs A/B testing
- [ ] **Token cost modeling**: Need to model the cost impact of adaptive budgets vs fixed budgets across real PR reviews
- [ ] **Worktree cleanup**: No clear best practice for when/how to clean up worktrees after parallel agent work completes
- [ ] **Cross-agent communication**: Claude Code Agent Teams are new (Feb 2026) -- limited real-world data on patterns for inter-agent messaging vs Task tool delegation
- [ ] **Preference learning at scale**: contextd can store preferences, but no established pattern for automatically applying them to modify agent behavior
- [ ] **SBOM for Go modules**: Need to evaluate specific Go SBOM tools (e.g., `cyclonedx-gomod`) for integration feasibility

---

## Next Steps

- [ ] **Phase 1 (Week 1)**: Create expanded PreToolUse hooks in `hooks/hooks.json` -- branch validation, pre-commit checks
- [ ] **Phase 1 (Week 1)**: Create `~/.claude/skills/session-preflight/SKILL.md` with auto-remediation
- [ ] **Phase 1 (Week 1)**: Create `~/.claude/skills/intent-confirmation/SKILL.md` with complexity gating
- [ ] **Phase 2 (Week 2-3)**: Implement adaptive budget allocation in `plugins/fs-dev/skills/consensus-review/skill.md`
- [ ] **Phase 2 (Week 2-3)**: Add auto-checkpoint to `plugins/contextd/skills/orchestration/SKILL.md`
- [ ] **Phase 3 (Week 3-4)**: Create `plugins/fs-dev/skills/worktree-management/SKILL.md`
- [ ] **Phase 4 (Week 5-6)**: Create `plugins/fs-dev/agents/sprint-orchestrator.md`
- [ ] **Phase 5 (Week 7-8)**: Create audit trail skill and headless batch scripts

---

## Quick Links

- [Technical Findings](./technical.md)
- [Architectural Analysis](./architectural.md)
- [UX Considerations](./ux.md)
- [Security Analysis](./security.md)
- [Competitive Context](./competitive.md)
