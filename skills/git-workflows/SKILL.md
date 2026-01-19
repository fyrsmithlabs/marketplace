---
name: git-workflows
description: Use when working with git operations, PRs, or code reviews - enforces modern agentic git workflows with multi-agent consensus review using contextd for memory, context folding, and learning capture
---

# Git Workflows

Modern agentic git workflow enforcement with multi-agent consensus review. Integrates deeply with contextd for cross-session learning, context folding, and remediation tracking.

## Core Principles

1. **Flexible Trigger, Full Traceability** - Any work trigger acceptable, all changes traceable via commit/PR metadata
2. **Agent-Assisted, Human-Owned** - Agents propose, humans approve; AI code never ships without human sign-off
3. **Trunk-Based, Short-Lived** - Branches <24h encouraged, squash merge only, auto-delete after merge
4. **Consensus Before Human Review** - Multi-agent consensus gate before human reviewers engaged
5. **contextd-First** - ReasoningBank, context folding, and remediation are first-class citizens

---

## Multi-Agent Consensus Review

### The Review Council

| Agent | Focus | Veto Power | Budget |
|-------|-------|------------|--------|
| **Security** | Auth, injection, secrets, OWASP | Yes | 8192 |
| **Vulnerability** | CVEs, deps, supply chain | Yes | 8192 |
| **Code Quality** | Logic, complexity, patterns, tests | No | 8192 |
| **Documentation** | README, comments, API docs, CHANGELOG | No | 4096 |
| **User Persona** | UX impact, breaking changes, API ergonomics | No | 4096 |

### Consensus Rules

- Security/Vulnerability agents have **veto power** on security issues
- Other agents use **weighted majority** for their domains
- **100% consensus** required: all Critical/High/Medium resolved
- Low findings: auto-create issues if <3, author triage if ≥3

---

## Workflow Phases

### Phase 1: Pre-Flight (ReasoningBank)

**MANDATORY before starting review:**

```
1. mcp__contextd__semantic_search(
     query: "code patterns in [changed files]",
     project_path: "."
   )
   → Understand codebase context

2. mcp__contextd__memory_search(
     project_id: "<project>",
     query: "PR review patterns [area]"
   )
   → Retrieve past review strategies

3. mcp__contextd__remediation_search(
     query: "common issues in [file types]",
     tenant_id: "<tenant>",
     include_hierarchy: true
   )
   → Pre-load known problem patterns

4. mcp__contextd__checkpoint_save(
     session_id: "<session>",
     project_path: ".",
     name: "review-start-PR-XXX",
     description: "Starting consensus review",
     summary: "5-agent review of PR #XXX",
     context: "[PR description, files changed]",
     full_state: "[complete PR context]",
     token_count: <current>,
     threshold: 0.0,
     auto_created: false
   )
   → Preserve review start state
```

### Phase 2: Parallel Agent Review (Context Folding)

Launch all 5 agents in isolated branches:

```
# For each agent:
mcp__contextd__branch_create(
  session_id: "<session>",
  description: "[Agent] review of PR #XXX",
  prompt: "[Agent-specific review instructions - see below]",
  budget: [agent budget],
  timeout_seconds: 300
)
→ Returns: branch_id

# Each agent internally:
# 1. semantic_search for relevant code
# 2. remediation_search for known patterns
# 3. Analyze and produce findings
# 4. Return structured results
```

**Agent Prompts:**

#### Security Agent
```
You are a SECURITY REVIEWER analyzing PR #XXX.

Context from pre-flight:
[Include semantic_search results]
[Include relevant remediation patterns]

Review focus:
1. Injection vulnerabilities (SQL, command, XSS)
2. Authentication/authorization flaws
3. Secrets exposure (hardcoded keys, tokens)
4. Supply chain risks (new dependencies)
5. OWASP Top 10 violations

For each finding:
- Severity: CRITICAL / HIGH / MEDIUM / LOW
- Location: file:line
- Issue: What's wrong
- Recommendation: How to fix
- Related remediation: [ID if from remediation_search]

You have VETO POWER on security issues.
```

#### Vulnerability Agent
```
You are a VULNERABILITY REVIEWER analyzing PR #XXX.

Review focus:
1. Known CVEs in dependencies
2. Outdated packages with security patches
3. Dependency confusion risks
4. License compliance issues
5. Transitive dependency risks

For each finding:
- Severity: CRITICAL / HIGH / MEDIUM / LOW
- Location: file or dependency
- CVE: [if applicable]
- Issue: What's vulnerable
- Recommendation: Version upgrade or mitigation

You have VETO POWER on security issues.
```

