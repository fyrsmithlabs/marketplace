# UX Research: Developer Experience in AI-Assisted Workflows

**Agent:** research-ux
**Date:** 2026-03-05
**Confidence:** MEDIUM-HIGH
**Sources:** 20+ web searches across UX research, practitioner articles, and tool documentation

---

## Focus Areas Investigated

1. Preflight validation patterns to reduce session-killing friction
2. Session recovery after failures
3. Progressive disclosure for complex multi-agent outputs
4. Wrong-approach prevention (agent diverges from intent)
5. User preference learning and feedback mechanisms

---

## Key Findings

### 1. Preflight Validation Patterns

**Confidence: HIGH**

Best practices for reducing session-killing friction (addresses 12 environment error events):

- **Verification-aware planning**: Encode pass-fail checks for each subtask so agents proceed or halt on facts
- **Input validation as core pattern**: Include validation, policy checks, and escalation paths as integral steps
- **Guardrails pattern**: Libraries like Guardrails AI apply input/output validators for policy, format, or PII
- **Layered validation**: Before execution (preflight), during execution (runtime checks), after execution (output validation)
- **Retry with escalation**: Use retries, circuit breakers, and escalation for low-confidence failures

**Current state in fyrsmithlabs:** Basic preflight hook checks git identity and warns on main branch. Missing: tool availability, token freshness, dependency status, Go version check.

**Recommendation:** Expand the preflight hook to a comprehensive validation skill that checks ALL prerequisites and auto-remediates where possible (e.g., `git config user.name "..."` if missing, `gh auth login` prompt if token expired).

