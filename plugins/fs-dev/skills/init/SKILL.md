---
name: init
description: Use when setting up a project to follow fyrsmithlabs standards. Works for new or existing repos - detects state automatically. Validates against git-repo-standards, generates missing artifacts, bootstraps CLAUDE.md based on project type. Includes interactive configuration wizard for project setup.
---

# Init

Set up any project to follow fyrsmithlabs standards. Detects whether repo is new or existing and handles accordingly.

## Command

```
/init                 # Full interactive setup wizard
/init --check         # Audit only, no modifications
/init --quick         # Skip wizard, use auto-detection
/init --validate      # Validate existing setup, check for staleness
```

## Contextd Integration (Optional)

If contextd MCP is available:
- `memory_search` for past init patterns
- `semantic_search` for project configuration
- `remediation_search` for common setup errors
- `memory_record` for init outcomes

If contextd is NOT available:
- Use Glob/Grep for project exploration
- Init still works fully (file-based fallback)
- No cross-session pattern learning

---

## Phase 1: Pre-Flight & Detection

### Step 1.1: Contextd Context Gathering (if available)

```
1. memory_search for past init patterns
2. semantic_search for project configuration
3. remediation_search for setup errors
```

**If NOT available:** Proceed with file-based detection.

### Step 1.2: Project Type Auto-Detection

Scan for language/framework indicators in priority order:

| Indicator File | Project Type | Language | Framework |
|---------------|--------------|----------|-----------|
| `go.mod` | Go Module | Go | - |
| `package.json` + `next.config.*` | Web App | TypeScript/JavaScript | Next.js |
| `package.json` + `nuxt.config.*` | Web App | TypeScript/JavaScript | Nuxt.js |
| `package.json` + `svelte.config.*` | Web App | TypeScript/JavaScript | SvelteKit |
| `package.json` + `vite.config.*` | Web App | TypeScript/JavaScript | Vite |
| `package.json` + `bin` field | CLI | JavaScript/TypeScript | Node.js |
| `package.json` (no framework) | Library | JavaScript/TypeScript | Node.js |
| `pyproject.toml` | Python | Python | - |
| `requirements.txt` (no pyproject) | Python (legacy) | Python | - |
| `Cargo.toml` | Rust | Rust | - |
| `pom.xml` | Java | Java | Maven |
| `build.gradle*` | Java/Kotlin | Java/Kotlin | Gradle |
| `*.csproj` | .NET | C# | .NET |
| `Gemfile` | Ruby | Ruby | - |
| `mix.exs` | Elixir | Elixir | - |
| Multiple language files | Monorepo | Mixed | - |
| None | Unknown | - | - |

### Step 1.3: Project Category Detection

| Category | Indicators |
|----------|------------|
| **API/Service** | `cmd/`, `main.go`, `server.ts`, `app.py`, Dockerfile, `internal/`, presence of HTTP/gRPC handlers |
| **CLI** | `cmd/`, `cobra`, `urfave/cli`, `package.json.bin`, `argparse`, `click` |
| **Library** | `pkg/` only, `exports` in package.json, `-lib` suffix, no entrypoint |
| **Web App** | Frontend framework detected, `pages/`, `src/app/`, `public/` |
| **Monorepo** | `pnpm-workspace.yaml`, `lerna.json`, `nx.json`, `turbo.json`, multiple `go.mod` |

---

## Phase 2: Interactive Configuration Wizard

**Skip if `--quick` flag is provided.** Use auto-detected values instead.

### Step 2.1: Project Type Confirmation

```
AskUserQuestion(
  questions: [{
    question: "Detected: <auto-detected-type>. Is this correct?",
    header: "Project Type",
    options: [
      { label: "Yes, <detected-type>", description: "<detected indicators>" },
      { label: "Web Application", description: "Frontend app with UI" },
      { label: "API/Service", description: "Backend service or API" },
      { label: "CLI Tool", description: "Command-line application" },
      { label: "Library", description: "Reusable package/module" },
      { label: "Monorepo", description: "Multiple projects in one repo" }
    ],
    multiSelect: false
  }]
)
```

