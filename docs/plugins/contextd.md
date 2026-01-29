# contextd Plugin Documentation

**Version**: 1.1.0
**Category**: Memory
**Author**: fyrsmithlabs

Cross-session memory and learning for Claude Code. Provides semantic search, memory recording, checkpoints, error remediation, and multi-agent orchestration via the contextd MCP server.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [MCP Server Setup](#mcp-server-setup)
- [Skills](#skills)
- [Agents](#agents)
- [Commands](#commands)
- [Tool Reference](#tool-reference)
- [Core Concepts](#core-concepts)
- [Quick Start](#quick-start)
- [Error Handling](#error-handling)

---

## Prerequisites

The contextd plugin **requires** the contextd MCP server to be installed and running.

### Requirements

1. **contextd binary** - Install via Homebrew, binary download, or Docker
2. **MCP configuration** - Claude Code must be configured to connect to contextd
3. **Git repository** - Tenant ID is derived from git remote URL

### Verification

Before using contextd tools, verify availability:

1. Check for `mcp__contextd__*` tools (use ToolSearch if needed)
2. If tools are NOT available:
   - Inform user: "contextd MCP server not configured"
   - Suggest: "Run `/contextd:init` to configure contextd"
   - Alternative: Use standard Read/Grep/Glob (no cross-session memory)

---

## MCP Server Setup

### Configuration

Add to your Claude Code MCP configuration (`.mcp.json`):

```json
{
  "mcpServers": {
    "contextd": {
      "type": "stdio",
      "command": "contextd",
      "args": ["--mcp", "--no-http"]
    }
  }
}
```

### Starting the Server

```bash
# Start with MCP mode (stdio)
contextd --mcp --no-http

# Or start with HTTP endpoints for health monitoring
contextd serve
```

### Health Monitoring (HTTP Mode)

When running with HTTP, contextd exposes health endpoints:

| Endpoint | Purpose | Status Codes |
|----------|---------|--------------|
| `GET /health` | Basic health with metadata summary | 200 OK, 503 Degraded |
| `GET /api/v1/health/metadata` | Detailed per-collection status | 200 OK |

```bash
# Check health
curl -s http://localhost:9090/health | jq
# {"status":"ok","metadata":{"status":"healthy","healthy_count":22,"corrupt_count":0}}
```

### Common Errors

| Error | Meaning | Fix |
|-------|---------|-----|
| `Unknown tool: mcp__contextd__*` | MCP not configured | Run `/contextd:init` |
| `Connection refused on port 9090` | Server not running | Run `contextd serve` |
| `Tenant not found` | First use | Will auto-create |

---

## Skills

Skills are activated automatically based on context or can be referenced with `@contextd:<skill-name>`.

| Skill | Purpose | Triggers |
|-------|---------|----------|
| `using-contextd` | Core tools introduction and pre-flight protocol | Session start, first contextd operation |
| `setup` | Project onboarding and CLAUDE.md management | Joining project, creating CLAUDE.md |
| `workflow` | Session lifecycle management (start/end protocols) | Session start, checkpoint, `/clear` |
| `consensus-review` | Multi-agent parallel code review | PR review, code audit, security review |
| `orchestration` | Multi-task execution with parallel agents | Epic execution, multi-issue work |
| `self-reflection` | Behavior pattern analysis and improvement | Periodic review, after failures |

### Skill Details

#### using-contextd

Canonical reference for all contextd tools. Defines the mandatory pre-flight protocol:

**Before any filesystem operation (Read, Grep, Glob), you MUST:**

1. `semantic_search(query, project_path: ".")` - Semantic code search with auto grep fallback
2. `memory_search(project_id, query)` - Check past learnings and solutions

Skipping this is a protocol violation.

#### setup

Project onboarding workflow:

1. **Discovery** - Scan repository structure, dependencies, configuration
2. **Pattern Extraction** - Identify architecture, testing patterns, build commands
3. **CLAUDE.md Generation** - Create comprehensive project documentation
4. **Indexing** - Index repository for semantic search

Supports tech stack auto-detection: Node.js, Go, Rust, Python, Ruby, Java.

#### workflow

Session lifecycle management:

- **Session Start**: Search memories, check checkpoints, offer resume
- **Checkpoint Workflow**: Save at 70% context, before risky ops, end of session
- **Error Remediation**: Diagnose -> search past fixes -> apply -> record
- **Session End**: Re-index repository, record learnings, checkpoint if resuming later

#### consensus-review

Multi-agent code review dispatching 4 specialized reviewers in parallel:

| Reviewer | Focus Areas |
|----------|-------------|
| Security | Injection, secrets, supply chain, permissions |
| Correctness | Logic errors, schema compliance, edge cases |
| Architecture | Structure, maintainability, patterns, extensibility |
| UX/Documentation | Clarity, completeness, examples, discoverability |

Synthesizes findings with severity ratings (CRITICAL/HIGH/MEDIUM/LOW).

#### orchestration

Execute multi-task work from GitHub issues or epics:

1. **Issue Discovery** - Fetch from GitHub, extract dependencies
2. **Dependency Resolution** - Build parallel groups via topological sort
3. **Parallel Execution** - Launch task agents with context folding
4. **Consensus Review** - Run security/quality gates after each group
5. **Checkpointing** - Save progress for resume capability

Requires contextd for context isolation via `branch_create`/`branch_return`.

#### self-reflection

Analyze memories and remediations for behavior patterns:

**Behavioral Taxonomy:**

| Behavior Type | Description |
|---------------|-------------|
| rationalized-skip | Justified skipping required step |
| overclaimed | Used absolute language inappropriately |
| ignored-instruction | Didn't follow CLAUDE.md/skill directive |
| assumed-context | Assumed without verification |
| undocumented-decision | Significant choice without rationale |

Includes causal chain analysis, comparative benchmarks, and behavioral prediction.

---

## Agents

Agents are specialized sub-agents that can be dispatched for complex tasks.

| Agent | Capabilities |
|-------|--------------|
| `task-agent` | Unified debugging, refactoring, architecture analysis, and general execution. Auto-detects mode based on keywords (fix/bug -> Debug, refactor -> Refactor, analyze -> Analyze, default -> Execute). Uses SRE 5-step troubleshooting for debug mode, incremental checkpoints for refactoring, semantic search for analysis. |
| `orchestrator` | Multi-agent workflow management with context-folding. Decomposes tasks into parallel sub-agents, allocates token budgets, aggregates results, and captures learnings. Use for tasks requiring 3+ specialized agents. |

### task-agent Mode Detection

| Keywords | Mode | Focus |
|----------|------|-------|
| fix, bug, error, failure, crash, broken | Debug | SRE troubleshooting flow |
| refactor, restructure, rename, extract, split | Refactor | checkpoint + incremental |
| understand, analyze, onboard, architecture | Analyze | semantic_search + document |
| (default) | Execute | memory_search + work + record |

### orchestrator Budget Allocation

| Sub-agent Role | Budget | Notes |
|----------------|--------|-------|
| Simple analysis | 6,144 tokens | Single focus area |
| Complex analysis | 10,240 tokens | Multi-file investigation |
| Deep research | 16,384 tokens | Architecture or security |
| Aggregation | 20% of total | Reserve in parent |

---

## Commands

Commands are invoked with `/contextd:<command>`.

| Command | Purpose | Example Usage |
|---------|---------|---------------|
| `/contextd:search <query>` | Search across memories, remediations, and code | `/contextd:search authentication patterns` |
| `/contextd:remember` | Record a learning or insight from current session | `/contextd:remember` (prompts for details) |
| `/contextd:checkpoint` | Save a checkpoint of current session state | `/contextd:checkpoint` (auto-generates summary) |
| `/contextd:diagnose <error>` | Diagnose an error using AI analysis and past fixes | `/contextd:diagnose "ENOENT: no such file"` |
| `/contextd:status` | Show contextd status for current project | `/contextd:status` |
| `/contextd:init [flags]` | Initialize contextd for a project | `/contextd:init --full --conversations` |
| `/contextd:reflect [flags]` | Analyze behavior patterns and improve docs | `/contextd:reflect --health` |
| `/contextd:consensus-review <path>` | Run multi-agent code review | `/contextd:consensus-review ./internal/api/` |
| `/contextd:orchestrate [issues]` | Execute multi-task orchestration | `/contextd:orchestrate 42,43,44` |
| `/contextd:help` | List all available skills and commands | `/contextd:help` |

### Command Details

#### /contextd:search

Combines results from three sources:
- **Code**: `semantic_search` with auto grep fallback
- **Memories**: `memory_search` for past learnings
- **Remediations**: `remediation_search` for error fix patterns

#### /contextd:init

| Flag | Description |
|------|-------------|
| `--full` | Run full onboarding: analyze codebase, generate CLAUDE.md |
| `--conversations` | Index past Claude Code conversations |
| `--batch` | Process offline via CLI (no context cost) |
| `--skip-claude-md` | Skip CLAUDE.md generation |

#### /contextd:reflect

| Flag | Description |
|------|-------------|
| `--health` | ReasoningBank health report only |
| `--policies` | Policy compliance report only |
| `--apply` | Apply changes with tiered defaults |
| `--scope=project\|global` | Limit to project or global docs |
| `--behavior=<type>` | Filter by behavior type |
| `--severity=CRITICAL\|HIGH\|MEDIUM\|LOW` | Filter by severity level |
| `--since=<duration>` | Analyze memories from timeframe (e.g., `7d`) |

#### /contextd:orchestrate

| Argument | Description |
|----------|-------------|
| `issues` | Comma-separated issue numbers or epic number |
| `--review-threshold` | `strict` (100%), `standard` (no vetoes), `advisory` (report only) |
| `--resume` | Resume from checkpoint name |

---

## Tool Reference

Low-level MCP tools available via `mcp__contextd__*`:

### Search Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `semantic_search` | Smart code search with semantic understanding + grep fallback | `query`, `project_path`, `limit` |
| `repository_index` | Index repository for semantic search | `path` |
| `repository_search` | Search over indexed code | `query`, `project_path`, `limit` |

### Memory Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `memory_search` | Find relevant past strategies | `project_id`, `query`, `limit` |
| `memory_record` | Save new memory explicitly | `project_id`, `title`, `content`, `outcome`, `tags` |
| `memory_feedback` | Rate memory helpfulness (adjusts confidence) | `memory_id`, `helpful` |
| `memory_outcome` | Report task success/failure after using a memory | `memory_id`, `outcome` |
| `memory_consolidate` | Merge similar memories | `similarity_threshold` |

### Checkpoint Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `checkpoint_save` | Save context snapshot | `session_id`, `tenant_id`, `project_path`, `name`, `summary`, `context` |
| `checkpoint_list` | List available checkpoints | `tenant_id`, `project_path`, `limit` |
| `checkpoint_resume` | Resume from checkpoint | `checkpoint_id`, `tenant_id`, `level` |

Resume levels: `summary` (minimal), `context` (balanced), `full` (complete)

### Remediation Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `remediation_search` | Find error fix patterns | `query`, `tenant_id`, `limit` |
| `remediation_record` | Record new fix | `title`, `problem`, `root_cause`, `solution`, `category`, `tenant_id`, `scope` |
| `troubleshoot_diagnose` | AI-powered error diagnosis | `error_message`, `error_context` |

Categories: `syntax`, `runtime`, `logic`, `config`, `dependency`, `network`, `auth`, `data`, `performance`

### Context Folding Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `branch_create` | Create isolated context branch with token budget | `session_id`, `description`, `prompt`, `budget` |
| `branch_return` | Return from branch with scrubbed results | `branch_id`, `message` |
| `branch_status` | Get branch status and budget usage | `branch_id` |

### Reflection Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `reflect_analyze` | Analyze behavior patterns | `project_id`, `period_days` |
| `reflect_report` | Generate reflection report | `format` |

---

## Core Concepts

### Tenant ID

Derived from git remote URL. Example: `github.com/fyrsmithlabs/contextd` -> `fyrsmithlabs`

Verify with:
```bash
git remote get-url origin | sed 's|.*github.com[:/]\([^/]*\).*|\1|'
```

### Project ID

Scopes memories to a specific project. Use repository name (e.g., `contextd`) or `org/repo` format for multi-org setups.

Hierarchical namespaces supported:
```
<org>/<team>/<project>/<module>

Examples:
  fyrsmithlabs/platform/contextd/api
  fyrsmithlabs/marketplace/fs-dev
```

### Confidence Score

Memories have confidence scores (0-1) that:
- Adjust via `memory_feedback(helpful=true/false)`
- Decay over time without reinforcement
- Higher scores rank first in search results

### Memory Types

| Type | Purpose | Default TTL |
|------|---------|-------------|
| `learning` | General knowledge gained | 180 days |
| `remediation` | Error -> fix mappings | 365 days |
| `decision` | ADR/architecture choices | Never |
| `failure` | What NOT to do | 365 days |
| `pattern` | Reusable code patterns | 180 days |
| `policy` | STRICT constraints | Never |

Tag memories with type: `tags: ["type:learning", "category:testing"]`

### The Learning Loop

```
1. SEARCH at task start (MANDATORY)
   semantic_search(query, project_path)
   memory_search(project_id, query)

2. DO the work
   (apply relevant memories)

3. RECORD at completion
   memory_record(project_id, title, content, outcome)

4. FEEDBACK when memories helped
   memory_feedback(memory_id, helpful)
```

---

## Quick Start

```bash
# 1. Check contextd status
/contextd:status

# 2. Search for relevant memories
/contextd:search <topic>

# 3. Do your work
# (contextd tools automatically invoked via pre-flight protocol)

# 4. Record what you learned
/contextd:remember

# 5. Save before clearing context
/contextd:checkpoint
```

### First Time Setup

```bash
# For new projects
/contextd:init

# For existing projects with code
/contextd:init --full

# To also index past conversations
/contextd:init --full --conversations
```

---

## Error Handling

### Graceful Degradation

If corrupt collections are detected, contextd quarantines them and continues operating with healthy collections. Check health status to detect degraded state.

### Partial Failures

Commands handle partial failures gracefully:

- If `semantic_search` fails: Continue with memory/remediation search
- If `memory_search` fails: Continue with other results
- If `remediation_search` fails: Continue with other results

### No Results

When no matches are found:
- Suggest broader search terms or different keywords
- Fall back to standard Read/Grep/Glob for exact matches

### Recovery

```bash
# Check health status
curl -s http://localhost:9090/health | jq

# Diagnose issues
/contextd:diagnose "metadata corruption"

# Re-index repository
mcp__contextd__repository_index(path: ".")
```

---

## Additional Resources

- **Installation**: See contextd README for installation via Homebrew, binary, or Docker
- **Statusline**: Configure with `ctxd statusline install --server http://localhost:9090`
- **Checkpoint Resume**: Handled automatically by SessionStart hook

---

*Last Updated: 2026-01-29*
