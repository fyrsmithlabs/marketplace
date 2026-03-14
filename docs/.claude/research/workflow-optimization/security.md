# Security Research: Security Review Automation in Agent Workflows

**Agent:** research-security
**Date:** 2026-03-05
**Confidence:** HIGH
**Sources:** 30+ web searches including OWASP, GitGuardian, SLSA, academic papers

---

## Focus Areas Investigated

1. Automated vulnerability scanning in AI agent workflows
2. Security gate enforcement in autonomous pipelines
3. Secrets scanning integration (GitGuardian MCP, gitleaks)
4. Audit trail generation for security decisions
5. Supply chain security (SBOM, SLSA, dependency verification)
6. OWASP Top 10 for Agentic Applications 2026
7. Prompt injection prevention
8. PreToolUse/PostToolUse hooks for security enforcement

---

## Key Findings

### 1. OWASP Top 10 for Agentic Applications 2026

**Confidence: HIGH**

Released December 2025, this is the authoritative framework for agentic AI security. All 10 risks are relevant to the fyrsmithlabs plugin architecture:

| Risk | ID | Relevance to fyrsmithlabs |
|------|----|-----------------------|
| Agent Goal Hijack | ASI01 | Agent instructions could be manipulated via untrusted content |
| Tool Misuse & Exploitation | ASI02 | Agents have Bash, Write access -- misuse is possible |
| Identity & Privilege Abuse | ASI03 | Agents inherit user's git credentials and API tokens |
| Agentic Supply Chain | ASI04 | Plugin marketplace is a supply chain attack vector |
| Unexpected Code Execution | ASI05 | Bash tool can execute attacker-controlled code |
| Memory & Context Poisoning | ASI06 | contextd memories could be poisoned |
| Insecure Inter-Agent Communication | ASI07 | Task tool passes data between agents without validation |
| Cascading Failures | ASI08 | Parallel agent failures can propagate |
| Human-Agent Trust Exploitation | ASI09 | Confident agent output may bypass human review |
| Rogue Agents | ASI10 | Compromised agent definitions could diverge from intent |

**Applicable to fyrsmithlabs:** The existing security-reviewer and vulnerability-reviewer agents should be updated to check for these 10 categories. The PreToolUse hooks are the primary enforcement mechanism.