### Step 2.2: Language/Framework Confirmation

```
AskUserQuestion(
  questions: [{
    question: "Detected language: <language>. Framework: <framework|none>. Confirm or change:",
    header: "Tech Stack",
    options: [
      { label: "Correct as detected", description: "<language> + <framework>" },
      { label: "Go", description: "Standard library or common Go patterns" },
      { label: "TypeScript/JavaScript", description: "Node.js ecosystem" },
      { label: "Python", description: "Python 3.x" },
      { label: "Rust", description: "Cargo-based project" },
      { label: "Other", description: "Specify manually" }
    ],
    multiSelect: false
  }]
)
```

### Step 2.3: Project Configuration

```
AskUserQuestion(
  questions: [{
    question: "What additional tooling should be configured?",
    header: "Tooling Setup",
    options: [
      { label: "Linting & Formatting", description: "Auto-detect and configure linter/formatter" },
      { label: "Testing Framework", description: "Set up test infrastructure" },
      { label: "CI/CD Pipeline", description: "GitHub Actions workflow" },
      { label: "Pre-commit Hooks", description: "husky, pre-commit, or similar" },
      { label: "Docker", description: "Dockerfile and .dockerignore" },
      { label: "All of the above", description: "Full project setup" }
    ],
    multiSelect: true
  }]
)
```

### Step 2.4: CLAUDE.md Customization

```
AskUserQuestion(
  questions: [{
    question: "What should be emphasized in CLAUDE.md?",
    header: "Project Focus",
    options: [
      { label: "Standard", description: "Balanced coverage of all areas" },
      { label: "Security-focused", description: "Extra emphasis on security patterns" },
      { label: "Performance-critical", description: "Performance patterns and benchmarking" },
      { label: "API-first", description: "API design, contracts, versioning" },
      { label: "TDD/Testing", description: "Test patterns and coverage requirements" }
    ],
    multiSelect: false
  }]
)
```

---

## Phase 3: Language-Specific Bootstrap

### Go Projects

**Detection Files:** `go.mod`

**Extract Configuration:**
```
1. Parse go.mod for module path and Go version
2. Check for golangci-lint config (.golangci.yml, .golangci.yaml)
3. Check for Makefile with standard targets
4. Detect cmd/ structure for entry points
5. Check for internal/ vs pkg/ organization
```

**Generate/Validate:**
| Item | Source | Action |
|------|--------|--------|
| `.golangci.yml` | If missing, generate standard config | Create |
| `Makefile` | If missing, generate with lint/test/build | Create |
| `.gitignore` | Use `gitignore-go.tmpl` | Merge |

**CLAUDE.md Go Section:**
```markdown
## Commands

| Command | Purpose |
|---------|---------|
| `make lint` | Run golangci-lint |
| `make test` | Run tests with coverage |
| `make build` | Build binary |
| `go generate ./...` | Run code generation |

## Code Style

- Follow Effective Go and Go Code Review Comments
- Use `internal/` for private packages
- Entry points in `cmd/<app-name>/main.go`
```

### Node.js/TypeScript Projects

**Detection Files:** `package.json`, `tsconfig.json`

**Extract Configuration:**
```
1. Parse package.json for:
   - name, version, type (module/commonjs)
   - scripts (build, test, lint, format)
   - dependencies (detect frameworks)
   - devDependencies (detect tooling)
2. Check for TypeScript (tsconfig.json)
3. Detect linter: eslint (.eslintrc*), biome (biome.json)
4. Detect formatter: prettier (.prettierrc*), biome
5. Detect test framework: jest, vitest, mocha, playwright
```

**Generate/Validate:**
| Item | Source | Action |
|------|--------|--------|
| `tsconfig.json` | If TS detected but missing | Create strict config |
| `.eslintrc.*` | If missing and eslint in deps | Create |
| `.prettierrc` | If missing and prettier in deps | Create |
| `.gitignore` | Merge with `gitignore-generic.tmpl` | Merge |

