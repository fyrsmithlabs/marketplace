# Architectural Research: Sprint Automation and Autonomous Development Pipelines

**Agent:** research-architectural
**Date:** 2026-03-05
**Confidence:** HIGH
**Sources:** 20+ web searches, codebase analysis of existing plugins

---

## Focus Areas Investigated

1. Issue decomposition and dependency graphing
2. Parallel execution batches with inter-task dependencies
3. Auto-merge strategies and guardrails
4. Merge conflict handling in parallel execution
5. Git worktree patterns for isolated parallel work
6. Headless/batch mode patterns for Claude Code

---

## Key Findings

### 1. Issue Decomposition and Dependency Graphing

**Confidence: HIGH**

Modern autonomous development pipelines decompose work using:

- **Task graph construction**: Parse issue descriptions for explicit dependencies ("depends on #N", "blocked by #M") and implicit dependencies (shared file edits, API contracts)
- **Topological sort**: Order tasks so dependencies complete before dependents. This is a well-solved computer science problem
- **Batch formation**: Group independent tasks (no dependencies between them) into parallelizable batches
- **Progressive batch execution**: Complete batch 1 fully, then start batch 2

**Applicable to fyrsmithlabs:** The product-owner agent already does priority synthesis. Enhancement: add formal dependency graph construction and topological sort to produce batch execution plans.

**Existing codebase patterns analyzed:**
- `plugins/fs-dev/agents/product-owner.md` -- priority analysis, no dependency graphing
- `plugins/fs-dev/skills/github-planning/SKILL.md` -- GitHub Issues integration
- `plugins/contextd/skills/orchestration/SKILL.md` -- parallel task dispatch, no dependency ordering

### 2. Git Worktree Patterns

**Confidence: HIGH**

Git worktrees have become the standard isolation mechanism for AI agent parallel work:

- Each agent gets its own worktree (separate physical directory, same repository)
- Eliminates file conflicts between parallel agents
- All linked to the same git history, enabling easy merging
- Recommended layout: main repo at `project/`, worktrees at `project-worktrees/feat-N/`

**Key patterns from 2025-2026:**
- Cursor 2.0 runs up to 8 parallel agents on separate worktrees
- Claude Code supports worktree-based parallel execution natively
- incident.io runs 4-5 parallel Claude agents routinely using worktrees
- Worktree creation is fast and space-efficient compared to full clones

**Applicable to fyrsmithlabs:** No formalized worktree management exists in the plugins. This is a high-value addition that enables sprint automation.

**Recommended worktree lifecycle:**
```
1. Create: git worktree add ../project-wt/feat-N -b feat/issue-N
2. Dispatch: claude -p "..." --cwd ../project-wt/feat-N
3. Review: consensus-review on the branch
4. Merge: git merge feat/issue-N (after review passes)
5. Cleanup: git worktree remove ../project-wt/feat-N
```