**Sources:**
- [OWASP Top 10 for Agentic Applications 2026](https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/)
- [Palo Alto Networks Analysis](https://www.paloaltonetworks.com/blog/cloud-security/owasp-agentic-ai-security/)

### 2. GitGuardian MCP Integration

**Confidence: HIGH**

GitGuardian has released an MCP server for real-time secrets scanning:

- **500+ secret detectors** for API keys, tokens, passwords, certificates
- **MCP protocol integration** -- works with Claude Code, Cursor, Windsurf
- **Real-time scanning** during development, not just at commit time
- **Honeytoken generation** for detecting unauthorized access
- **Automated remediation** suggestions within the development workflow

**Applicable to fyrsmithlabs:** Add GitGuardian MCP server to recommended MCP configuration. Create a PreToolUse:Write hook that scans file content for secrets before writing to disk.

**Sources:**
- [GitGuardian MCP Server - GitHub](https://github.GitGuardian/ggmcp)
- [Shifting Security Left for AI Agents](https://blog.gitguardian.com/shifting-security-left-for-ai-agents-enforcing-ai-generated-code-security-with-gitguardian-mcp/)
- [Building a Multi-Agent Security Pipeline with A2A and GitGuardian](https://blog.gitguardian.com/building-a-multi-agent-security-pipeline-with-googles-a2a-protocol-and-gitguardian/)

### 3. PreToolUse Hooks for Security Enforcement

**Confidence: HIGH**

PreToolUse is the only hook that can block actions, making it the security enforcement point:

- Starting v2.0.10, PreToolUse hooks can **modify tool inputs** before execution (dry-run flags, secret redaction)
- Uses `hookSpecificOutput.permissionDecision` to ALLOW or DENY
- Can be scoped to specific tools: `PreToolUse:Bash`, `PreToolUse:Write`, `PreToolUse:Edit`
- As of Feb 2026, Claude Code has 14 lifecycle events and 3 handler types (command, prompt, agent)

**Recommended security hooks for fyrsmithlabs:**

| Hook | Event | Check |
|------|-------|-------|
| Branch guard | `PreToolUse:Bash` | Block `git push` to main/master |
| Secrets scan | `PreToolUse:Write` | Scan content for API keys, tokens before file write |
| Destructive command guard | `PreToolUse:Bash` | Block `rm -rf`, `git reset --hard`, `DROP TABLE` |
| Pre-commit validation | `PreToolUse:Bash` (git commit) | Run gitleaks, go vet, go test before commit |
| Dependency check | `PreToolUse:Bash` (go get) | Verify package is not known-malicious before installing |

**Sources:**
- [Hooks Reference - Claude Code Docs](https://code.claude.com/docs/en/hooks)
- [Claude Code Hooks Guide - All 12 Lifecycle Events](https://www.pixelmojo.io/blogs/claude-code-hooks-production-quality-ci-cd-patterns)
- [Secure Your Claude Skills with Custom PreToolUse Hooks](https://egghead.io/secure-your-claude-skills-with-custom-pre-tool-use-hooks~dhqko)

### 4. Audit Trail for Agent Decisions

**Confidence: HIGH**

Agent audit trails must capture the "why" alongside the "what":

- **Required fields**: who (agent ID), what (action), when (timestamp), why (prompt + context + decision logic), result
- **Unique identifiers**: UUID per build, deployment, agent instance, access event
- **Real-time monitoring**: contextual analysis, not just log aggregation
- **Regulatory alignment**: EU AI Act enforcement starting August 2026, SOC 2 and GDPR audits scrutinizing AI agent access

**Current state in fyrsmithlabs:** Agent outputs go to `docs/.claude/` per the agent-artifacts skill, but there is no structured audit trail with UUID tracking, decision rationale, or compliance mapping.

**Recommendation:** Create an `audit-trail` skill that writes structured JSON logs for every consensus review decision, including agent verdicts, veto exercises, finding counts, and resolution actions.

**Sources:**
- [AI Agent Audit Trail: Complete Guide 2026](https://fast.io/resources/ai-agent-audit-trail/)
- [Audit Trails in CI/CD: Best Practices for AI Agents](https://prefactor.tech/blog/audit-trails-in-ci-cd-best-practices-for-ai-agents)
- [The Growing Challenge of Auditing Agentic AI - ISACA](https://www.isaca.org/resources/news-and-trends/industry-news/2025/the-growing-challenge-of-auditing-agentic-ai)

### 5. Supply Chain Security

**Confidence: MEDIUM**

Key frameworks and tools for Go-first development:

| Tool/Framework | Purpose | Maturity |
|---------------|---------|----------|
| **govulncheck** | Go vulnerability scanning | Production-ready |
| **cyclonedx-gomod** | SBOM generation for Go modules | Mature |
| **SLSA** | Supply chain integrity levels | SLSA Level 2 achievable with GitHub Actions |
| **Sigstore/cosign** | Artifact signing | Mature but overkill for plugin marketplace |
| **Dependabot/Renovate** | Automated dependency updates | Production-ready |

**SLSA Level 2** is the recommended target: requires source-aware build system and provenance signatures. Achievable with GitHub Actions and minimal configuration.

**Sources:**
- [SLSA Framework](https://slsa.dev/)
- [SBOMs in 2026: Love, Hate, Ambivalence](https://www.darkreading.com/application-security/sboms-in-2026-some-love-some-hate-much-ambivalence)
- [Software Supply Chain Security Goes Continuous](https://www.efficientlyconnected.com/2026-predictions-software-supply-chain-security-shifts-to-continuous-verification/)

### 6. Prompt Injection Prevention

**Confidence: HIGH**

Prompt injection appeared in 73% of production AI system audits in 2025:

- Multi-agent defense pipelines can fully mitigate all 55 known attack types
- Sanitize all prompts from users or internal processes
- Independently validate outputs before propagation
- Provenance tracking across data types improves detection
- Immutable configurations and cryptographic verification preferred over detection-based

**Applicable to fyrsmithlabs:** The plugin marketplace itself is a supply chain vector (ASI04). Plugin manifest files should be verified. Agent prompts should not incorporate untrusted external content without sanitization.

**Sources:**
- [Multi-Agent LLM Defense Pipeline Against Prompt Injection](https://arxiv.org/html/2509.14285v4)
- [Prompt Injection: The Hidden Threat - Lakera](https://www.lakera.ai/blog/indirect-prompt-injection)

---

## Recommendations for fyrsmithlabs

1. **Expand PreToolUse hooks** with branch guard, secrets scan, destructive command guard, pre-commit validation (P0)
2. **Integrate GitGuardian MCP** for real-time secrets scanning during development (P1)
3. **Create audit-trail skill** with structured JSON logging and UUID tracking (P2)
4. **Update security-reviewer** to check against OWASP Agentic Top 10 categories (P1)
5. **Add govulncheck** to pre-commit validation hooks (P1)
6. **Target SLSA Level 2** for the marketplace itself using GitHub Actions (P2)
7. **Add plugin manifest verification** to protect against supply chain attacks (P2)
