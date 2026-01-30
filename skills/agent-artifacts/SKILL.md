---
name: agent-artifacts
description: Agent artifact placement conventions. Use when creating plans, tasks, research, reviews, brainstorms, or any agent-generated files. Ensures artifacts go to docs/.claude/ (gitignored) instead of polluting the repo.
---

# Agent Artifact Placement

Agent-generated files (plans, tasks, research, reviews, orchestration output) MUST go to `docs/.claude/`, never the repo root. This directory is gitignored per git-repo-standards.

## Directory Structure

```
docs/.claude/
├── tasks/          # Todo lists, checklists, work tracking
├── plans/          # Implementation plans, design docs, architecture
├── research/       # Research results, analysis, findings
├── reviews/        # Consensus review reports, audit results
├── orchestration/  # Orchestration state, dispatch logs
└── brainstorms/    # Brainstorm sessions, ideation output
```

## Rules

1. **NEVER** write agent artifacts to the repo root (TODO.md, PLAN.md, etc.)
2. **ALWAYS** use `docs/.claude/<subdir>/` for generated files
3. **CREATE** subdirectories as needed — the structure above is the default set
4. **CHECK** `.claude/fs-dev-settings.json` for project-specific overrides

## File Routing

| Artifact Type | Directory | Examples |
|---------------|-----------|----------|
| Plans | `docs/.claude/plans/` | implementation plans, design approaches, architecture docs |
| Tasks | `docs/.claude/tasks/` | todo lists, checklists, work items |
| Research | `docs/.claude/research/` | technical research, competitive analysis, findings |
| Reviews | `docs/.claude/reviews/` | consensus review reports, code audits |
| Orchestration | `docs/.claude/orchestration/` | multi-agent dispatch state, execution logs |
| Brainstorms | `docs/.claude/brainstorms/` | brainstorm transcripts, ideation notes |

## Project Settings

Projects can customize via `.claude/fs-dev-settings.json`:

```json
{
  "agentArtifacts": {
    "baseDir": "docs/.claude",
    "allowedSubdirs": [
      "tasks", "plans", "orchestration",
      "research", "reviews", "brainstorms"
    ]
  }
}
```

If the settings file doesn't exist, use the defaults above.

## What Is NOT an Agent Artifact

These belong at the repo root — do not redirect them:

- `CLAUDE.md`, `.claude.local.md` — Claude Code configuration
- `README.md`, `CHANGELOG.md`, `LICENSE` — repo documentation
- `.gitignore`, `.gitleaks.toml` — repo configuration
- `SECURITY.md`, `CONTRIBUTING.md`, `CODEOWNERS` — repo standards
- Source code, tests, configs — normal project files