**Sources:**
- [Mastering Git Worktrees with Claude Code](https://medium.com/@dtunai/mastering-git-worktrees-with-claude-code-for-parallel-development-workflow-41dc91e645fe)
- [Using Git Worktrees for Multi-Feature Development with AI Agents](https://www.nrmitchi.com/2025/10/using-git-worktrees-for-multi-feature-development-with-ai-agents/)
- [How Git Worktrees Changed My AI Agent Workflow - Nx Blog](https://nx.dev/blog/git-worktrees-ai-agents)

### 3. Auto-Merge Strategies

**Confidence: MEDIUM**

Safe auto-merge requires multiple guardrails:

| Guardrail | Purpose | Implementation |
|-----------|---------|----------------|
| All tests pass | Functional correctness | `go test ./...` exit code 0 |
| Consensus review 100% | Code quality | No vetoes, all reviewers approve |
| No security vetoes | Security assurance | security-reviewer and vulnerability-reviewer approve |
| No merge conflicts | Clean integration | `git merge --no-commit` succeeds |
| Branch up-to-date | No stale merges | `git rebase main` before merge |
| Coverage threshold | No regression | Coverage >= baseline |

**When NOT to auto-merge:**
- Any CRITICAL severity finding
- Changes to security-sensitive files (auth, crypto, config)
- Changes that modify CI/CD pipeline configuration
- First-time contributor patterns (new file types, new dependencies)

**Applicable to fyrsmithlabs:** Auto-merge should be opt-in and gated behind all guardrails passing. Start with documentation-only PRs as the safest category.

### 4. Merge Conflict Handling

**Confidence: MEDIUM**

Strategies for handling merge conflicts in parallel execution:

1. **Prevention**: Dependency graph ensures conflicting tasks run sequentially
2. **Detection**: Pre-merge dry run with `git merge --no-commit --no-ff`
3. **Resolution**: For simple conflicts (non-overlapping changes), auto-resolve. For complex conflicts, escalate to human
4. **Rebase-first**: Rebase feature branch onto latest main before merge attempt

**Applicable to fyrsmithlabs:** The dependency graph approach (prevention) is preferred. When conflicts do occur, the sprint-orchestrator should pause, report the conflict, and wait for human resolution.

### 5. Headless/Batch Mode Patterns

**Confidence: HIGH**

Claude Code's `claude -p` flag enables headless execution:

- Pipe prompts via stdin or pass as argument
- Combine with `--allowedTools` to restrict tool access
- Use `--output-format json` for structured output parsing
- Chain multiple invocations in shell scripts
- Use `--cwd` to target specific worktrees

**Key patterns:**
```bash
# Parallel execution across worktrees
for wt in ../project-wt/feat-*; do
  claude -p "Implement the issue described in TASK.md" \
    --cwd "$wt" \
    --allowedTools Bash,Read,Edit,Write &
done
wait

# Sequential with dependency checking
claude -p "..." --output-format json | jq '.result'
```

**Sources:**
- [Git Worktree Workflow - Claude Code Ultimate Guide](https://deepwiki.com/FlorianBruniaux/claude-code-ultimate-guide/7.4-batch-operations)
- [Claude Code Hooks Guide - Pixelmojo](https://www.pixelmojo.io/blogs/claude-code-hooks-production-quality-ci-cd-patterns)

### 6. Rollback Mechanisms

**Confidence: MEDIUM**

For autonomous pipelines, rollback needs multiple layers:

1. **Git-level**: Each agent commits atomically. Rollback = `git revert` or `git reset`
2. **Branch-level**: Feature branches are never merged to main until reviewed. Rollback = delete branch
3. **Worktree-level**: Remove worktree to discard all work. Clean and fast
4. **Pipeline-level**: Track which batches completed successfully. Resume from last successful batch

---

## Recommendations for fyrsmithlabs

1. **Create `worktree-management` skill** with create/list/cleanup lifecycle
2. **Create `sprint-orchestrator` agent** that decomposes issues, builds dependency graph, dispatches in batches
3. **Add `tdd-pipeline` skill** for test-driven bug fixing workflow
4. **Create headless batch scripts** for common operations (security audit, lint, sprint)
5. **Gate auto-merge** behind 100% consensus + all tests + no CRITICAL findings
6. **Add dependency graph resolution** to contextd orchestration skill

## Codebase Patterns Analyzed

The architectural agent examined the following existing files for context:

- `plugins/fs-dev/agents/` -- 14 agents (6 reviewers, 7 research, 1 product-owner)
- `plugins/fs-dev/skills/` -- 13 skills including consensus-review, context-folding, research-orchestration
- `plugins/fs-dev/commands/` -- 12 commands
- `plugins/contextd/skills/orchestration/` -- parallel task dispatch
- `plugins/contextd/agents/` -- orchestrator, task-agent
- `plugins/fs-dev/includes/orchestration/` -- result-synthesis, consensus-review, parallel-execution patterns
