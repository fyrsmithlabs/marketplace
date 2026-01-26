# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.2.0]: https://github.com/fyrsmithlabs/marketplace/compare/v1.0.0...v1.2.0
[1.0.0]: https://github.com/fyrsmithlabs/marketplace/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/fyrsmithlabs/marketplace/releases/tag/v0.1.0
