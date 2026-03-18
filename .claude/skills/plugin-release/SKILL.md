---
name: plugin-release
description: Use when releasing a new version of a fyrsmithlabs plugin. Automates version bumping across all manifests (plugin.json, marketplace.json, CLAUDE.md), validates counts match disk, runs plugin-validator, creates git tag and GitHub release. Say "release the plugin", "bump version", "create a release".
---

# Plugin Release

Automates the full release workflow for fyrsmithlabs marketplace plugins. Eliminates version drift by updating all manifest files atomically, validates artifact counts against disk, and creates a tagged GitHub release with generated notes.

## Contextd Integration

If contextd MCP is available:
- `memory_search` to find past release issues for this plugin
- `memory_record` to store release metadata for cross-session tracking

If contextd is NOT available:
- Release runs inline (still works)
- No persistence of release history

---

## When to Use

- When preparing a new plugin release
- When the user says "release the plugin", "bump version", or "create a release"
- After a batch of changes are merged and ready for tagging
- When version drift is detected between manifest files

---

## Step 1: Determine Target Version

Accept the version in one of three forms:

| Input | Behavior |
|-------|----------|
| Explicit version (e.g., `1.11.0`) | Use as-is after validating it is greater than current |
| Bump type (`patch`, `minor`, `major`) | Apply semver bump to current version |
| No input | Auto-detect from commits since last tag |

**Read current version:**
```
cat plugins/{plugin}/.claude-plugin/plugin.json → version field
```

**Auto-detect from commits (when no version argument provided):**
```
git log v{current}..HEAD --oneline
```

Apply conventional commit rules:
- Any `feat:` or `feat(...):`  → minor bump
- Only `fix:` / `chore:` / `refactor:` / `docs:` → patch bump
- Any commit containing `BREAKING CHANGE` or `!:` → major bump

Present the detected version to the user and confirm before proceeding.

---

## Step 2: Version Bump Checklist

Update ALL of the following files. Missing any file causes version drift.

| File | Field/Pattern | Example |
|------|---------------|---------|
| `plugins/{plugin}/.claude-plugin/plugin.json` | `"version": "{version}"` | `"1.10.0"` to `"1.11.0"` |
| `.claude-plugin/marketplace.json` | `metadata.version` | `"1.10.0"` to `"1.11.0"` |
| `.claude-plugin/marketplace.json` | `plugins[name={plugin}].version` | `"1.10.0"` to `"1.11.0"` |
| `CLAUDE.md` | `**Version**: {version}` header line | `**Version**: 1.10.0` to `**Version**: 1.11.0` |
| `CLAUDE.md` | Plugins table row for `{plugin}` | `v1.10.0` to `v1.11.0` |

**Verification after edits:** Read each file back and confirm the new version string appears exactly once in each expected location. If any file still contains the old version in a location that should have been updated, fix it before proceeding.

---

## Step 3: Count Validation

Scan the filesystem to get actual counts and update CLAUDE.md if they have changed.

**Count commands:**
```bash
ls plugins/{plugin}/agents/*.md | wc -l
ls plugins/{plugin}/skills/*/SKILL.md | wc -l
ls plugins/{plugin}/commands/*.md | wc -l
```

**Locations to update in CLAUDE.md if counts changed:**

| Section | Pattern | Example |
|---------|---------|---------|
| Architecture diagram comment | `# {N} commands`, `# {N} subagents`, `# {N} skills` | `# 13 commands` |
| Architecture diagram | `├── commands/` line | `├── commands/          # 13 commands (...)` |
| Architecture diagram | `├── agents/` line | `├── agents/            # 17 subagents (...)` |
| Architecture diagram | `├── skills/` line | `├── skills/            # 16 skills (...)` |

Also verify that new skills, agents, or commands added since the last release are listed in the appropriate CLAUDE.md tables. If any are missing, add them.

---

## Step 4: Pre-Release Validation

