# CLAUDE.md - Marketplace

**Status**: Active Development
**Version**: 1.12.0
**Last Updated**: 2026-06-01

---

## Critical Rules

**ALWAYS** follow Claude Code plugin conventions
**ALWAYS** apply git-repo-standards and git-workflows skills to projects
**NEVER** commit credentials or API keys to the repository
**OPTIONAL** use contextd for cross-session memory (if MCP server available)

---

## Project Overview

A Claude Code plugin marketplace providing skills, commands, and agents for fyrsmithlabs project standards and workflows. Contains multiple plugins that can be installed independently.

## Architecture

```
marketplace/
├── .claude-plugin/      # Root marketplace manifest
│   └── marketplace.json # Multi-plugin registry
├── plugins/             # All plugins
│   ├── fs-dev/                # Core development plugin
│   │   ├── .claude-plugin/    # Plugin manifest
│   │   ├── commands/          # 12 commands (/fs-dev:init, /fs-dev:plan, etc.)
│   │   ├── agents/            # 16 subagents (6 reviewers + 7 research + 1 product-owner + 2 automation)
│   │   ├── skills/            # 14 skills (standards, workflows, planning, validation)
│   │   └── includes/          # Shared includes for skills/agents
│   ├── cc-skills-golang/      # External Go skills plugin (github: samber/cc-skills-golang)
│   ├── contextd/              # Cross-session memory plugin
│   │   ├── .claude-plugin/    # Plugin manifest
│   │   ├── agents/            # 2 contextd agents
│   │   ├── skills/            # 5 contextd skills
│   │   └── commands/          # 8 contextd commands
│   ├── fs-design/             # Design system plugin
│   │   ├── .claude-plugin/    # Plugin manifest
│   │   ├── agents/            # 2 design agents
│   │   ├── skills/            # 1 skill (design-check)
│   │   └── commands/          # 1 command (/fs-design:check)
│   └── open-policy-agent/     # OPA/Rego policy plugin
│       ├── .claude-plugin/    # Plugin manifest
│       ├── agents/            # 4 agents (validator, spec-gen, reviewer, test-gen)
│       ├── skills/            # 7 skills (rego, testing, toolchain, platforms, benchmarks, specs, migration)
│       ├── commands/          # 6 commands (/opa:write, /opa:validate, etc.)
│       ├── hooks/             # PreToolUse hook for .rego validation
│       └── includes/          # Shared OPA conventions
└── hooks/               # Claude Code hooks
    ├── hooks.json       # Lifecycle hooks (PreCompact + PreToolUse)
    ├── precompact.sh    # Auto-checkpoint before context compaction
    ├── pre-commit-secrets.sh  # Gitleaks scan before git commit
    └── branch-guard.sh  # Branch protection for writes/pushes
```

## Plugins

This marketplace contains five plugins. Four are maintained in-tree; `cc-skills-golang` is referenced externally via a GitHub source.

| Plugin | Version | Category | Description |
|--------|---------|----------|-------------|
| `fs-dev` | v1.11.0 | development | Core standards, workflows, planning |
| `cc-skills-golang` | external | development | Go development skills (github: samber/cc-skills-golang) |
| `contextd` | v1.2.0 | memory | Cross-session memory and learning |
| `fs-design` | v1.0.0 | design | Design system compliance |
| `open-policy-agent` | v0.1.0 | security | OPA/Rego policy authoring, validation, benchmarks |

---

## fs-dev Plugin

Core development standards, workflows, and GitHub integration.

### Core Skills

| Skill | Purpose |
|-------|---------|
| `git-repo-standards` | Repository naming, structure, README, CHANGELOG, LICENSE, gitleaks |
| `git-workflows` | Multi-agent consensus review, PR requirements, branching |
| `init` | Set up projects to follow fyrsmithlabs standards |
| `yagni` | YAGNI/KISS enforcement with structured nudges |
| `complexity-assessment` | Task complexity evaluation (SIMPLE/STANDARD/COMPLEX) |
| `github-planning` | GitHub Issues/Projects integration |
| `roadmap-discovery` | Codebase analysis with lens filtering |
| `product-owner` | Daily standups, priority synthesis, cross-project dependencies |
| `context-folding` | Context isolation for complex sub-tasks |
| `agent-artifacts` | Agent file placement conventions (docs/.claude/) |
| `consensus-review` | Multi-agent code review with adaptive budgets and veto power |
| `research-orchestration` | Parallel research agent dispatch and synthesis |
| `preflight-validation` | Multi-layer environment validation with auto-remediation |
| `intent-confirmation` | Structured intent disambiguation gated by complexity tier |

