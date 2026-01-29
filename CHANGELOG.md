# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.8.0] - 2026-01-29

### Added
- **Research agent orchestration** - Multi-agent research system with 7 specialized agents (technical, security, UX, competitive, architectural, synthesis, orchestrator) for comprehensive feature research
- **Adaptive token budgets** - Dynamic budget allocation for consensus review based on scope size with formula `scale = min(4.0, 1.0 + total_tokens / 16384)`
- **Progressive summarization** - Graceful degradation for consensus review: full analysis (0-80%), high-severity only (80-95%), force return (95%+)
- **Context-folding isolation** - Branch mode for large scopes (>16K tokens) with automatic context isolation per agent
- **Comprehensive plugin documentation** - Full documentation for fs-dev, contextd, and fs-design plugins with examples and integration guides
- **Consensus review testing** - Runtime-validated test scenarios for small and medium scope reviews

### Changed
- **contextd input validation** - Documented new security hardening requirements (path validation, ID format, glob pattern validation) from contextd v1.5+
- **Shared orchestration patterns** - Consolidated orchestration patterns into `includes/orchestration/` for reuse across skills

### Removed
- **ASCII recordings** - Removed synthetic terminal recordings (placeholder demos)

### Security
- **contextd v1.5 hardening** - Documents CWE-22 (Path Traversal), CWE-287 (Auth Bypass), CWE-20 (Input Validation) mitigations

## [1.7.0] - 2026-01-29

### Added
- **effective-go skill** - Comprehensive Go development guide with Go 1.22+ features (Generics, Iterators, PGO)
- **go-reviewer agent** - Specialized reviewer for Go code quality and idioms
- **consensus-review command** - `/consensus-review` for multi-agent code review with veto power
- **41 test scenarios** with 46 pressure tests across 5 skills
- **Industry standards integration**:
  - OWASP Top 10 coverage in security and roadmap-discovery
  - WCAG 2.2 compliance in fs-design:check and roadmap-discovery
  - DORA metrics in product-owner skill
  - OpenSSF Best Practices in git-repo-standards
  - SBOM requirements in git-repo-standards
  - W3C Design Tokens (2025.10) in fs-design:check
  - WSJF prioritization in product-owner

### Changed
- **All 17 skills modernized** with Claude Code 2.1 features (+8,483 lines, +215% avg)
- **Claude Code 2.1 integration**:
  - Task tool with `run_in_background` (7 skills)
  - Task dependencies with `addBlockedBy` (7 skills)
  - PreToolUse/PostToolUse hooks (8 skills)
- **contextd integration** expanded to 14/17 skills (82%)
- **git-workflows** - Added git worktrees, all-agent veto power, `--ignore-vetos` flag
- **git-repo-standards** - Added SECURITY.md, CODEOWNERS, monorepo patterns, GitHub Actions templates
- **init** - Interactive wizard, language-specific bootstrap, staleness detection
- **yagni** - Complexity metrics, design pattern library, severity scoring, technical debt dashboard
- **complexity-assessment** - Testing dimension, risk multipliers, confidence scoring, JSON output
- **github-planning** - Native sub-issues, Projects v2 GraphQL, YAML issue forms, label taxonomy
- **product-owner** - AI risk scoring, velocity tracking, cross-project dependencies, Slack/Teams/Jira integration
- **context-folding** - Observability, adaptive budgets, dependency DAG, graceful degradation
- **roadmap-discovery** - DX/compliance/a11y lenses, complexity scoring, trend analysis, JIRA export
- **fs-design:check** - Stylelint integration, axe-core accessibility, CI pipeline integration
- **contextd:using-contextd** - Memory lifecycle, temporal decay, query expansion, hierarchical namespaces
- **contextd:setup** - Tech stack database, policy enforcement, setup checksums
- **contextd:workflow** - Checkpoint compression, checkpoint branching, auto-error capture hooks
- **contextd:consensus-review** - Dynamic reviewer selection, finding relationships, incremental review
- **contextd:orchestration** - Resource monitoring, concurrency limits, dead letter queue
- **contextd:self-reflection** - Causal chain analysis, comparative benchmarks, behavioral prediction

