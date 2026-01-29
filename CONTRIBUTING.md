# Contributing to Marketplace

Thank you for your interest in contributing to the fyrsmithlabs marketplace. This document provides guidelines for contributing.

## Code of Conduct

Be respectful, inclusive, and constructive. We welcome contributors of all experience levels.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Install Claude Code CLI
4. Test your changes with `/test-skill`

## Types of Contributions

### Skills

Skills provide domain expertise and workflows. To contribute a skill:

1. Create a directory under `skills/<skill-name>/`
2. Add `SKILL.md` with the skill definition
3. Include test scenarios in `tests/scenarios.md`
4. Update the README and CLAUDE.md

### Commands

Commands are user-invoked actions. To contribute a command:

1. Create `commands/<command-name>.md`
2. Follow the command template format
3. Document usage and examples

### Agents

Agents are specialized subagents for specific tasks. To contribute an agent:

1. Create `agents/<agent-name>.md`
2. Define focus areas and output format
3. Specify veto power if applicable

### Bug Fixes

1. Check existing issues first
2. Create a minimal reproduction
3. Submit a PR with test coverage

## Development Workflow

### Branch Naming

- `feature/<description>` - New features
- `fix/<description>` - Bug fixes
- `docs/<description>` - Documentation updates

### Commit Messages

Follow conventional commits:

```
type(scope): description

- feat: New feature
- fix: Bug fix
- docs: Documentation
- chore: Maintenance
- test: Test updates
```

### Pull Request Process

1. Run `/consensus-review` on your changes
2. Address all HIGH and CRITICAL findings
3. Update documentation
4. Request review

### Testing

Before submitting:

```bash
# Run skill tests
/test-skill <your-skill>

# Run consensus review
/consensus-review
```

## Quality Standards

### Skills Must

- Include clear triggers and descriptions
- Have test scenarios with expected behaviors
- Follow kebab-case naming
- Document contextd integration (if applicable)

### Commands Must

- Have clear usage examples
- Document all arguments
- Include error handling guidance

### Agents Must

- Output structured JSON
- Define severity ratings
- Specify veto conditions

## Review Process

All contributions go through:

1. **Automated checks** - Linting, structure validation
2. **Consensus review** - Multi-agent code review
3. **Maintainer review** - Final approval

## License

By contributing, you agree that your contributions will be licensed under the Apache-2.0 License.

## Questions?

Open a discussion or reach out to the maintainers.
