# fs-dev Plugin Documentation

**Version:** 1.6.8
**Category:** Development
**Description:** Core development standards, workflows, and GitHub integration for fyrsmithlabs projects.

---

## Overview

The fs-dev plugin provides comprehensive development standards, multi-agent code review workflows, and GitHub integration for Claude Code. It includes skills for repository setup, code quality enforcement, and planning workflows that integrate with GitHub Issues and Projects.

### Installation

```bash
# Install via Claude Code plugin marketplace
claude plugin install fyrsmithlabs/marketplace/fs-dev
```

### Activation

The plugin activates automatically when installed. Skills trigger based on context detection, and commands are available via `/command-name` syntax.

---

## Skills

| Name | Purpose | Triggers |
|------|---------|----------|
| `git-repo-standards` | Enforce repository naming conventions, structure, required files (README, CHANGELOG, LICENSE, .gitignore, .gitleaks.toml), and badge requirements | "create repo", "new repository", "set up project", "repo standards", "repository structure", or when creating/auditing repositories |
| `git-workflows` | Multi-agent consensus review with veto power, PR requirements, branching strategy, and fyrsmith-workflow.yml configuration | "review code", "create PR", "pull request", "consensus review", "code review", or when preparing code for review |
| `init` | Interactive project setup wizard that detects project type, configures language-specific tooling, generates CLAUDE.md, and validates against standards | "init this repo", "initialize project", "set up standards", "make this follow fyrsmithlabs standards" |
| `yagni` | YAGNI/KISS enforcement with severity scoring, pattern detection, technical debt tracking, and whitelist management | Automatically triggered on Write/Edit operations; manual via `/yagni` command |
| `complexity-assessment` | Evaluate task complexity into tiers (SIMPLE/STANDARD/COMPLEX) to determine appropriate planning depth and agent involvement | "assess complexity", "how complex is this", "plan this feature", or automatically during `/brainstorm` |
| `github-planning` | Create GitHub Issues, native sub-issues, Projects v2 boards, milestones, and YAML issue templates based on complexity tier | Called by `/brainstorm` Phase 6; "create issues", "set up project board", "github planning" |
| `roadmap-discovery` | Codebase analysis with configurable lenses (architecture, security, performance, testing, documentation) for understanding existing projects | "discover codebase", "analyze architecture", "understand this project", "roadmap discovery" |
| `product-owner` | Daily standups with GitHub synthesis, priority analysis, cross-project dependency detection, and strategic recommendations | "standup", "what should I work on", "priorities", "daily status" |
| `context-folding` | Context isolation for complex sub-tasks using contextd branch_create/branch_return to prevent context pollution | Automatically used during complex agent workflows; "isolate context", "context branch" |
| `effective-go` | Idiomatic Go development guidance based on Effective Go, covering naming, error handling, concurrency, and package design | Triggered when working with Go files; "go best practices", "idiomatic go", "effective go" |

---

## Agents

| Name | Focus Area | Veto Power |
|------|------------|------------|
| `security-reviewer` | Injection vulnerabilities (SQL, XSS, command), authentication/authorization flaws, secrets exposure, OWASP Top 10, input validation, cryptographic issues | Yes |
| `vulnerability-reviewer` | CVE detection, dependency vulnerabilities, supply chain attacks, outdated packages, known exploits, SBOM analysis | Yes |
| `code-quality-reviewer` | Code logic correctness, complexity metrics, design patterns, DRY violations, error handling, maintainability, test coverage | Yes |
| `documentation-reviewer` | README completeness, API documentation, CHANGELOG updates, inline comments, example code, breaking change documentation | Yes |
| `user-persona-reviewer` | User experience impact, breaking changes, API ergonomics, migration paths, backwards compatibility, developer experience | Yes |
| `go-reviewer` | Effective Go compliance, concurrency patterns (goroutines, channels, mutexes), error handling idioms, package design, interface usage | Yes |
| `product-owner` | Priority analysis, cross-project dependencies, strategic alignment, risk assessment, resource allocation recommendations | N/A (Strategic) |

### Consensus Review Process

The consensus review uses parallel agent execution with adaptive budgets and context isolation:

1. **Parallel Initialization**: Scope detection and file indexing run concurrently
2. **Adaptive Budget Calculation**: `scale = min(4.0, 1.0 + total_tokens / 16384)` applied to base budgets
3. **Context Isolation**: Branch mode for scopes >16K tokens, shared mode for smaller scopes
4. **Parallel Review**: All agents analyze changes simultaneously with calculated budgets
5. **Progressive Summarization**: Agents adapt output based on budget (full → high-severity → force return)
6. **Veto Enforcement**: All agents can veto; use `--ignore-vetos` for advisory mode