### Review Agents

| Agent | Focus | Veto |
|-------|-------|------|
| `security-reviewer` | Injection, auth, secrets, OWASP | Yes |
| `vulnerability-reviewer` | CVEs, deps, supply chain | Yes |
| `code-quality-reviewer` | Logic, complexity, patterns | Yes |
| `documentation-reviewer` | README, API docs, CHANGELOG | Yes |
| `user-persona-reviewer` | UX, breaking changes, ergonomics | Yes |
| `go-reviewer` | Effective Go, concurrency, error handling | Yes |

### Research Agents

| Agent | Focus |
|-------|-------|
| `research-orchestrator` | Dispatches and coordinates research agents |
| `research-technical` | APIs, libraries, frameworks, implementation patterns |
| `research-architectural` | Design patterns, system structure, code organization |
| `research-security` | Security best practices, OWASP, vulnerability patterns |
| `research-ux` | User experience, accessibility, usability patterns |
| `research-competitive` | Industry trends, competitor analysis, market context |
| `research-synthesis` | Consolidates findings from all research agents |

### Automation Agents

| Agent | Purpose |
|-------|---------|
| `product-owner` | Priority analysis, cross-project dependencies, strategic recommendations |
| `environment-validator` | Pre-session environment validation (git, tools, tokens) |
| `sprint-orchestrator` | Autonomous sprint execution with dependency graphing and merge orchestration |

### Key Commands

| Command | Purpose |
|---------|---------|
| `/fs-dev:init` | Set up project standards |
| `/fs-dev:yagni` | Manage YAGNI settings |
| `/fs-dev:plan` | Full planning workflow |
| `/fs-dev:standup` | Daily standup with GitHub synthesis |
| `/fs-dev:test-skill` | Run pressure tests |
| `/fs-dev:discover` | Codebase analysis |
| `/fs-dev:brainstorm` | Feature design workflow |
| `/fs-dev:consensus-review` | Multi-agent code review with veto power |
| `/fs-dev:research` | Multi-agent research orchestration |

---

## contextd Plugin

Cross-session memory and learning via the contextd MCP server.

### Skills

| Skill | Purpose |
|-------|---------|
| `contextd:using-contextd` | Core tools introduction |
| `contextd:setup` | Project onboarding and CLAUDE.md management |
| `contextd:workflow` | Session lifecycle management |
| `contextd:orchestration` | Multi-task execution with parallel agents |
| `contextd:self-reflection` | Behavior pattern analysis |

### Agents

| Agent | Purpose |
|-------|---------|
| `contextd:task-agent` | Unified debugging, refactoring, architecture analysis |
| `contextd:orchestrator` | Multi-agent workflow with context-folding |

### Commands

| Command | Purpose |
|---------|---------|
| `/contextd:search` | Semantic search across memories |
| `/contextd:remember` | Record learnings from session |
| `/contextd:checkpoint` | Save session state |
| `/contextd:diagnose` | Error analysis with AI |
| `/contextd:status` | Show contextd status |
| `/contextd:reflect` | Analyze patterns, improve policies |
| `/contextd:orchestrate` | Execute multi-task orchestration plans |
| `/contextd:help` | List available commands |

---

## fs-design Plugin

Terminal Elegance design system compliance checking.

### Skills

| Skill | Purpose |
|-------|---------|
| `fs-design:check` | Design system compliance checking and reporting |

### Agents

| Agent | Purpose |
|-------|---------|
| `fs-design:consistency-reviewer` | Audit files for design system compliance |
| `fs-design:task-executor` | Execute design system refactoring |

### Commands

| Command | Purpose |
|---------|---------|
| `/fs-design:check [path]` | Audit files for design system violations |

### Capabilities

