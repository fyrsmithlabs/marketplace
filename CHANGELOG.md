# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- 5 review agents for consensus code review (security, vulnerability, code-quality, documentation, user-persona)
- contextd MCP server dependency documentation
- `.mcp.json.example` for contextd setup
- `CHANGELOG.md`, `LICENSE` (Apache-2.0), `.gitleaks.toml` - plugin now follows its own standards

### Changed
- Simplified plugin structure from 46 to 27 files
- Enhanced skill and command descriptions with trigger phrases

### Fixed
- License mismatch in plugin.json (MIT → Apache-2.0)
- README.md now documents all 9 commands and 7 skills
- Plugin namespace renamed to fyrsmithlabs for correct namespacing
- Marketplace source format now uses relative paths

## [0.1.0] - 2026-01-08

### Added
- Initial release
- git-repo-standards skill for repository naming, structure, and documentation
- git-workflows skill for multi-agent consensus review
- project-onboarding skill for project initialization
- yagni skill for YAGNI/KISS enforcement
- complexity-assessment skill for task complexity evaluation
- github-planning skill for GitHub Issues/Projects integration
- roadmap-discovery skill for codebase analysis
- 9 slash commands (onboard, yagni, brainstorm, plan, discover, test-skill, comp-analysis, spec-refinement, app-interview)
- PostToolUse hooks for YAGNI/KISS detection and scope creep checks
- PreToolUse hooks for artifact placement, secrets check, and conventional commits

[Unreleased]: https://github.com/fyrsmithlabs/marketplace/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/fyrsmithlabs/marketplace/releases/tag/v0.1.0
