# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.8.x   | :white_check_mark: |
| < 1.8   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please report it responsibly.

### How to Report

1. **Do not** open a public GitHub issue for security vulnerabilities
2. Email security concerns to: **security@fyrsmithlabs.com**
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days
- **Resolution Timeline**: Depends on severity
  - Critical: 24-48 hours
  - High: 7 days
  - Medium: 30 days
  - Low: Next release

### Scope

This security policy covers:
- The marketplace plugin code
- Skills, commands, and agents
- Hook configurations
- Documentation containing security guidance

### Out of Scope

- The contextd MCP server (separate repository)
- Claude Code itself (report to Anthropic)
- Third-party dependencies (report to maintainers)

## Security Considerations

### Plugin Security Model

Claude Code plugins operate within the Claude Code sandbox. However, plugins can:
- Define hooks that influence LLM behavior
- Provide prompts that guide code generation
- Access files within the project directory

### Best Practices

When using this marketplace:
1. Review plugin code before installation
2. Keep plugins updated to latest versions
3. Use gitleaks to prevent credential commits
4. Follow the security-reviewer agent recommendations

## Acknowledgments

We appreciate responsible disclosure and will acknowledge security researchers who help improve our security posture.
