# Marketplace

A Claude Code plugin providing skills, commands, and agents for fyrsmithlabs project standards and workflows.

## Overview

This plugin provides:
- **Repository Standards** - Naming conventions, structure, documentation requirements
- **Git Workflows** - Multi-agent consensus review, PR requirements, branching strategy
- **Project Onboarding** - Initialize or onboard projects to fyrsmithlabs standards

## Structure

```
marketplace/
├── .claude-plugin/           # Plugin manifest
├── commands/                 # Slash commands
│   └── onboard.md           # /onboard command
├── agents/                   # Subagents
├── skills/
│   ├── git-repo-standards/  # Repo standards skill
│   │   ├── SKILL.md
│   │   └── templates/
│   ├── git-workflows/       # Workflow skill
│   │   ├── SKILL.md
│   │   └── templates/
│   └── project-onboarding/  # Onboarding skill
│       └── SKILL.md
└── hooks/
    └── hooks.json           # Enforcement hooks
```

## Skills

| Skill | Description |
|-------|-------------|
| `git-repo-standards` | Repository naming, structure, README, CHANGELOG, LICENSE, gitleaks |
| `git-workflows` | 5-agent consensus review, PR requirements, trunk-based branching |
| `project-onboarding` | Initialize new projects or onboard existing repos |

## Commands

| Command | Description |
|---------|-------------|
| `/onboard` | Onboard existing project to standards |
| `/onboard init` | Initialize new project from scratch |
| `/onboard validate` | Audit compliance without changes |

## Installation

Add to your Claude Code plugins or install via the marketplace.

## Usage

```
# Onboard an existing project
/onboard

# Create a new project
/onboard init

# Check compliance
/onboard validate
```

## contextd Integration

This plugin integrates deeply with contextd:
- `memory_search` / `memory_record` - Cross-session learning
- `remediation_search` / `remediation_record` - Error pattern tracking
- `branch_create` / `branch_return` - Context folding for agent isolation
- `checkpoint_save` / `checkpoint_resume` - State preservation

## License

AGPL-3.0