### Fixed
- contextd skills now work without MCP server (file-based fallback)
- Unified memory types across all contextd skills (learning, remediation, decision, failure, pattern, policy)
- Event-driven state sharing between skills
- Audit logging fields (created_by, created_at, usage_count) standardized

## [1.3.0] - 2026-01-26

### Added
- **Health monitoring documentation** in `using-contextd` skill - HTTP endpoints for vectorstore integrity
- **Health status** in `contextd-status` command - Shows healthy/degraded state with collection counts
- **Graceful degradation** documentation - P0 production hardening for corrupt collection handling
- **Reflection tools** in Core Tools table - `reflect_analyze`, `reflect_report` for behavior analysis

### Changed
- `contextd-status` now checks HTTP health endpoint before displaying status
- Updated health check examples with curl commands

### Security
- Documents CVE-2024-3078 Qdrant upgrade requirement (v1.7.4 → v1.8.3)
- Health endpoint security note for production deployments

## [1.2.0] - 2026-01-19

### Added
- 5 review agents for consensus code review (security, vulnerability, code-quality, documentation, user-persona)
- **Skill test scenarios** for TDD-style validation (23 scenarios across 4 skills)
- **Force Push Policy** in git-workflows - secret removal with credential rotation is only allowed case
- **MIT/BSD license coverage** in git-repo-standards - alternative licenses flagged with warnings
- **Severity tiers** in init - Critical/Required/Style with explicit blocking rules
- **Remediation guidance** in init - handling existing incorrect files (additive, not destructive)
- contextd MCP server dependency documentation
- `.mcp.json.example` for contextd setup
- `CHANGELOG.md`, `LICENSE` (Apache-2.0), `.gitleaks.toml` - plugin now follows its own standards

### Changed
- Renamed `not-hotdog` to `yagni` - more descriptive than Silicon Valley reference
- Renamed `/onboard` to `/init` - single command for project setup (auto-detects new vs existing)
- Simplified `/init` modes: just `/init` and `/init --check` (removed init/onboard/validate complexity)
- Simplified plugin structure from 46 to 27 files
- Enhanced skill and command descriptions with trigger phrases
- **Simplified YAGNI system** - removed 9 character personalities, now uses structured tree-style output
  - Reduced includes from 3 files (700+ lines) to 1 file (55 lines)
  - Output is now structured and token-efficient
  - Patterns reduced to 4 core types: abstraction, config-addiction, scope-creep, dead-code

### Fixed
- **hooks.json format** - Changed to correct nested format `{"hooks": {"PreToolUse": [...]}}` (was causing startup errors)
- License mismatch in plugin.json (MIT → Apache-2.0)
- README.md now documents all commands and skills
- Plugin namespace renamed to fyrsmithlabs for correct namespacing

## [0.1.0] - 2026-01-08

### Added
- Initial release
- git-repo-standards skill for repository naming, structure, and documentation
- git-workflows skill for multi-agent consensus review
- init skill for project initialization
- yagni skill for YAGNI/KISS enforcement
- complexity-assessment skill for task complexity evaluation
- github-planning skill for GitHub Issues/Projects integration
- roadmap-discovery skill for codebase analysis
- 9 slash commands (init, yagni, brainstorm, plan, discover, test-skill, comp-analysis, spec-refinement, app-interview)
- PostToolUse hooks for YAGNI/KISS detection and scope creep checks
- PreToolUse hooks for artifact placement, secrets check, and conventional commits

[1.8.0]: https://github.com/fyrsmithlabs/marketplace/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/fyrsmithlabs/marketplace/compare/v1.3.0...v1.7.0
[1.3.0]: https://github.com/fyrsmithlabs/marketplace/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/fyrsmithlabs/marketplace/compare/v0.1.0...v1.2.0
[0.1.0]: https://github.com/fyrsmithlabs/marketplace/releases/tag/v0.1.0
