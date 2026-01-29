---
name: setup
description: Use when onboarding to a project or creating/updating CLAUDE.md - covers codebase analysis, documentation generation, and policy management
---

# Project Setup

## When to Use

- Joining existing project without CLAUDE.md
- Project has outdated/incomplete CLAUDE.md
- Taking over maintenance of unfamiliar codebase
- Claude repeatedly asks the same questions

## Onboarding Workflow

### Phase 1: Discovery

```
1. Repository structure scan (Glob)
2. Package/dependency analysis (package.json, go.mod, requirements.txt)
3. Configuration files (tsconfig, .eslintrc, Makefile)
4. Existing documentation (README, docs/, CONTRIBUTING)
5. CI/CD configuration (.github/workflows)
```

### Phase 2: Pattern Extraction

| Target | Search Strategy |
|--------|-----------------|
| Entry points | main.*, index.*, cmd/, src/ |
| Architecture | Directory structure, imports |
| Testing | *_test.*, *.spec.*, jest.config |
| Build commands | Makefile, package.json scripts |

### Phase 3: CLAUDE.md Generation

Generate with this structure:

\`\`\`markdown
# CLAUDE.md - [Project Name]

**Status**: Active Development | Maintenance | Legacy
**Last Updated**: YYYY-MM-DD

---

## Critical Rules

**ALWAYS** [most important constraints]
**NEVER** [dangerous actions to avoid]

---

## Architecture

\`\`\`
src/
├── components/    # [purpose]
├── lib/           # [purpose]
└── utils/         # [purpose]
\`\`\`

## Tech Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Runtime   | Node.js    | 20.x    |

## Commands

| Command | Purpose |
|---------|---------|
| \`npm run dev\` | Start development server |
| \`npm run test\` | Run unit tests |

## Known Pitfalls

| Pitfall | Prevention |
|---------|------------|
| [Issue 1] | [How to avoid] |
\`\`\`

## CLAUDE.md Best Practices

**ALWAYS:**
- Start with Status and Last Updated
- Put Critical Rules (NEVER/ALWAYS) at top
- Use specific versions, paths, exact commands
- Include code examples for key patterns

**NEVER:**
- Write vague descriptions ("modern tech stack")
- Skip examples for important concepts
- List commands without context

## File Hierarchy

| Location | Purpose | Scope |
|----------|---------|-------|
| \`~/.claude/CLAUDE.md\` | User preferences | All projects |
| \`./CLAUDE.md\` | Project rules | Team (Git) |
| Parent directories | Monorepo root | Inherited |
| Subdirectories | Module overrides | On demand |

All locations load automatically. Most specific wins.

## Modularization with @imports

For large projects, split documentation:

\`\`\`markdown
# CLAUDE.md
@docs/architecture.md
@docs/api-conventions.md
@docs/testing-strategy.md
\`\`\`

Keep main CLAUDE.md clean. Only core rules inline.

## Policies (Strict Guidelines)

Policies are STRICT constraints that MUST be followed:

\`\`\`json
{
  "project_id": "global",
  "title": "POLICY: test-before-fix",
  "content": "RULE: Always run tests before claiming a fix is complete.\nCATEGORY: verification\nSEVERITY: high",
  "outcome": "success",
  "tags": ["type:policy", "category:verification", "severity:high"]
}
\`\`\`

**Categories:** verification, process, security, quality, communication

**Severity:** critical, high, medium

## After Setup

\`\`\`
# Re-index repository with new documentation
repository_index(path: ".")

# Record the setup as a memory
memory_record(
  project_id: "<project>",
  title: "Project onboarded with CLAUDE.md",
  content: "Created CLAUDE.md with architecture, commands, pitfalls...",
  outcome: "success",
  tags: ["onboarding", "claude-md"]
)
\`\`\`

## Common Mistakes

| Mistake | Prevention |
|---------|------------|
| Asking user "what framework?" | Check package.json, go.mod first |
| Generic architecture description | Run actual discovery commands |
| Missing version numbers | Extract from lockfiles |
| No examples for key patterns | Always show code patterns |
| Too long CLAUDE.md (>500 lines) | Modularize with @imports |

## Quick Reference

| Step | Action |
|------|--------|
| 1 | Scan repo structure |
| 2 | Read package/config files |
| 3 | Extract patterns |
| 4 | Generate CLAUDE.md |
| 5 | Verify commands work |
| 6 | Index repository |

---

## Tech Stack Database Patterns

### Automatic Stack Detection

Setup auto-detects and records tech stack metadata:

| File | Detected Stack | Patterns Applied |
|------|----------------|------------------|
| \`package.json\` | Node.js, npm/yarn/pnpm | JS/TS conventions |
| \`go.mod\` | Go | Go idioms, error handling |
| \`Cargo.toml\` | Rust | Ownership patterns |
| \`pyproject.toml\` | Python (modern) | Type hints, async |
| \`requirements.txt\` | Python (legacy) | Virtual env patterns |
| \`Gemfile\` | Ruby | Rails conventions if present |
| \`pom.xml\` | Java/Maven | Spring patterns if present |
| \`build.gradle\` | Java/Kotlin/Gradle | Android if detected |

### Stack-Specific Memories

Setup creates foundation memories per stack:

\`\`\`json
{
  "project_id": "contextd",
  "title": "STACK: Go 1.22 with embedded vectorstore",
  "content": "Tech: Go 1.22\nDeps: chromem-go, chi router\nPatterns: Registry DI, table-driven tests\nLinting: golangci-lint",
  "tags": ["type:pattern", "stack:go", "auto-generated"]
}
\`\`\`

### Database Pattern Recognition

| Config File | Database | Applied Patterns |
|-------------|----------|------------------|
| \`.env\` with \`DATABASE_URL\` | PostgreSQL/MySQL | Migration patterns, connection pooling |
| \`prisma/schema.prisma\` | Prisma ORM | Type-safe queries, migrations |
| \`drizzle.config.ts\` | Drizzle ORM | Schema-first, migrations |
| \`ent/schema/\` | Ent (Go) | Code generation, edges |
| \`sqlc.yaml\` | sqlc (Go) | Generated queries |

---

## Policy Enforcement Metadata

### Policy Structure

Policies are STRICT constraints with enforcement metadata:

\`\`\`json
{
  "project_id": "global",
  "title": "POLICY: test-before-fix",
  "content": "RULE: Always run tests before claiming a fix is complete.",
  "outcome": "success",
  "tags": ["type:policy", "category:verification", "severity:high"],
  "enforcement": {
    "mode": "strict",
    "check_hook": "PreToolUse",
    "check_tool": "Bash",
    "violation_action": "block"
  }
}
\`\`\`

### Enforcement Modes

| Mode | Behavior | Use Case |
|------|----------|----------|
| \`strict\` | Block violating actions | Security, data integrity |
| \`warning\` | Allow with prominent warning | Best practices |
| \`audit\` | Log only, no interruption | Monitoring, gradual rollout |

### Policy Categories

| Category | Examples |
|----------|----------|
| \`verification\` | Test before commit, review before merge |
| \`process\` | TDD, checkpoint before clear |
| \`security\` | No secrets in code, input validation |
| \`quality\` | Linting, type safety, documentation |
| \`communication\` | Commit message format, PR templates |

---

## Setup Checksums

### Integrity Verification

Setup generates checksums to detect drift:

\`\`\`json
{
  "setup_checksum": {
    "claude_md_hash": "sha256:abc123...",
    "stack_snapshot": "sha256:def456...",
    "policy_version": "v1.2.0",
    "generated_at": "2026-01-28T10:00:00Z"
  }
}
\`\`\`

### Drift Detection

On session start, compare checksums:

\`\`\`
1. Hash current CLAUDE.md
2. Compare to stored setup_checksum.claude_md_hash
3. If mismatch:
   - Warn: "CLAUDE.md has changed since setup"
   - Suggest: "Run /init --update to sync"
\`\`\`

### Checksum Commands

| Command | Purpose |
|---------|---------|
| \`/init --verify\` | Check for drift without changes |
| \`/init --update\` | Re-run setup, update checksums |
| \`/init --force\` | Full re-setup, overwrite |

---

## Hierarchical Namespace Guidance

### Project ID Structure

\`\`\`
<org>/<team>/<project>/<module>

Examples:
  fyrsmithlabs/platform/contextd/api
  fyrsmithlabs/platform/contextd/vectorstore
  fyrsmithlabs/marketplace/fs-dev/skills
\`\`\`

### ID Format Requirements (contextd v1.5+)

**IMPORTANT**: \`tenant_id\` and \`project_id\` must be lowercase alphanumeric with underscores:
- **Valid**: \`my_project\`, \`contextd\`, \`org123\`, \`fyrsmithlabs_marketplace\`
- **Invalid**: \`My-Project\`, \`org/repo\`, \`project..name\`
- **Length**: 1-64 characters

When deriving IDs from git remotes:
- Replace hyphens with underscores: \`my-project\` → \`my_project\`
- Remove invalid characters (slashes, dots)
- Convert to lowercase

### Setup Namespace Detection

Setup auto-detects namespace from:

1. Git remote URL: \`github.com/fyrsmithlabs/contextd\` -> \`fyrsmithlabs/contextd\`
2. Directory structure: Monorepo detection
3. Existing CLAUDE.md: Parse namespace declarations

### Namespace Inheritance

\`\`\`markdown
# In root CLAUDE.md
@namespace fyrsmithlabs/platform

# In packages/api/CLAUDE.md (inherits)
@namespace ../api  # Resolves to fyrsmithlabs/platform/api
\`\`\`

---

## Audit Fields

Setup records create audit metadata:

| Field | Description | Auto-set |
|-------|-------------|----------|
| \`created_by\` | Session/agent that ran setup | Yes |
| \`created_at\` | ISO timestamp | Yes |
| \`setup_version\` | Setup skill version | Yes |
| \`usage_count\` | Times CLAUDE.md loaded | Yes |

---

## Claude Code 2.1 Patterns

### Background Indexing

Use background tasks for large repos:

\`\`\`
Task(
  subagent_type: "general-purpose",
  prompt: "Index all source files in /path/to/repo",
  run_in_background: true,
  description: "Repository indexing"
)

// Continue with other setup tasks...
TaskOutput(task_id, block: false)  // Check progress
\`\`\`

### Setup Task Dependencies

Chain setup phases:

\`\`\`
phase1 = Task(prompt: "Scan repository structure")
phase2 = Task(prompt: "Detect tech stack", addBlockedBy: [phase1.id])
phase3 = Task(prompt: "Generate CLAUDE.md", addBlockedBy: [phase2.id])
phase4 = Task(prompt: "Index repository", addBlockedBy: [phase3.id])
\`\`\`

### PreToolUse Hook for Setup Verification

Auto-verify setup before operations:

\`\`\`json
{
  "hook_type": "PreToolUse",
  "tool_name": "Read",
  "condition": "file_path.endsWith('CLAUDE.md')",
  "prompt": "Check setup checksum for drift before reading CLAUDE.md."
}
\`\`\`

---

## Event-Driven State Sharing

Setup emits events for other skills:

\`\`\`json
{
  "event": "setup_complete",
  "payload": {
    "project_id": "fyrsmithlabs/contextd",
    "stack": "go",
    "policies_loaded": 5,
    "checksum": "sha256:..."
  },
  "notify": ["workflow", "consensus-review"]
}
\`\`\`

Subscribe to setup events:
- \`setup_started\` - Setup initiated
- \`setup_complete\` - Setup finished successfully
- \`setup_drift_detected\` - Checksum mismatch found
- \`policy_loaded\` - New policy activated
