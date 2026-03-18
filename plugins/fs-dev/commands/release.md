---
name: release
description: Release a new version of an fs-dev plugin with automated version bumping, validation, and GitHub release creation
arguments:
  - name: version
    description: "Target version (e.g., '1.11.0') or bump type ('patch', 'minor', 'major'). If omitted, auto-detects from conventional commits."
    required: false
---

# /fs-dev:release [version]

Release a new plugin version with full automation.

## Usage

```
/fs-dev:release 1.11.0       # Release specific version
/fs-dev:release minor         # Bump minor version
/fs-dev:release patch         # Bump patch version
/fs-dev:release major         # Bump major version
/fs-dev:release               # Auto-detect from commits
```

## What It Does

1. Determines the target version (from argument or commit history)
2. Updates version in all 5 manifest locations (plugin.json, marketplace.json x2, CLAUDE.md x2)
3. Counts agents, skills, and commands on disk and updates CLAUDE.md if counts changed
4. Validates JSON, version consistency, and frontmatter on all artifacts
5. Generates release notes from the conventional commit log
6. Commits, tags, pushes, and creates a GitHub release

## Workflow

Invoke the `plugin-release` skill with the version argument. The skill handles the complete release checklist including:

- Version bumping across all manifests
- Count validation against disk
- Pre-release validation (JSON, frontmatter, version consistency)
- Release notes generation from commit history
- Git commit, tag, push, and GitHub release creation
- Post-release verification

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `version` | No | Semver version (`1.11.0`) or bump type (`patch`, `minor`, `major`). Auto-detects if omitted. |

## Related

- `plugin-release` skill - Full release automation instructions
- `git-repo-standards` skill - Repository structure conventions
- `git-workflows` skill - Branching and PR conventions