Run these checks before creating the release. All must pass.

### 4a. JSON Validity
```bash
python3 -c "import json; json.load(open('plugins/{plugin}/.claude-plugin/plugin.json'))"
python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))"
```

### 4b. Version Consistency

Verify all five version locations from Step 2 contain the same version string. If any mismatch is found, stop and fix before proceeding.

### 4c. Skill Frontmatter Validation

For each file matching `plugins/{plugin}/skills/*/SKILL.md`:
- Verify YAML frontmatter exists (starts with `---`)
- Verify `name:` field is present and non-empty
- Verify `description:` field is present and non-empty

Report any skills missing frontmatter.

### 4d. Agent Frontmatter Validation

For each file matching `plugins/{plugin}/agents/*.md`:
- Verify YAML frontmatter exists (starts with `---`)
- Verify `name:` field is present and non-empty
- Verify `description:` field is present and non-empty

Report any agents missing frontmatter.

### 4e. Command Frontmatter Validation

For each file matching `plugins/{plugin}/commands/*.md`:
- Verify YAML frontmatter exists (starts with `---`)
- Verify `name:` field is present and non-empty
- Verify `description:` field is present and non-empty

Report any commands missing frontmatter.

### 4f. Validation Results

Present results as a table:

```
## Pre-Release Validation

| Check | Status | Details |
|-------|--------|---------|
| plugin.json valid JSON | PASS | |
| marketplace.json valid JSON | PASS | |
| Version consistency (5 locations) | PASS | All show 1.11.0 |
| Skill frontmatter (16 skills) | PASS | All have name + description |
| Agent frontmatter (17 agents) | PASS | All have name + description |
| Command frontmatter (13 commands) | PASS | All have name + description |
| Count accuracy | PASS | CLAUDE.md matches disk |
```

If ANY check fails, stop and report the failures. Do NOT proceed to release steps until all checks pass.

---

## Step 5: Release Notes Generation

Generate release notes from the commit log since the last tag.

**Get commits:**
```bash
git log v{previous_version}..HEAD --oneline --no-merges
```

**Group by conventional commit type:**

```markdown
## What's Changed

### Features
- Description from feat: commits

### Bug Fixes
- Description from fix: commits

### Refactoring
- Description from refactor: commits

### Documentation
- Description from docs: commits

### Maintenance
- Description from chore: commits
```

Omit empty sections. Use the commit subject line as the description, cleaned up for readability (remove the conventional commit prefix, capitalize first letter).

**Generate a one-line release title** summarizing the most significant changes.

Present the release notes to the user for review before proceeding.

---

## Step 6: Create Release

Execute these commands in order. Each step depends on the previous one succeeding.

```bash
# Stage all changed files
git add plugins/{plugin}/.claude-plugin/plugin.json
git add .claude-plugin/marketplace.json
git add CLAUDE.md
# Add any other files modified during count/table updates

# Commit
git commit -m "chore: release v{version} - {one-line summary}"

# Tag
git tag v{version}

# Push (with tags)
git push origin {current_branch} --tags

# Create GitHub release
gh release create v{version} \
  --title "v{version} - {title}" \
  --notes "{generated_release_notes}"
```

**Important:** If pushing to a feature branch (not main), the GitHub release should still be created against the tag. The user may need to merge to main first -- ask if the current branch is not main.

---

## Step 7: Post-Release Verification

After the release is created:

1. Verify the tag exists: `git tag -l v{version}`
2. Verify the GitHub release: `gh release view v{version}`
3. Report the release URL to the user

**If contextd is available:**
```
mcp__contextd__memory_record(
  project_id: "marketplace",
  title: "Release v{version}",
  content: "Released v{version} of {plugin}. {summary}. Files updated: plugin.json, marketplace.json, CLAUDE.md.",
  outcome: "success",
  tags: ["release", "{plugin}", "v{version}"]
)
```

---

## Mandatory Checklist