### Budget Allocation

| Agent | Base Budget | Max Budget (4x) |
|-------|-------------|-----------------|
| security-reviewer | 8,192 | 32,768 |
| vulnerability-reviewer | 8,192 | 32,768 |
| go-reviewer | 8,192 | 32,768 |
| code-quality-reviewer | 6,144 | 24,576 |
| documentation-reviewer | 4,096 | 16,384 |
| user-persona-reviewer | 4,096 | 16,384 |

### Progressive Summarization

Agents adapt analysis based on budget consumption:

| Budget Used | Mode | Behavior |
|-------------|------|----------|
| 0-80% | Full Analysis | All severities, detailed evidence |
| 80-95% | High Severity Only | CRITICAL/HIGH only, concise evidence |
| 95%+ | Force Return | Stop immediately, `partial: true` |

---

## Commands

| Command | Purpose | Example Usage |
|---------|---------|---------------|
| `/init` | Set up project to follow fyrsmithlabs standards with interactive wizard, auto-detection, and compliance checking | `/init` (full wizard), `/init --check` (audit only), `/init --quick` (skip wizard), `/init --validate` (check for drift) |
| `/yagni` | Manage YAGNI/KISS enforcement settings, view status, understand nudges, toggle on/off, manage whitelist | `/yagni` (status), `/yagni config` (adjust settings), `/yagni why` (explain last nudge), `/yagni whitelist "*Factory*"` |
| `/plan` | Full planning workflow combining complexity assessment, design, and GitHub artifact creation | `/plan "Add user authentication"` |
| `/standup` | Daily standup with GitHub PR/Issue synthesis, blocker identification, and priority recommendations | `/standup` (today's status), `/standup --week` (weekly summary) |
| `/test-skill` | Run pressure tests on skills to validate behavior under edge cases | `/test-skill git-repo-standards`, `/test-skill --all` |
| `/discover` | Codebase analysis with lens filtering for architecture, security, performance, testing, or documentation focus | `/discover` (full analysis), `/discover --lens security` (security focus) |
| `/brainstorm` | Feature design workflow with complexity assessment, requirements gathering, design decisions, and GitHub planning | `/brainstorm "Add OAuth support"` |
| `/consensus-review` | Multi-agent code review with parallel execution and veto power for security/vulnerability/go issues | `/consensus-review` (review staged changes), `/consensus-review --strict` (all findings must pass) |
| `/app-interview` | Comprehensive app ideation interview with competitor analysis and differentiation strategies | `/app-interview` (new interview), `/app-interview --reuse` (continue previous) |
| `/comp-analysis` | Generate executive summary of competitor analysis from previous app-interview sessions | `/comp-analysis` (find automatically), `/comp-analysis path/to/competition.json` |
| `/spec-refinement` | Conduct in-depth interview about a specification file to refine technical details and edge cases | `/spec-refinement docs/feature.spec.md` |

---

## Recordings

Demo recordings for each command (placeholder links):

- [`/init`](../recordings/init.cast)
- [`/yagni`](../recordings/yagni.cast)
- [`/plan`](../recordings/plan.cast)
- [`/standup`](../recordings/standup.cast)
- [`/test-skill`](../recordings/test-skill.cast)
- [`/discover`](../recordings/discover.cast)
- [`/brainstorm`](../recordings/brainstorm.cast)
- [`/consensus-review`](../recordings/consensus-review.cast)
- [`/app-interview`](../recordings/app-interview.cast)
- [`/comp-analysis`](../recordings/comp-analysis.cast)
- [`/spec-refinement`](../recordings/spec-refinement.cast)

---

## Integration with contextd

The fs-dev plugin optionally integrates with the contextd MCP server for enhanced functionality:

| Feature | Without contextd | With contextd |
|---------|------------------|---------------|
| Cross-session memory | Not available | Memories persist across sessions |
| Remediation patterns | Session-only | Searchable knowledge base |
| Context folding | Basic isolation | Full branch_create/branch_return |
| Planning decisions | Not recorded | Stored for future reference |

To enable contextd integration, install the contextd plugin:

```bash
claude plugin install fyrsmithlabs/marketplace/contextd
```

---

## Related Documentation

- [contextd Plugin](./contextd.md) - Cross-session memory and learning
- [fs-design Plugin](./fs-design.md) - Design system compliance
- [Marketplace Overview](../README.md) - All available plugins