#### Code Quality Agent
```
You are a CODE QUALITY REVIEWER analyzing PR #XXX.

Review focus:
1. Logic errors and edge cases
2. Test coverage gaps
3. Cyclomatic complexity spikes
4. Code duplication
5. Pattern violations
6. Error handling gaps

For each finding:
- Severity: CRITICAL / HIGH / MEDIUM / LOW
- Location: file:line
- Issue: What's wrong
- Recommendation: How to fix
```

#### Documentation Agent
```
You are a DOCUMENTATION REVIEWER analyzing PR #XXX.

Review focus:
1. README updates needed
2. Missing/outdated code comments
3. API documentation gaps
4. CHANGELOG entry required
5. Breaking change documentation

For each finding:
- Severity: MEDIUM / LOW
- Location: file or section
- Issue: What's missing
- Recommendation: What to add
```

#### User Persona Agent
```
You are a USER EXPERIENCE REVIEWER analyzing PR #XXX.

Review focus:
1. Breaking API changes
2. Migration path clarity
3. Error message quality
4. Configuration complexity
5. Developer ergonomics

For each finding:
- Severity: MEDIUM / LOW
- Location: file:line or feature
- Issue: UX impact
- Recommendation: Improvement
```

### Phase 3: Collect & Aggregate

```
# For each agent:
mcp__contextd__branch_return(
  branch_id: "<branch>",
  message: "[Structured findings JSON]"
)
→ Auto-scrubs secrets before return

# Aggregate findings:
1. Parse all agent responses
2. Tally by severity across agents
3. Identify consensus (2+ agents = higher priority)
4. De-duplicate similar findings
5. Apply veto rules:
   - Security/Vuln CRITICAL/HIGH on security → BLOCK regardless
   - Other agents → weighted majority
```

**Findings Structure:**
```json
{
  "agent": "security",
  "verdict": "REQUEST_CHANGES",
  "findings": [
    {
      "severity": "HIGH",
      "location": "auth/handler.go:45",
      "issue": "SQL injection via unsanitized user input",
      "recommendation": "Use parameterized queries",
      "related_remediation": "rem_abc123"
    }
  ],
  "summary": {
    "critical": 0,
    "high": 1,
    "medium": 2,
    "low": 0
  }
}
```

### Phase 4: Consensus Decision

```
IF any agent has Critical/High/Medium findings:
  → BLOCK PR
  → Return to author with:
    - All findings prioritized
    - remediation_search suggestions for each
    - Links to past solutions

IF only Low findings:
  IF count < 3:
    → Auto-create GitHub issues for each
    → Link issues to PR
    → Mark as "deferred to backlog"
  ELSE (≥3):
    → Require author to triage
    → Author acknowledges or disputes each
    → Issues created for acknowledged items

IF all agents APPROVE (no Critical/High/Medium, Low handled):
  → CONSENSUS PASSED
  → Proceed to human review tier
```

### Phase 5: Post-Flight (Learning Capture)

**MANDATORY after review completes:**

```
# 1. Record review outcome
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "PR #XXX review - [PASSED|BLOCKED]",
  content: "Agents: 5, Findings: [summary], Novel: [patterns],
            Blocked on: [if blocked], Time: [duration]",
  outcome: "success" | "failure",
  tags: ["pr-review", "consensus", "<project>", "<severity>"]
)

# 2. Record novel findings as remediations
# For each finding NOT from existing remediation:
mcp__contextd__remediation_record(
  title: "[Issue pattern title]",
  problem: "[Exact issue found]",
  symptoms: ["[observable symptoms]"],
  root_cause: "[Why it's a problem]",
  solution: "[How to fix]",
  affected_files: ["[files]"],
  category: "security" | "syntax" | "logic" | "config" | etc,
  confidence: 0.8,
  tags: ["pr-review", "[category]", "<project>"],
  tenant_id: "<tenant>",
  scope: "org"  # Share across projects
)

# 3. Feedback on memories that helped
mcp__contextd__memory_feedback(
  memory_id: "<id>",
  helpful: true | false
)

# 4. Report outcome for memories used
mcp__contextd__memory_outcome(
  memory_id: "<id>",
  succeeded: true | false,
  session_id: "<session>"
)

# 5. Final checkpoint
mcp__contextd__checkpoint_save(
  session_id: "<session>",
  project_path: ".",
  name: "review-complete-PR-XXX",
  description: "Consensus review completed",
  summary: "[verdict]: [finding counts]",
  context: "[final state]",
  full_state: "[complete audit trail if Full Trace mode]",
  token_count: <current>,
  threshold: 0.0,
  auto_created: false
)
```