**EVERY release MUST complete ALL steps:**

- [ ] Determine target version (explicit, bump type, or auto-detect)
- [ ] Confirm version with user before proceeding
- [ ] Update `plugins/{plugin}/.claude-plugin/plugin.json`
- [ ] Update `.claude-plugin/marketplace.json` metadata.version
- [ ] Update `.claude-plugin/marketplace.json` plugins[name].version
- [ ] Update `CLAUDE.md` header version
- [ ] Update `CLAUDE.md` plugins table version
- [ ] Count agents, skills, commands on disk
- [ ] Update CLAUDE.md counts and tables if changed
- [ ] Validate all JSON files parse correctly
- [ ] Verify version consistency across all 5 locations
- [ ] Validate frontmatter on all skills, agents, and commands
- [ ] Generate release notes from commit log
- [ ] Present release notes to user for review
- [ ] Commit, tag, push, create GitHub release
- [ ] Verify release was created successfully
- [ ] Record release in contextd (if available)

**A release is NOT complete until the GitHub release URL is confirmed.**

---

## Red Flags - STOP and Reconsider

If you're thinking any of these, you're about to violate the skill:

| Thought | Reality |
|---------|---------|
| "I'll just update plugin.json, that's the main one" | ALL FIVE locations must be updated. Missing any causes version drift. |
| "The counts in CLAUDE.md are probably still correct" | Count from disk every time. New artifacts get added without updating docs. |
| "I'll skip frontmatter validation, it's tedious" | Missing frontmatter causes plugin loading failures. Always validate. |
| "The user said the version, I don't need to confirm" | Always confirm. Typos in version numbers are hard to undo after tagging. |
| "I'll generate release notes later" | Generate before tagging. The release notes are part of the release. |
| "I'll push to main directly" | Check the current branch. If not main, ask the user about merge strategy. |
| "marketplace.json only needs one version update" | It needs TWO: metadata.version AND plugins[name].version. |
| "I can skip the post-release verification" | Verify the tag and release exist. Silent failures happen. |

---

## Common Mistakes

| Mistake | Correct Approach |
|---------|-----------------|
| Updating only plugin.json | Update all 5 version locations |
| Forgetting marketplace.json has 2 version fields | Update both metadata.version and plugins[].version |
| Not counting artifacts from disk | Always count; never trust cached numbers |
| Skipping frontmatter validation | Validate every skill, agent, and command |
| Creating tag before committing | Commit first, then tag, then push |
| Not generating release notes | Always generate from commit log |
| Pushing without `--tags` | Tags must be pushed explicitly |
| Not confirming version with user | Always confirm before making changes |
| Forgetting to update CLAUDE.md tables for new artifacts | Check if new skills/agents/commands need table entries |

---

## Example: Full Release Run

**User says: `/fs-dev:release minor`**

1. **Read current version:** `1.10.0` from `plugins/fs-dev/.claude-plugin/plugin.json`
2. **Apply minor bump:** `1.10.0` to `1.11.0`
3. **Confirm with user:** "Bumping fs-dev from v1.10.0 to v1.11.0. Proceed?"
4. **Update 5 files:** plugin.json, marketplace.json (x2), CLAUDE.md (x2)
5. **Count from disk:** 17 agents, 16 skills, 13 commands
6. **Update CLAUDE.md** architecture diagram counts if changed
7. **Validate:** JSON valid, versions consistent, frontmatter present
8. **Generate release notes** from `git log v1.10.0..HEAD`
9. **Present notes to user** for review
10. **Commit:** `chore: release v1.11.0 - add plugin-release automation`
11. **Tag:** `v1.11.0`
12. **Push:** `git push origin main --tags`
13. **Release:** `gh release create v1.11.0 --title "v1.11.0 - Plugin Release Automation" --notes "..."`
14. **Verify:** Tag exists, release URL confirmed
15. **Record in contextd** (if available)
