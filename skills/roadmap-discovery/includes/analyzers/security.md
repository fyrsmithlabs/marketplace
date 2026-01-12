# Security Analyzer

Identify security vulnerabilities and risks.

## Analysis Categories

### 1. Authentication & Authorization

**Patterns to Check:**
- Missing auth middleware on routes
- Hardcoded credentials or API keys
- Insecure session management
- Missing CSRF protection
- Improper JWT validation

**Search Patterns:**
```
Grep: password|secret|api_key|apikey|token
Grep: Authorization|Bearer|Basic
Glob: **/auth/**/*.{js,ts,go,py}
```

### 2. Input Validation

**Patterns to Check:**
- SQL injection vulnerabilities
- Command injection risks
- Path traversal possibilities
- XSS attack vectors
- Unvalidated redirects

**Search Patterns:**
```
Grep: exec\(|eval\(|system\(
Grep: innerHTML|dangerouslySetInnerHTML
Grep: SELECT.*\+|INSERT.*\+
```

### 3. Data Protection

**Patterns to Check:**
- PII exposure in logs
- Missing encryption for sensitive data
- Insecure data transmission
- Improper error messages exposing internals

**Search Patterns:**
```
Grep: console\.log.*password|email|ssn
Grep: http://(?!localhost)
```

### 4. Dependencies

**Patterns to Check:**
- Known vulnerable packages
- Outdated dependencies
- Unmaintained packages

**Commands:**
```bash
npm audit --json 2>/dev/null
go list -m -u all 2>/dev/null
pip-audit --format json 2>/dev/null
```

### 5. Configuration

**Patterns to Check:**
- Debug mode in production
- Permissive CORS settings
- Missing security headers
- Exposed sensitive endpoints

**Search Patterns:**
```
Grep: DEBUG.*=.*true|True|TRUE
Grep: Access-Control-Allow-Origin.*\*
```

## Severity Classification

| Finding | Severity |
|---------|----------|
| Hardcoded secrets | CRITICAL |
| SQL injection | CRITICAL |
| Missing auth on sensitive routes | CRITICAL |
| XSS vulnerability | MAJOR |
| Missing CSRF protection | MAJOR |
| Debug mode enabled | MAJOR |
| Outdated dependencies with CVE | MAJOR |
| Missing input validation | MINOR |
| Permissive CORS | MINOR |

## Output Format

```json
{
  "id": "sec_001",
  "lens": "security",
  "severity": "CRITICAL",
  "title": "Hardcoded API key in config",
  "description": "Found plaintext API key in config/settings.js",
  "location": "config/settings.js:42",
  "recommendation": "Move to environment variable, add to .gitignore",
  "effort": "low",
  "references": ["https://owasp.org/secrets-management"]
}
```
