# contextd Plugin Documentation

**Version**: 1.2.0
**Category**: Memory
**Author**: fyrsmithlabs

---

> ## ⚠️ REQUIRED: MCP Server Installation
>
> **The contextd plugin CANNOT function without the contextd MCP server.**
>
> Before using ANY contextd features, you MUST complete the [Quick Setup](#quick-setup) below.
> Without the MCP server, all `/contextd:*` commands will fail with "Unknown tool" errors.
>
> **Setup time: ~2 minutes**

---

## Quick Setup

Choose ONE installation method:

### Option A: Automated Plugin Setup (Easiest)

If you already have the marketplace plugin installed:

```bash
# Run auto-setup in Claude Code
/contextd:init
```

This automatically:
- Downloads contextd binary (or uses Docker if binary unavailable)
- Configures MCP settings in `~/.claude/settings.json`
- Validates the connection

Restart Claude Code and verify with `/contextd:status`.

### Option B: Homebrew (macOS/Linux)

```bash
# Step 1: Install via Homebrew
brew tap fyrsmithlabs/contextd https://github.com/fyrsmithlabs/contextd
brew install contextd

# Step 2: Auto-configure MCP
ctxd mcp install

# Step 3: Restart Claude Code, then verify
/contextd:status
```

### Option C: Direct Download

Download pre-built binaries from [GitHub Releases](https://github.com/fyrsmithlabs/contextd/releases):
- macOS Apple Silicon: `contextd_*_darwin_arm64.tar.gz`
- macOS Intel: `contextd_*_darwin_amd64.tar.gz`
- Linux x64: `contextd_*_linux_amd64.tar.gz`
- Windows x64: `contextd_*_windows_amd64.tar.gz`

```bash
# Step 1: Extract and install
tar xzf contextd_*.tar.gz
sudo mv contextd /usr/local/bin/

# Step 2: Auto-configure MCP
ctxd mcp install

# Step 3: Restart Claude Code, then verify
/contextd:status
```

### Option D: Build from Source (Advanced)

> **Note:** Building from source requires Go 1.21+, CGO enabled.
> Most users should use Homebrew or direct download instead.

```bash
# Prerequisites: Go 1.21+, CGO
go install github.com/fyrsmithlabs/contextd@v1.5.0

# Auto-configure MCP
ctxd mcp install

# Restart Claude Code, then verify
/contextd:status
```

### Option E: Manual MCP Configuration

If `ctxd mcp install` doesn't work, manually add to `~/.claude/settings.json`:

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

Or for project-scoped config, create `.mcp.json` in your project root:

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

Then restart Claude Code and run `/contextd:status` to verify.

---

## First Run Behavior

On first run, contextd automatically downloads required dependencies:

```
ONNX runtime not found. Downloading v1.23.0...
Downloaded to ~/.config/contextd/lib/libonnxruntime.so
Downloading fast-bge-small-en-v1.5...
```

This one-time download (~100MB) happens automatically. Subsequent runs start instantly.

---

## Troubleshooting Setup

### "Unknown tool: mcp__contextd__*"

**Cause:** MCP server not configured or Claude Code not restarted.

**Fix:**
1. Run `ctxd mcp status` to check configuration
2. If not configured, run `ctxd mcp install`
3. Restart Claude Code completely (not just the terminal)
4. Run `/contextd:status` to verify

### "contextd: command not found"

**Cause:** contextd binary not installed or not in PATH.

**Fix:**
```bash
# Check if installed
which contextd

# If not found, install via Homebrew:
brew tap fyrsmithlabs/contextd https://github.com/fyrsmithlabs/contextd
brew install contextd

# Or via Go:
go install github.com/fyrsmithlabs/contextd@v1.5.0

# Verify Go bin is in PATH
echo $PATH | grep -q "$(go env GOPATH)/bin" && echo "OK" || echo "Add $(go env GOPATH)/bin to PATH"
```

### "Connection refused" or timeout errors

**Cause:** MCP mode uses stdio, not HTTP. This error typically means wrong configuration.

**Fix:** Verify configuration with:
```bash
ctxd mcp status
```

If incorrect, reinstall:
```bash
ctxd mcp uninstall
ctxd mcp install
```

### Permission denied

**Fix:**
```bash
chmod +x ~/.local/bin/contextd
# Or if installed elsewhere:
chmod +x $(which contextd)
```

### Still not working?

1. Check Claude Code logs: `claude --debug`
2. Test contextd directly: `contextd --mcp --no-http` (should wait for input)
3. Check MCP status: `ctxd mcp status`
4. File an issue: [fyrsmithlabs/contextd](https://github.com/fyrsmithlabs/contextd/issues)

---

## What is contextd?

Cross-session memory and learning for Claude Code. Unlike standard Claude Code which starts fresh each session, contextd enables:

| Feature | Without contextd | With contextd |
|---------|------------------|---------------|
| Remember past solutions | ❌ Lost each session | ✓ Searchable memory |
| Learn from errors | ❌ Repeat mistakes | ✓ Remediation database |
| Resume interrupted work | ❌ Start over | ✓ Checkpoints |
| Search code semantically | ❌ Grep only | ✓ AI-powered search |
| Complex multi-task work | ❌ Context overflow | ✓ Context folding |

---

## First Steps After Setup

Once `/contextd:status` shows connected:

```bash
# 1. Initialize contextd for this project
/contextd:init --full

# 2. Search for existing memories (may be empty on first use)
/contextd:search <topic>

# 3. After completing work, record what you learned
/contextd:remember

# 4. Before ending session, save a checkpoint
/contextd:checkpoint
```

---

## CLI Commands Reference

### MCP Management

```bash
ctxd mcp install      # Auto-configure Claude Code MCP settings
ctxd mcp status       # Check MCP connection status
ctxd mcp uninstall    # Remove MCP configuration
```

### Utilities

```bash
ctxd health                  # Server health check
ctxd scrub <file>            # Remove secrets from files
ctxd init                    # Download ONNX runtime
ctxd migrate                 # Migrate Qdrant → chromem data
ctxd statusline install      # Configure Claude Code status display
ctxd statusline run          # Run statusline
```

---

## Advanced Configuration

### Environment Variables

Configure advanced settings via environment variables:

| Variable | Default | Purpose |
|----------|---------|---------|
| `VECTORSTORE_PROVIDER` | `chromem` | Vector database (`chromem` or `qdrant`) |
| `VECTORSTORE_PATH` | `~/.config/contextd/vectorstore` | Data storage location |
| `QDRANT_HOST` | `localhost` | Qdrant hostname |
| `QDRANT_PORT` | `6334` | Qdrant gRPC port |
| `EMBEDDING_PROVIDER` | `fastembed` | Embedding service |
| `LOG_LEVEL` | `info` | Logging verbosity |

### External Qdrant (Team Deployments)

For shared team deployments, configure a Qdrant instance:

```bash
docker run -d --name qdrant \
  -p 6333:6333 -p 6334:6334 \
  -v $(pwd)/qdrant_data:/qdrant/storage \
  qdrant/qdrant
```

Update `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "contextd": {
      "type": "stdio",
      "command": "contextd",
      "args": ["--mcp", "--no-http"],
      "env": {
        "VECTORSTORE_PROVIDER": "qdrant",
        "QDRANT_HOST": "localhost",
        "QDRANT_PORT": "6334"
      }
    }
  }
}
```

### Data Storage & Backup

Default location: `~/.config/contextd/`

```
~/.config/contextd/
├── vectorstore/       # Memories, checkpoints, error fixes
├── lib/              # ONNX runtime (auto-downloaded)
└── config.yaml       # Optional settings
```

Backup your data:
```bash
tar czf contextd-backup.tar.gz ~/.config/contextd/
```

Restore:
```bash
tar xzf contextd-backup.tar.gz -C ~/
```

### Statusline Integration

```bash
ctxd statusline install --server http://localhost:9090
```

---

## Table of Contents

- [Quick Setup](#quick-setup)
- [Troubleshooting Setup](#troubleshooting-setup)
- [What is contextd?](#what-is-contextd)
- [CLI Commands Reference](#cli-commands-reference)
- [Advanced Configuration](#advanced-configuration)
- [Skills](#skills)
- [Agents](#agents)
- [Commands](#commands)
- [Tool Reference](#tool-reference)
- [Core Concepts](#core-concepts)
- [Error Handling](#error-handling)

---

## Skills

Skills activate automatically based on context or can be referenced with `@contextd:<skill-name>`.

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

Agents are specialized sub-agents for complex tasks.

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

| Command | Purpose | Example |
|---------|---------|---------|
| `/contextd:status` | Check connection status | `/contextd:status` |
| `/contextd:init [flags]` | Initialize contextd for project | `/contextd:init --full` |
| `/contextd:search <query>` | Search memories, remediations, code | `/contextd:search auth patterns` |
| `/contextd:remember` | Record a learning from session | `/contextd:remember` |
| `/contextd:checkpoint` | Save session state | `/contextd:checkpoint` |
| `/contextd:diagnose <error>` | AI-powered error diagnosis | `/contextd:diagnose "ENOENT"` |
| `/contextd:reflect [flags]` | Analyze behavior patterns | `/contextd:reflect --health` |
| `/contextd:consensus-review <path>` | Multi-agent code review | `/contextd:consensus-review ./api/` |
| `/contextd:orchestrate [issues]` | Execute multi-task work | `/contextd:orchestrate 42,43,44` |
| `/contextd:help` | List all commands | `/contextd:help` |

### Command Flags

#### /contextd:init

| Flag | Description |
|------|-------------|
| `--full` | Analyze codebase, generate CLAUDE.md |
| `--conversations` | Index past Claude Code conversations |
| `--batch` | Process offline via CLI |
| `--skip-claude-md` | Skip CLAUDE.md generation |

#### /contextd:reflect

| Flag | Description |
|------|-------------|
| `--health` | ReasoningBank health report only |
| `--policies` | Policy compliance report only |
| `--apply` | Apply changes with tiered defaults |
| `--scope=project\|global` | Limit to project or global docs |
| `--behavior=<type>` | Filter by behavior type |
| `--severity=CRITICAL\|HIGH\|MEDIUM\|LOW` | Filter by severity |
| `--since=<duration>` | Timeframe (e.g., `7d`) |

#### /contextd:orchestrate

| Argument | Description |
|----------|-------------|
| `issues` | Comma-separated issue numbers or epic number |
| `--review-threshold` | `strict` / `standard` / `advisory` |
| `--resume` | Resume from checkpoint name |

---

## Tool Reference

Low-level MCP tools available via `mcp__contextd__*`:

### Search Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `semantic_search` | Smart code search + grep fallback | `query`, `project_path`, `limit` |
| `repository_index` | Index repository | `path` |
| `repository_search` | Search indexed code | `query`, `project_path`, `limit` |

### Memory Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `memory_search` | Find past strategies | `project_id`, `query`, `limit` |
| `memory_record` | Save new memory | `project_id`, `title`, `content`, `outcome`, `tags` |
| `memory_feedback` | Rate memory helpfulness | `memory_id`, `helpful` |
| `memory_outcome` | Report task result | `memory_id`, `outcome` |
| `memory_consolidate` | Merge similar memories | `similarity_threshold` |

### Checkpoint Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `checkpoint_save` | Save context snapshot | `session_id`, `tenant_id`, `project_path`, `name`, `summary`, `context` |
| `checkpoint_list` | List checkpoints | `tenant_id`, `project_path`, `limit` |
| `checkpoint_resume` | Resume from checkpoint | `checkpoint_id`, `tenant_id`, `level` |

Resume levels: `summary` (minimal), `context` (balanced), `full` (complete)

### Remediation Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `remediation_search` | Find error fix patterns | `query`, `tenant_id`, `limit` |
| `remediation_record` | Record new fix | `title`, `problem`, `root_cause`, `solution`, `category`, `tenant_id`, `scope` |
| `troubleshoot_diagnose` | AI error diagnosis | `error_message`, `error_context` |

Categories: `syntax`, `runtime`, `logic`, `config`, `dependency`, `network`, `auth`, `data`, `performance`

### Context Folding Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `branch_create` | Create isolated context branch | `session_id`, `description`, `prompt`, `budget` |
| `branch_return` | Return from branch | `branch_id`, `message` |
| `branch_status` | Get branch status | `branch_id` |

### Reflection Tools

| Tool | Purpose | Key Parameters |
|------|---------|----------------|
| `reflect_analyze` | Analyze behavior patterns | `project_id`, `period_days` |
| `reflect_report` | Generate reflection report | `format` |

---

## Core Concepts

### Tenant ID

Derived from git remote URL. Example: `github.com/fyrsmithlabs/contextd` -> `fyrsmithlabs`

```bash
git remote get-url origin | sed 's|.*github.com[:/]\([^/]*\).*|\1|'
```

### Project ID

Scopes memories to a specific project. Use repository name or `org/repo` format.

Hierarchical namespaces:
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
| `learning` | General knowledge | 180 days |
| `remediation` | Error -> fix mappings | 365 days |
| `decision` | ADR/architecture choices | Never |
| `failure` | What NOT to do | 365 days |
| `pattern` | Reusable code patterns | 180 days |
| `policy` | STRICT constraints | Never |

Tag memories: `tags: ["type:learning", "category:testing"]`

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

## Error Handling

### Graceful Degradation

If corrupt collections are detected, contextd quarantines them and continues with healthy collections.

### Partial Failures

Commands handle partial failures gracefully:
- If `semantic_search` fails: Continue with memory/remediation search
- If `memory_search` fails: Continue with other results
- If `remediation_search` fails: Continue with other results

### No Results

When no matches found:
- Suggest broader search terms
- Fall back to standard Read/Grep/Glob

### Recovery

```bash
# Check health
ctxd health

# Diagnose issues
/contextd:diagnose "metadata corruption"

# Re-index repository
mcp__contextd__repository_index(path: ".")
```

---

## Additional Resources

- **contextd Repository**: [github.com/fyrsmithlabs/contextd](https://github.com/fyrsmithlabs/contextd)
- **Issue Tracker**: [fyrsmithlabs/contextd/issues](https://github.com/fyrsmithlabs/contextd/issues)
- **Releases**: [github.com/fyrsmithlabs/contextd/releases](https://github.com/fyrsmithlabs/contextd/releases)

---

*Last Updated: 2026-01-29*
