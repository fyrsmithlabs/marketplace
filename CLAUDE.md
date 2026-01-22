# CLAUDE.md - Marketplace

**Status**: Active Development
**Version**: 1.3.0
**Last Updated**: 2026-01-22

---

## Critical Rules

**ALWAYS** follow Claude Code plugin conventions
**ALWAYS** use contextd for cross-session memory and learning
**ALWAYS** apply git-repo-standards and git-workflows skills to projects
**NEVER** commit credentials or API keys to the repository

---

## Project Overview

A Claude Code plugin marketplace providing skills, commands, and agents for fyrsmithlabs project standards and workflows.

## Architecture

```
marketplace/
├── .claude-plugin/      # Plugin manifests
├── commands/            # 19 slash commands (10 core + 9 contextd)
├── agents/              # 10 subagents (5 reviewers + 1 product-owner + 2 contextd + 2 design)
├── skills/              # 15 skills
│   ├── git-repo-standards/    # Repo naming, structure, docs
│   ├── git-workflows/         # Consensus review, PRs, branching
│   ├── init/                  # Project setup
│   ├── yagni/                 # YAGNI/KISS enforcement
│   ├── complexity-assessment/ # Task complexity
│   ├── github-planning/       # GitHub Issues/Projects
│   ├── roadmap-discovery/     # Codebase analysis
│   ├── product-owner/         # Standups, priorities
│   └── contextd-*/            # 6 contextd skills
├── includes/            # Shared includes for hooks
│   └── yagni/           # Pattern detection
└── hooks/               # Claude Code hooks
    └── hooks.json       # Enforcement hooks
```

## Plugin Components

### Core Skills

| Skill | Purpose |
|-------|---------|
| `git-repo-standards` | Repository naming, structure, README, CHANGELOG, LICENSE, gitleaks |
| `git-workflows` | 5-agent consensus review with contextd, PR requirements, branching |
| `init` | Set up projects to follow fyrsmithlabs standards |
| `yagni` | YAGNI/KISS enforcement with structured nudges |
| `complexity-assessment` | Task complexity evaluation (SIMPLE/STANDARD/COMPLEX) |
| `github-planning` | GitHub Issues/Projects integration |
| `roadmap-discovery` | Codebase analysis with lens filtering |
| `product-owner` | Daily standups, priority synthesis, cross-project dependencies |
| `design-check` | Terminal Elegance design system compliance checking and reporting |

### Review Agents

| Agent | Focus | Veto |
|-------|-------|------|
| `security-reviewer` | Injection, auth, secrets, OWASP | Yes |
| `vulnerability-reviewer` | CVEs, deps, supply chain | Yes |
| `code-quality-reviewer` | Logic, complexity, patterns | No |
| `documentation-reviewer` | README, API docs, CHANGELOG | No |
| `user-persona-reviewer` | UX, breaking changes, ergonomics | No |

### Other Agents

| Agent | Purpose |
|-------|---------|
| `product-owner` | Priority analysis, cross-project dependencies, strategic recommendations |
| `design-consistency-reviewer` | Audit files for Terminal Elegance design system compliance |
| `design-task-executor` | Execute design system refactoring with user permission |

### Key Commands

| Command | Purpose |
|---------|---------|
| `/init` | Set up project standards |
| `/yagni` | Manage YAGNI settings |
| `/plan` | Full planning workflow |
| `/standup` | Daily standup with GitHub + contextd synthesis |
| `/test-skill` | Run pressure tests |
| `/contextd-*` | 9 contextd commands |

## Code Standards

- Plugin artifacts follow Claude Code conventions
- Use kebab-case for all component names
- Skills must integrate with contextd (memory, remediation, checkpoints)
- Templates go in `skills/<skill-name>/templates/`

## Skills Overview

### git-repo-standards
Enforces repository naming, structure, and documentation standards:
- Naming: `[domain]-[type]` kebab-case
- Required files: README, CHANGELOG, LICENSE, .gitignore, .gitleaks.toml
- Agent artifacts must go in `docs/.claude/` (gitignored)
- Licensing: Apache-2.0 for libs, AGPL-3.0 for services

### git-workflows
Modern agentic git workflows with multi-agent consensus review:
- 5 agents: Security, Vulnerability, Code Quality, Documentation, User Persona
- Security/Vuln have veto power
- contextd integration for learning and remediation
- Trunk-based development, squash merge only

### init
Set up projects to follow fyrsmithlabs standards:
- `/init` - Set up project (detects new vs existing)
- `/init --check` - Audit only, no modifications

### yagni
YAGNI/KISS enforcement with structured nudges:
- Non-blocking feedback when over-engineering detected
- 4 pattern types: abstraction, config-addiction, scope-creep, dead-code
- Structured tree-style output format
- Configurable sensitivity (conservative/moderate/aggressive)
- `/yagni` to manage settings

### product-owner
Daily standups and priority synthesis:
- `/standup` - Daily standup with GitHub + contextd synthesis
- `/standup --platform` - Cross-project view for all fyrsmithlabs repos
- Priority classification: CRITICAL → HIGH → DEPENDENCY ALERT → MEDIUM → CARRIED OVER
- Cross-project dependency detection
- Velocity tracking via checkpoint comparison

### design-check
Terminal Elegance design system compliance checking:
- `/design-check [path]` - Audit files for design system violations
- Reports hardcoded colors, spacing, fonts, z-index values
- Checks accessibility (alt text, ARIA labels, focus states)
- Validates brand name consistency in documentation
- Report-only tool, does not auto-fix issues

## Known Pitfalls

- **Hook prompts are LLM instructions, not executable code** - Variables in hooks/templates (e.g., `{{filename}}`) are documentation for the LLM, not shell interpolation
- **Template variables** use Go's `text/template` which handles escaping; they're not directly user-controlled
- **Security reviewers may flag "injection"** in prompts - this is expected; the prompts instruct the LLM what to analyze

## ADRs (Architectural Decisions)

<!-- Format: ADR-NNN: Title, Status, Context, Decision, Consequences -->
