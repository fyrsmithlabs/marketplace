# CLAUDE.md - Marketplace

**Status**: Active Development
**Version**: 1.2.0
**Last Updated**: 2026-01-20

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
├── commands/            # 18 slash commands (9 core + 9 contextd)
├── agents/              # 7 subagents (5 reviewers + 2 contextd)
├── skills/              # 13 skills
│   ├── git-repo-standards/    # Repo naming, structure, docs
│   ├── git-workflows/         # Consensus review, PRs, branching
│   ├── init/                  # Project setup
│   ├── yagni/                 # YAGNI/KISS enforcement
│   ├── complexity-assessment/ # Task complexity
│   ├── github-planning/       # GitHub Issues/Projects
│   ├── roadmap-discovery/     # Codebase analysis
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

### Review Agents

| Agent | Focus | Veto |
|-------|-------|------|
| `security-reviewer` | Injection, auth, secrets, OWASP | Yes |
| `vulnerability-reviewer` | CVEs, deps, supply chain | Yes |
| `code-quality-reviewer` | Logic, complexity, patterns | No |
| `documentation-reviewer` | README, API docs, CHANGELOG | No |
| `user-persona-reviewer` | UX, breaking changes, ergonomics | No |

### Key Commands

| Command | Purpose |
|---------|---------|
| `/init` | Set up project standards |
| `/yagni` | Manage YAGNI settings |
| `/plan` | Full planning workflow |
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

## Known Pitfalls

- **Hook prompts are LLM instructions, not executable code** - Variables in hooks/templates (e.g., `{{filename}}`) are documentation for the LLM, not shell interpolation
- **Template variables** use Go's `text/template` which handles escaping; they're not directly user-controlled
- **Security reviewers may flag "injection"** in prompts - this is expected; the prompts instruct the LLM what to analyze

## ADRs (Architectural Decisions)

<!-- Format: ADR-NNN: Title, Status, Context, Decision, Consequences -->