---

## Human Review Tiers (Label-Based)

After agent consensus passes, human review is required:

```yaml
# Configurable in .github/fyrsmith-workflow.yml
review:
  tiers:
    - labels: [critical-path, security-sensitive, breaking-change]
      approvals: 2  # Configurable
      required_reviewers: ["@security-team"]
    - labels: [api-change, infrastructure]
      approvals: 2
    - labels: []  # default
      approvals: 1
```

| Label | Approvals | Rationale |
|-------|-----------|-----------|
| `critical-path` | 2 | Core system changes |
| `security-sensitive` | 2 | Security-related code |
| `breaking-change` | 2 | API/behavior breaking |
| `api-change` | 2 | Public API modifications |
| `infrastructure` | 2 | Infra/deployment changes |
| (default) | 1 | Standard changes |

---

## Branch & Merge Strategy

**Model:** Trunk-Based with Short-Lived Branches

```
main (protected)
  └── feature/short-description
  └── fix/issue-number-description
  └── chore/cleanup-description
```

### Branch Naming

| Type | Purpose | Example |
|------|---------|---------|
| `feature/` | New functionality | `feature/plugin-search` |
| `fix/` | Bug fixes | `fix/123-auth-timeout` |
| `chore/` | Maintenance, deps | `chore/update-deps` |
| `docs/` | Documentation only | `docs/api-reference` |
| `refactor/` | Code restructuring | `refactor/auth-module` |
| `release/` | Release prep | `release/1.2.0` |

### Stale Branch Cleanup

| Timeline | Action |
|----------|--------|
| 24h | Warning notification |
| 48h | Auto-close PR |
| 72h | Delete branch |

**Exception:** `long-running` label exempts from auto-close.

### Merge Requirements

- Squash merge only (linear history)
- Branch must be up-to-date with main
- Auto-delete branch after merge
- All CI checks passing
- Agent consensus passed
- Human approvals met

### Force Push Policy

Force push is **prohibited** except for one specific case:

| Scenario | Allowed | Required Actions |
|----------|---------|------------------|
| Secret accidentally committed | **Yes** | 1. Rotate credential immediately, 2. Force push to remove from history, 3. Verify removal, 4. Document in PR |
| Clean up commit history | No | Use interactive rebase before push |
| Fix merge conflicts | No | Pull and merge properly |
| Override CI failures | No | Fix the actual issue |
| "Clean up" force push to main | **Never** | Not allowed under any circumstances |

**Secret Removal Procedure:**

**Recommended: Use git-filter-repo (safer, faster):**
```bash
# 1. IMMEDIATELY rotate the exposed credential
# 2. Install git-filter-repo: pip install git-filter-repo
# 3. Remove file from history (use single quotes to prevent injection):
git filter-repo --invert-paths --path 'config/secrets.json'

# 4. Force push (branch only, NEVER main)
git push origin --force --all
```

**Alternative: BFG Repo-Cleaner:**
```bash
# For removing specific secrets from all files:
bfg --replace-text passwords.txt repo.git
```

**Legacy: git filter-branch (deprecated, use with caution):**
```bash
# WARNING: Ensure filename is properly escaped
# NEVER use user input directly in this command
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch -- "config/secrets.json"' \
  --prune-empty --tag-name-filter cat -- --all

# Clean up refs
git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
git reflog expire --expire=now --all
git gc --prune=now
```

**Security Warning:** Never interpolate untrusted input into shell commands. Always validate and escape file paths before use.

**Key Rule:** Force push for secret removal is acceptable ONLY with immediate credential rotation. The credential must be rotated BEFORE the force push completes.

---

## PR Structure (Agent-Assisted)

Agent auto-generates PR description from commits; author reviews and approves:

```markdown
## Description
<!-- Agent-generated from commits, author-verified -->
[Auto-generated summary of changes]

## Change Type
- [ ] feat | fix | refactor | docs | chore | test

## Test Plan
- [ ] Unit tests added/updated
- [ ] Integration tests (if applicable)
- [ ] Manual testing performed

## Breaking Changes
- [ ] None
- [ ] Yes: <!-- describe migration path -->

## Linked Issues
Closes #XXX

---
## Agent Review Summary
| Agent | Verdict | Critical | High | Medium | Low |
|-------|---------|----------|------|--------|-----|
| Security | ✅ | 0 | 0 | 0 | 0 |
| Vulnerability | ✅ | 0 | 0 | 0 | 0 |
| Code Quality | ✅ | 0 | 0 | 1 | 2 |
| Documentation | ⚠️ | 0 | 0 | 1 | 0 |
| User Persona | ✅ | 0 | 0 | 0 | 1 |

**Consensus:** PASSED
**Low Issues Created:** #124, #125, #126
```

---

## Agent-Generated Commits

When agents commit directly (GitHub Copilot agent mode, etc.):

| Rule | Implementation |
|------|----------------|
| Auto-label | `agent-generated` label applied |
| Same rules | Identical consensus loop, no exceptions |
| Track separately | Metrics collected for process improvement |
| Audit trail | Full trace mode recommended |

---

## Audit Trail Levels

| Level | Captured | Storage |
|-------|----------|---------|
| **Standard** | Agent verdicts, findings summary, consensus result, issues created | `memory_record` |
| **Full Trace** | + Agent reasoning, branch timelines, debate transcripts, confidence scores | `checkpoint_save` with `full_state` |

**Configuration:**
```yaml
consensus:
  tracing:
    level: standard  # standard | full
    contextd_enabled: true
```

---

## Configuration Schema

```yaml
# .github/fyrsmith-workflow.yml

consensus:
  agents:
    security:
      enabled: true
      veto_power: true
      budget: 8192
    vulnerability:
      enabled: true
      veto_power: true
      budget: 8192
    code_quality:
      enabled: true
      veto_power: false
      budget: 8192
    documentation:
      enabled: true
      veto_power: false
      budget: 4096
    user_persona:
      enabled: true
      veto_power: false
      budget: 4096

  thresholds:
    block_on: [critical, high, medium]
    auto_issue_below: 3  # Low findings count

  tracing:
    level: standard
    contextd_enabled: true

review:
  tiers:
    - labels: [critical-path, security-sensitive, breaking-change]
      approvals: 2
    - labels: [api-change, infrastructure]
      approvals: 2
    - labels: []
      approvals: 1

branches:
  strategy: trunk-based
  merge_method: squash
  auto_delete: true
  stale:
    warn_days: 1
    close_days: 2
    delete_days: 3
    exempt_labels: [long-running]

pr_template:
  agent_assisted: true
  required_sections:
    - description
    - change_type
    - test_plan
    - breaking_changes
    - linked_issues

agent_commits:
  label: agent-generated
  same_rules: true
  track_metrics: true
```

---

## Quick Reference

| Phase | contextd Tools | Purpose |
|-------|----------------|---------|
| Pre-flight | `semantic_search`, `memory_search`, `remediation_search`, `checkpoint_save` | Context loading |
| Review | `branch_create` (x5), `branch_status` | Isolated agent execution |
| Collect | `branch_return` (x5) | Gather findings |
| Post-flight | `memory_record`, `remediation_record`, `memory_feedback`, `memory_outcome`, `checkpoint_save` | Learning capture |

---

## Common Mistakes

| Mistake | Prevention |
|---------|------------|
| Skipping pre-flight memory search | Protocol violation - always search first |
| Not using context folding for agents | Agents MUST run in isolated branches |
| Forgetting post-flight learning capture | Record outcomes for every review |
| Ignoring veto power | Security/Vuln vetoes are non-negotiable |
| Not creating issues for Low findings | All findings must be tracked |
| Skipping remediation_record for novel issues | Novel patterns must be captured |

---

## Integration with git-repo-standards

This skill works alongside `git-repo-standards`:

| git-repo-standards | git-workflows |
|--------------------|---------------|
| Repo structure | PR/review process |
| Naming conventions | Branch naming |
| README/CHANGELOG | PR template |
| Gitleaks config | Security agent |
| License compliance | Vulnerability agent |