**Sources:**
- [Agents At Work: The 2026 Playbook for Building Reliable Agentic Workflows](https://promptengineering.org/agents-at-work-the-2026-playbook-for-building-reliable-agentic-workflows/)
- [Multi-Agent Workflows Often Fail - GitHub Blog](https://github.blog/ai-and-ml/generative-ai/multi-agent-workflows-often-fail-heres-how-to-engineer-ones-that-dont/)

### 2. Session Recovery and Checkpointing

**Confidence: HIGH**

Checkpoint/restore is expanding as AI-centric applications grow:

- **Event-sourced state model**: Save running program state to persistent storage, resume from that point
- **Time travel**: Save, examine, and branch from prior execution states
- **Phase-based checkpointing**: Save state after each phase, restart from last successful checkpoint on failure
- **LangGraph pattern**: Built-in checkpointing with SqliteSaver -- state persists after every step
- **Governance features**: Human-in-the-loop checkpoints, autonomy boundaries, audit trails as first-class design

**Current state in fyrsmithlabs:** contextd has `/contextd:checkpoint` command for manual state saving. Missing: automatic checkpointing after phases, deterministic replay, resume-from-failure.

**Recommendation:** Add automatic checkpoint triggers in the contextd orchestration skill -- checkpoint after each successful phase completion, enabling resume from the last good state.

**Sources:**
- [Checkpoint/Restore Systems: Applications in AI Agents](https://eunomia.dev/blog/2025/05/11/checkpointrestore-systems-evolution-techniques-and-applications-in-ai-agents/)
- [Time Travel in Agentic AI](https://pub.towardsai.net/time-travel-in-agentic-ai-3063c20e5fe2)
- [Mastering LangGraph Checkpointing](https://sparkco.ai/blog/mastering-langgraph-checkpointing-best-practices-for-2025)

### 3. Progressive Disclosure

**Confidence: HIGH**

Progressive disclosure has evolved from traditional UI design into a critical architectural pattern for AI agents:

**Three-layer architecture:**
1. **Layer 1 (Index)**: Lightweight metadata -- titles, descriptions, token counts. Enough to route decisions
2. **Layer 2 (Details)**: Full content, loaded only when relevant to current task
3. **Layer 3 (Deep Dive)**: Supporting materials, examples, reference docs. Accessed only when needed

**Key principles:**
- Context is currency -- every token loaded competes for attention
- Keep to 2-3 layers to avoid complexity
- Progressive disclosure is about revealing information according to actual need, not providing less information
- Enables more efficient, scalable, and cheaper systems

**Applicable to fyrsmithlabs:** The research-synthesis agent currently dumps all findings into a single document. Recommendation: restructure output as Index (executive summary with links) -> Details (per-agent summaries) -> Deep Dive (full findings with citations). This is exactly what the current synthesis is doing, but the pattern should be formalized for consensus review outputs too.

**Sources:**
- [Progressive Disclosure Matters: Applying 90s UX Wisdom to 2026 AI Agents](https://aipositive.substack.com/p/progressive-disclosure-matters)
- [Progressive Disclosure in AI Agent Skill Design - Towards AI](https://pub.towardsai.net/progressive-disclosure-in-ai-agent-skill-design-b49309b4bc07)
- [The Coherence Cascade for AI](https://medium.com/@todd.dsm/why-progressive-disclosure-works-for-ai-agents-a-theory-of-motivated-retrieval-665a9d1ea23a)

### 4. Wrong-Approach Prevention

**Confidence: HIGH**

This is the #1 friction point (18 events). Research identifies key patterns:

**Root cause analysis of wrong-approach events:**
- Claude picks wrong branch (reviewing main instead of feature)
- Uses wrong tool (npm instead of standalone Tailwind)
- Creates wrong artifact type (one-shot files instead of skills)
- Codes before planning

**Industry patterns for prevention:**
- **Intent frameworks**: Systems should guide users to think through the shape of their requests -- direction, limitations, exceptions, success criteria, failure criteria, what must never happen
- **Constraint definition**: UX design moves from pixel decisions to defining constraints, guardrails, and intervention points
- **Transparency**: Users must understand not just what the system did, but WHY it did it
- **Override capability**: Users must be able to intervene, override, and correct at any point
- **Scope limitation**: Delegate fewer responsibilities, clearly define scope

**Applicable to fyrsmithlabs:** The complexity-assessment skill should gate intent confirmation:
- SIMPLE tasks (formatting, typos): auto-execute
- STANDARD tasks (feature implementation): confirm plan before executing
- COMPLEX tasks (architecture changes): confirm plan AND approach AND constraints before executing

The PreToolUse hook can enforce this by checking if a plan has been confirmed before allowing file writes on STANDARD/COMPLEX tasks.

**Sources:**
- [Designing for Autonomy: UX Principles for Agentic AI - UXmatters](https://www.uxmatters.com/mt/archives/2025/12/designing-for-autonomy-ux-principles-for-agentic-ai.php)
- [State of Design 2026: When Interfaces Become Agents](https://tejjj.medium.com/state-of-design-2026-when-interfaces-become-agents-fc967be10cba)

### 5. User Preference Learning

**Confidence: MEDIUM**

Feedback mechanisms for learning user preferences:

- **RLHF-lite for individual users**: Track which approaches the user accepts vs rejects, build implicit preference model
- **Explicit preference capture**: After session, prompt for satisfaction and specific feedback
- **Negative preference learning**: "Wrong approach" events are strong negative signals -- store these as anti-patterns
- **Project-context defaults**: Analyze codebase to infer preferences (Go = no npm, kebab-case = naming convention)
- **Cross-session memory**: Use persistent storage (contextd) to maintain preferences across sessions

**Current state in fyrsmithlabs:** contextd provides memory storage, but there is no automatic capture of preferences from user behavior. The user manually writes memories.

**Recommendation:** Add automatic negative-preference capture: when the user says "wrong approach" or redirects Claude, the system should automatically record what was attempted and what was correct, as a contextd memory for future reference.

---

## Recommendations for fyrsmithlabs

1. **Create `intent-confirmation` user skill** with complexity-gated confirmation (P0, addresses 18 wrong-approach events)
2. **Expand preflight validation** to comprehensive environment check with auto-remediation (P0, addresses 12 env errors)
3. **Add automatic checkpointing** to contextd orchestration after each phase (P1)
4. **Apply progressive disclosure** to consensus review and research synthesis outputs (P1)
5. **Add automatic negative-preference capture** when user redirects agent (P2)
6. **Create `smart-defaults` skill** that infers project preferences from codebase analysis (P2)
