---
name: init
description: Initialize contextd for the current project — installs the binary if missing, configures MCP, and optionally seeds CLAUDE.md.
---

Initialize contextd for the current project.

## Steps

1. **Check installation.** Run `command -v contextd` and `command -v ctxd`. If either is missing, run the bundled install script:
   ```
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/install-contextd.sh
   ```
   The script tries Homebrew, then a binary release download. Report the version on success.

2. **Verify MCP configuration.** Run `ctxd mcp status` and confirm the `contextd` server is registered in `~/.claude/settings.json`. If not, run `ctxd mcp install` and confirm the new config.

3. **Detect project context.** From the current working directory:
   - Read `git remote get-url origin` to derive the tenant/project ID.
   - Report the resolved tenant ID and project path back to the user.
   - If not a git repo, ask the user whether to use the directory name as the project ID or to skip.

4. **Health check.** Call the contextd HTTP health endpoint if running:
   ```
   curl -s http://localhost:9090/health
   ```
   If contextd is not running yet, that's fine — the MCP transport will start it on demand.

5. **Optional full setup (when invoked with `--full`).** For existing codebases, also:
   - Run the `@contextd:project-setup` skill to generate a `CLAUDE.md` tailored to the repo.
   - Run `mcp__contextd__repository_index` to seed semantic search for this project.
   - Run `mcp__contextd__memory_search` with a broad query to confirm the store is reachable.

## Arguments

- `--full` — Run the optional steps in (5). Use for established projects where indexing and CLAUDE.md generation are wanted up front.

## Output

Report back as a clean status block:

```
## contextd initialized

- Binary: contextd v0.4.0 (/usr/local/bin/contextd)
- CLI:    ctxd v0.4.0
- MCP:    registered in ~/.claude/settings.json
- Tenant: fyrsmithlabs
- Project: /home/user/projects/foo
- Health: ✅ healthy (or "not running — will start on first MCP call")
```

If any step fails, surface the specific command that failed and a short remediation hint rather than re-running the whole flow.
