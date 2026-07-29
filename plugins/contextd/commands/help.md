---
name: help
description: List all available skills and commands for contextd Claude Code plugin.
---

# contextd Help

List all available skills and commands for contextd Claude Code plugin.

## Commands

Commands are invoked with `/contextd:<command>`.

| Command | Description |
|---------|-------------|
| `/contextd:search <query>` | Search across memories and remediations |
| `/contextd:remember` | Record a learning or insight from current session |
| `/contextd:checkpoint` | Save a checkpoint of current session state |
| `/contextd:diagnose <error>` | Diagnose an error using AI analysis and past fixes |
| `/contextd:status` | Show contextd status for current project |
| `/contextd:init` | Initialize contextd for a project (use `--full` for existing codebases) |
| `/contextd:reflect` | Analyze behavior patterns and improve docs |
| `/contextd:consensus-review <path>` | Run multi-agent code review on files/directory |
| `/contextd:help` | Show this help message |

## Skills

Skills are activated automatically based on context or can be referenced with `@contextd:<skill-name>`.

| Skill | Description |
|-------|-------------|
| `using-contextd` | Canonical reference for all contextd tools |
| `workflow` | Pre/work/post-flight flow for sessions |
| `setup` | Onboarding, CLAUDE.md generation, policies |
| `orchestration` | Multi-task execution with parallel agents |
| `self-reflection` | Analyze behavior patterns, improve skills/docs |

## MCP Tools

Low-level tools available via `mcp__contextd__*`:

| Tool | Purpose |
|------|---------|
| `memory_search` | Find relevant past strategies (supports category filter) |
| `memory_record` | Save new memory (auto-classifies category if omitted) |
| `memory_feedback` | Rate memory helpfulness (adjusts confidence) |
| `memory_outcome` | Report task success/failure after using a memory |
| `memory_consolidate` | Flush session buffer (session granularity mode) |
| `memory_consolidate_session` | Flush session turns into session-level memories |
| `checkpoint_save` | Save context snapshot |
| `checkpoint_list` | List available checkpoints |
| `checkpoint_resume` | Resume from checkpoint |
| `remediation_search` | Find error fix patterns |
| `remediation_record` | Record new fix |
| `remediation_feedback` | Rate whether a fix was helpful |
| `repository_index` | Index repo for semantic search |
| `semantic_search` | Smart search with semantic understanding + grep fallback (accepts optional `collection_name` to search a specific collection) |
| `troubleshoot_diagnose` | AI-powered error diagnosis |
| `conversation_index` | Index Claude Code conversation files |
| `conversation_search` | Search indexed conversations |
| `reflect_report` | Generate self-reflection report on memories and patterns |
| `reflect_analyze` | Analyze behavioral patterns in memories |
| `branch_create` | Create isolated context branch with token budget |
| `branch_return` | Return from branch with scrubbed results |
| `branch_status` | Get branch status and budget usage |

## Quick Start

```
1. /contextd:status           - See what contextd knows
2. /contextd:search <topic>   - Find relevant memories
3. Do your work
4. /contextd:remember         - Record what you learned
5. /contextd:checkpoint       - Save before clearing context
```

## Getting Started with Skills

Reference skills in conversation:
- "Use the @contextd:workflow skill for session flow"
- "Apply @contextd:setup to create CLAUDE.md"
- "Follow @contextd:orchestration for multi-agent task execution"

## Additional Features

These features are documented but not exposed as commands:

- **Installation**: See contextd README for installation via Homebrew, binary, or Docker
- **Statusline**: Configure with `ctxd statusline install --server http://localhost:9090`
- **Checkpoint Resume**: Handled automatically by SessionStart hook

## Error Handling

@_error-handling.md