**CLAUDE.md Node Section:**
```markdown
## Commands

| Command | Purpose |
|---------|---------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run test` | Run tests |
| `npm run lint` | Run ESLint |
| `npm run format` | Run Prettier |

## Code Style

- Use TypeScript strict mode
- Prefer named exports over default exports
- Use path aliases from tsconfig.json
```

### Python Projects

**Detection Files:** `pyproject.toml`, `requirements.txt`, `setup.py`

**Extract Configuration:**
```
1. Parse pyproject.toml for:
   - project name, version
   - dependencies, optional-dependencies
   - tool.* sections (ruff, black, pytest, mypy)
2. Detect linter/formatter:
   - ruff (ruff.toml, pyproject.toml[tool.ruff])
   - black (pyproject.toml[tool.black])
   - flake8 (.flake8, setup.cfg)
3. Detect type checker: mypy, pyright
4. Detect test framework: pytest, unittest
5. Check for virtual env (.venv, venv, .python-version)
```

**Generate/Validate:**
| Item | Source | Action |
|------|--------|--------|
| `pyproject.toml` | If missing, generate PEP 621 compliant | Create |
| `ruff.toml` | If no linter configured | Create |
| `.python-version` | If missing | Create with detected version |
| `.gitignore` | Merge Python patterns | Merge |

**CLAUDE.md Python Section:**
```markdown
## Commands

| Command | Purpose |
|---------|---------|
| `uv run pytest` | Run tests |
| `uv run ruff check .` | Lint code |
| `uv run ruff format .` | Format code |
| `uv run mypy .` | Type check |

## Code Style

- Use type hints for all public functions
- Follow PEP 8 (enforced by ruff)
- Use dataclasses or Pydantic for data structures
```

### Rust Projects

**Detection Files:** `Cargo.toml`

**Extract Configuration:**
```
1. Parse Cargo.toml for:
   - package name, version, edition
   - dependencies, dev-dependencies
   - workspace configuration (monorepo)
2. Check for clippy configuration
3. Check for rustfmt.toml
4. Detect binary vs library (src/main.rs vs src/lib.rs)
```

**Generate/Validate:**
| Item | Source | Action |
|------|--------|--------|
| `rustfmt.toml` | If missing | Create with standard config |
| `clippy.toml` | If missing | Create |
| `.gitignore` | Rust patterns | Merge |

**CLAUDE.md Rust Section:**
```markdown
## Commands

| Command | Purpose |
|---------|---------|
| `cargo build` | Build debug |
| `cargo build --release` | Build release |
| `cargo test` | Run tests |
| `cargo clippy` | Run linter |
| `cargo fmt` | Format code |

## Code Style