- Reports hardcoded colors, spacing, fonts, z-index values
- Checks accessibility (alt text, ARIA labels, focus states)
- Validates brand name consistency in documentation
- Report-only tool, does not auto-fix issues

---

## open-policy-agent Plugin

OPA/Rego policy authoring, validation, testing, and benchmark-aligned spec generation.

### Skills

| Skill | Purpose |
|-------|---------|
| `rego-language` | Rego v1 syntax, idioms, built-in functions, safe navigation |
| `opa-testing` | `opa test` framework, mocking, coverage, Conftest patterns |
| `opa-toolchain` | OPA CLI, Regal linter, bundle management, CI/CD |
| `policy-platforms` | K8s (Gatekeeper), Terraform, Docker, Envoy platform patterns |
| `security-benchmarks` | CIS, SOC2, HIPAA, PCI-DSS, NIST control mappings |
| `spec-driven-policy` | Spec-first workflow with benchmark research and approval gates |
| `rego-v1-migration` | Rego v0 to v1 migration patterns and tooling |

### Agents

| Agent | Purpose |
|-------|---------|
| `policy-validator` | Validates syntax, lint, tests, benchmark alignment |
| `spec-generator` | Researches benchmarks, generates SPEC.md |
| `policy-reviewer` | Security gap analysis and benchmark coverage review |
| `test-generator` | Generates comprehensive `_test.rego` suites |

### Commands

| Command | Purpose |
|---------|---------|
| `/opa:write <platform> <component>` | Guided policy creation with spec and tests |
| `/opa:validate [path]` | Full validation pipeline |
| `/opa:test [path]` | Generate and run test suites |
| `/opa:spec <platform> <component>` | Create benchmark-aligned policy spec |
| `/opa:review [path]` | Deep security review against benchmarks |
| `/opa:migrate [path]` | Migrate Rego v0 to v1 syntax |

---

## cc-skills-golang Plugin (external)

Go development skills referenced from an external repository rather than vendored
in-tree. The marketplace entry uses a GitHub source, so Claude Code resolves and
installs it directly from upstream.

- **Source**: https://github.com/samber/cc-skills-golang (`samber/cc-skills-golang`)
- **Auto-installed with fs-dev**: `fs-dev` declares `cc-skills-golang` in its
  `dependencies` array, so installing fs-dev resolves and installs this plugin
  from upstream automatically. Both live in this marketplace, so the dependency
  resolves in-marketplace (no `allowCrossMarketplaceDependenciesOn` needed).
- **Provides**: 40+ atomic, cross-referencing Go skills — code quality, architecture,
  concurrency, testing, performance, DI frameworks, and tooling.
- **Replaces**: the former in-tree `effective-go` skill, which was a single-skill
  subset of this coverage. The `go-reviewer` consensus agent now references these
  skills for Go pattern validation.
- **Maintenance**: owned upstream by samber; version is tracked by the external repo,
  not this marketplace. Pin a specific release by adding `"ref"`/`"sha"` to the
  plugin's `source` block in `marketplace.json` if reproducibility is needed.

---

## Code Standards

- Plugin artifacts follow Claude Code conventions
- Use kebab-case for all component names
- Skills can optionally integrate with contextd (memory, remediation, checkpoints)
- Templates go in `skills/<skill-name>/templates/`
- Agents output structured JSON for consensus review integration

## Known Pitfalls

- **Hook prompts are LLM instructions, not executable code** - Variables in hooks/templates (e.g., `{{filename}}`) are documentation for the LLM, not shell interpolation
- **Template variables** use Go's `text/template` which handles escaping; they're not directly user-controlled
- **Security reviewers may flag "injection"** in prompts - this is expected; the prompts instruct the LLM what to analyze
- **Verify all SKILL.md reference file paths exist on disk** - Skills reference files in `references/` that may not have been created yet; always check before release
- **Pressure test skills before release** - Use `/fs-dev:test-skill` with adversarial scenarios; harden HIGH-risk patterns with explicit "DO NOT" / "CRITICAL" warnings in skill body

## ADRs (Architectural Decisions)

<!-- Format: ADR-NNN: Title, Status, Context, Decision, Consequences -->
