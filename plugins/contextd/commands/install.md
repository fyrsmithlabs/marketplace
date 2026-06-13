---
name: install
description: Install the contextd binary and register the MCP server with Claude Code.
---

Install contextd locally and wire it into Claude Code.

## Steps

1. **Run the install script** bundled with this plugin:
   ```
   bash ${CLAUDE_PLUGIN_ROOT}/scripts/install-contextd.sh
   ```
   It detects OS/arch, tries Homebrew first, then falls back to a binary download from the GitHub releases page. On success both `contextd` and `ctxd` will be on the user's `PATH`.

2. **Register the MCP server** by running:
   ```
   ctxd mcp install
   ```
   This writes the `contextd` entry into `~/.claude/settings.json` so Claude Code can launch the stdio transport. If a prior entry exists, the command updates it in place.

3. **Verify** the install:
   ```
   contextd --version
   ctxd mcp status
   ```
   Report both back to the user.

## When to use `/contextd:install` vs `/contextd:init`

- `/contextd:install` — system-wide setup only. Use this once per machine.
- `/contextd:init` — per-project setup. Use this in each repo you want contextd to work with. It also runs `install` if needed.

## Failure handling

If the install script fails:

- **Homebrew failure** — surface the brew error and suggest the binary fallback (which the script already attempts; only escalate if both fail).
- **Binary download failure** — surface the curl/wget error and suggest manual download from `https://github.com/fyrsmithlabs/contextd/releases`.
- **`ctxd mcp install` failure** — likely a malformed existing `~/.claude/settings.json`. Show the error and suggest the user back up and inspect the file.

Do not re-run the full script on partial failure; the script is idempotent but noisy. Re-run only the step that failed.