- Run `cargo clippy` before commits
- Use `#[must_use]` for functions returning values
- Prefer `Result<T, E>` over panics
```

---

## Phase 4: CLAUDE.md Generation

### Template Selection

Select template based on project type and focus:

| Project Type | Template Base | Additional Sections |
|--------------|---------------|---------------------|
| API/Service | `claude-md-service.tmpl` | API patterns, error handling, auth |
| CLI | `claude-md-cli.tmpl` | Argument parsing, output formatting |
| Library | `claude-md-library.tmpl` | Public API, backwards compatibility |
| Web App | `claude-md-webapp.tmpl` | Component patterns, state management |
| Monorepo | `claude-md-monorepo.tmpl` | Workspace structure, shared deps |

### Automatic Rule Extraction

Extract rules from existing configuration files:

| Source | Extract |
|--------|---------|
| `.eslintrc.*` | Disabled rules as pitfalls, custom rules as patterns |
| `tsconfig.json` | Strict settings, path aliases |
| `.golangci.yml` | Enabled linters, custom rules |
| `ruff.toml` | Ignored rules, line length |
| `.editorconfig` | Indent style, line endings |
| `Makefile` | Available targets as commands |
| `package.json scripts` | Available commands |
| `.github/workflows/*.yml` | CI commands, required checks |

### CLAUDE.md Structure

```markdown
# CLAUDE.md - {{.ProjectName}}

**Status**: Active Development
**Version**: {{.Version}}
**Last Updated**: {{.Date}}

---

## Critical Rules

**ALWAYS** {{extracted from linter configs or user input}}
**NEVER** {{extracted from security configs or user input}}

---

## Architecture

\`\`\`
{{.DirectoryStructure}}
\`\`\`

## Tech Stack

| Component | Technology | Version |
|-----------|------------|---------|
{{range .TechStack}}
| {{.Component}} | {{.Technology}} | {{.Version}} |
{{end}}

## Commands

| Command | Purpose |
|---------|---------|
{{range .Commands}}
| `{{.Command}}` | {{.Purpose}} |
{{end}}

## Code Style

{{.CodeStyleRules}}

## Known Pitfalls

| Pitfall | Prevention |
|---------|------------|
{{range .Pitfalls}}
| {{.Pitfall}} | {{.Prevention}} |
{{end}}

---

## ADRs (Architectural Decisions)

<!-- Format: ADR-NNN: Title, Status, Context, Decision, Consequences -->
```

---

## Phase 5: Severity Tiers & Compliance

All checklist items have a severity tier that determines action:

| Tier | Action | Description |
|------|--------|-------------|
| **Critical** | Block | Cannot proceed until fixed. Init cannot complete. |
| **Required** | Block | Must be fixed before init completes. |
| **Style** | Fix | Must be fixed. Lower priority but still required. |

**Critical Rule:** Init MUST achieve 100% pass rate on ALL checklist items. No exceptions - Critical, Required, AND Style items must all pass before init completes.

**Why Style Items Are Required:**
- Style items (badges, README sections, PR templates) affect discoverability and usability
- "Good enough" mindset leads to debt accumulation
- It's easier to fix now than create issues to fix later
- Projects should start fully compliant, not partially compliant

---

## Phase 6: Compliance Checklist

### Repository Standards (git-repo-standards)

| Item | Tier | Check |
|------|------|-------|
| **Naming** | Critical | Repo name follows `[domain]-[type]` pattern |
| **README.md** | Critical | Exists with required sections + badges |
| **CHANGELOG.md** | Critical | Exists with `[Unreleased]` section |
| **LICENSE** | Critical | Exists, matches project type |
| **.gitignore** | Critical | Exists with `docs/.claude/` ignored |
| **.gitleaks.toml** | Critical | Exists |
| **CLAUDE.md** | Required | Exists with project-specific content |
| **docs/.claude/** | Required | Directory exists and gitignored |

### Language-Specific Checks

#### Go (if detected)

| Item | Tier | Check |
|------|------|-------|
| **go.mod** | Critical | Exists with valid module path |
| **cmd/** | Required | Entry points for executables (services only) |
| **internal/** | Style | Private packages recommended |
| **.golangci.yml** | Style | Linter configuration exists |
| **No /src** | Required | Avoid Java-style src directory |

#### Node.js/TypeScript (if detected)

| Item | Tier | Check |
|------|------|-------|
| **package.json** | Critical | Valid with name and version |
| **tsconfig.json** | Required | If TypeScript files exist |
| **Linter config** | Style | ESLint or Biome configured |
| **package-lock.json** | Required | Lockfile committed |

#### Python (if detected)

| Item | Tier | Check |
|------|------|-------|
| **pyproject.toml** | Required | PEP 621 compliant |
| **Linter config** | Style | Ruff, flake8, or similar |
| **.python-version** | Style | Python version pinned |

#### Rust (if detected)

| Item | Tier | Check |
|------|------|-------|
| **Cargo.toml** | Critical | Valid package definition |
| **rustfmt.toml** | Style | Formatter configuration |

### Workflow Standards (git-workflows)

| Item | Tier | Check |
|------|------|-------|
| **CI workflow** | Required | GitHub Actions configured |
| **fyrsmith-workflow.yml** | Required | Consensus review config exists |
| **PR template** | Style | `.github/pull_request_template.md` |

---

## Phase 7: Remediation

### Missing Files

For missing files, generate from templates:

| Missing | Action |
|---------|--------|
| README.md | Generate from `README.md.tmpl` |
| CHANGELOG.md | Generate from `CHANGELOG.md.tmpl` |
| LICENSE | Generate based on project type |
| .gitignore | Generate from language-specific template |
| .gitleaks.toml | Generate from `gitleaks.toml.tmpl` |
| CLAUDE.md | Generate from project-type template |

### Existing Incorrect Files

For files that exist but are incorrect:

| Issue | Remediation |
|-------|-------------|
| README missing sections | **Add** missing sections, preserve existing content |
| README missing badges | **Add** badges at top, keep existing badges |
| CHANGELOG wrong format | **Convert** to Keep a Changelog format, preserve entries |
| LICENSE wrong type | **Warn and recommend** change with migration guidance |
| .gitignore missing patterns | **Append** required patterns, keep existing |
| .gitleaks.toml incomplete | **Merge** required config, keep custom allowlist |
| CLAUDE.md outdated | **Update** sections, preserve custom content |

**License Change Protocol:**
When LICENSE type is incorrect (e.g., MIT for a service):
1. Warn with specific recommendation
2. Explain why the change matters
3. Note: changing license may require contributor consent
4. Create issue to track license migration
5. Do NOT auto-change license files

**Key Principle:** Init prefers **additive** changes over **destructive** ones. Existing content is preserved where possible.

---

## Phase 8: Gap Report & Fix Process

### Step 8.1: Show Gap Report

```markdown
## Init Audit: [repo-name]

**Project:** <detected-type> | <language> | <framework>

| Check | Tier | Status | Action |
|-------|------|--------|--------|
| README.md | Style | Missing badges | Add badges |
| CHANGELOG.md | Critical | Missing | Create |
| .gitleaks.toml | Critical | Missing | Create |
| CLAUDE.md | Required | Missing | Generate |
| docs/.claude/ | Required | Missing | Create |

**Gaps:** 2 Critical, 2 Required, 1 Style - ALL must be fixed
```

### Step 8.2: Fix Gaps (with confirmation)

```
AskUserQuestion(
  questions: [{
    question: "Found <N> gaps to fix. Proceed with remediation?",
    header: "Remediation",
    options: [
      { label: "Fix all automatically", description: "Generate/update all missing items" },
      { label: "Review each change", description: "Confirm each modification individually" },
      { label: "Abort", description: "Exit without changes" }
    ],
    multiSelect: false
  }]
)
```

For each gap:
1. Generate missing file from template
2. Update existing file if needed
3. Create commit for logical changes

**Do NOT skip any gaps.** Even Style-tier items must be fixed.

### Step 8.3: Verify

Re-run checklist. **ALL items MUST pass.**

If ANY item fails (Critical, Required, OR Style):
- Init CANNOT complete
- Return to Step 8.2 and fix the failing item
- Do NOT proceed with "good enough" mindset

---

## Phase 9: Setup Validation & Staleness Detection

### Setup Checksum

After successful init, generate a checksum of the configuration state:

```
checksum = sha256(
  concat(
    sort([
      hash(README.md),
      hash(CHANGELOG.md),
      hash(LICENSE),
      hash(.gitignore),
      hash(.gitleaks.toml),
      hash(CLAUDE.md),
      hash(package.json) if exists,
      hash(go.mod) if exists,
      hash(pyproject.toml) if exists,
      hash(Cargo.toml) if exists,
      hash(.golangci.yml) if exists,
      hash(tsconfig.json) if exists
    ])
  )
)
```

Store in `.claude/init-checksum.json`:
```json
{
  "checksum": "<sha256>",
  "version": "1.0",
  "created_at": "<ISO-8601>",
  "project_type": "<detected-type>",
  "language": "<detected-language>",
  "framework": "<detected-framework>",
  "files_tracked": ["<list of files included in checksum>"]
}
```

### Staleness Detection (`--validate` flag)

When `--validate` is run:

1. **Recalculate current checksum** from tracked files
2. **Compare with stored checksum**
3. **Report staleness:**

```markdown
## Init Validation: [repo-name]

| Check | Status | Details |
|-------|--------|---------|
| Checksum | Stale | Configuration changed since init |
| README.md | Valid | Matches init state |
| CLAUDE.md | Modified | Manual changes detected |
| .gitignore | Valid | Matches init state |

**Recommendation:** Run `/init` to update configuration
```

### Integration Health Checks

Validate that integrations are properly configured:

| Check | Validation |
|-------|------------|
| **CI Configured** | `.github/workflows/*.yml` exists with expected jobs |
| **Hooks Installed** | `.husky/` or `.git/hooks/` contains expected hooks |
| **Gitleaks Active** | CI workflow includes gitleaks job OR pre-commit configured |
| **Tests Runnable** | `npm test`, `go test`, or equivalent succeeds |
| **Lint Passes** | Lint command exits 0 |

```
AskUserQuestion(
  questions: [{
    question: "Some integration checks failed. How to proceed?",
    header: "Integration Health",
    options: [
      { label: "Fix automatically", description: "Attempt to repair failing integrations" },
      { label: "Show details", description: "Display what's wrong before deciding" },
      { label: "Skip for now", description: "Continue without fixing (not recommended)" }
    ],
    multiSelect: false
  }]
)
```

---

## Phase 10: Memory Recording (Post-Init)

### Success Recording

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Project initialized with fyrsmithlabs standards",
  content: "Project type: <type>. Language: <language>. Framework: <framework>.
            Gaps fixed: [list]. CLAUDE.md generated with <focus> focus.
            Checksum: <checksum>.",
  outcome: "success",
  tags: ["init", "<project-type>", "<language>"]
)
```

### Failure Recording

If init fails or is incomplete:

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Init incomplete: <reason>",
  content: "Failed checks: [list]. Blocked by: <tier> items.
            Attempted fixes: [list]. User action required.",
  outcome: "failure",
  tags: ["init", "failure", "<blocking-reason>"]
)
```

---

## Templates Used

From `git-repo-standards/templates/`:
- README.md.tmpl
- CHANGELOG.md.tmpl
- gitignore-go.tmpl / gitignore-generic.tmpl
- gitleaks.toml.tmpl

From `git-workflows/templates/`:
- fyrsmith-workflow.yml.tmpl
- pr-template.md.tmpl

From `init/templates/` (project type specific):
- claude-md-service.tmpl
- claude-md-cli.tmpl
- claude-md-library.tmpl
- claude-md-webapp.tmpl
- claude-md-monorepo.tmpl

---

## License Selection

```
IF project_type in [library, cli, tool]:
  license = Apache-2.0
ELSE IF project_type in [service, api, platform]:
  license = AGPL-3.0
```

---

## Quick Reference

| Flag | Behavior |
|------|----------|
| (none) | Full interactive wizard |
| `--check` | Audit only, no modifications |
| `--quick` | Auto-detect, skip wizard prompts |
| `--validate` | Check staleness and integration health |

| Phase | Description |
|-------|-------------|
| 1 | Pre-Flight & Detection |
| 2 | Interactive Configuration Wizard |
| 3 | Language-Specific Bootstrap |
| 4 | CLAUDE.md Generation |
| 5 | Severity Tiers & Compliance |
| 6 | Compliance Checklist |
| 7 | Remediation |
| 8 | Gap Report & Fix Process |
| 9 | Setup Validation & Staleness Detection |
| 10 | Memory Recording |

---

## Red Flags - STOP

If you're thinking:
- "Good enough for now"
- "I'll fix the rest later"
- "Warnings aren't critical"
- "Style items don't really matter"
- "Only Critical items block"
- "I'll create an issue for the warnings"
- "I already know what's missing"
- "Most things are done"
- "Auto-detection is probably right"
- "Skip the wizard to save time"

**You're rationalizing. Follow the skill exactly.**

ALL items must pass - Critical, Required, AND Style. There are no "optional" checklist items.

---

## Integration

This skill orchestrates:
- `git-repo-standards` - Structure, naming, files
- `git-workflows` - Review process, PR requirements
- `contextd:setup` - CLAUDE.md best practices (if contextd available)
