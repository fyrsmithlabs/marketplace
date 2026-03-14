# Technical Research: Multi-Agent Orchestration Patterns

**Agent:** research-technical
**Date:** 2026-03-05
**Confidence:** HIGH
**Sources:** 25+ web searches across academic papers, vendor documentation, and practitioner guides

---

## Focus Areas Investigated

1. Parallel agent dispatch patterns
2. Budget/token management and graceful degradation
3. Consensus mechanisms beyond majority vote
4. Partial results handling at context limits
5. Agent specialization vs. generalist review

---

## Key Findings

### 1. Parallel Agent Dispatch Patterns

**Confidence: HIGH**

The dominant pattern for 2025-2026 is **orchestrator + specialized workers with isolated contexts**:

- Multiple agents working simultaneously on independent parts dramatically reduces completion time vs sequential processing
- Git worktrees are the standard isolation mechanism -- each agent gets its own working directory linked to the same repository
- The Writer/Reviewer pattern (one agent writes, another reviews) and Plan/Execute separation (powerful model plans, faster model executes) are well-established
- OpenAI Codex (Feb 2026) centralized multi-agent coordination as a "command center for agents"
- Google ADK provides formal parallel agent workflow primitives

**Applicable to fyrsmithlabs:** The existing Task tool dispatch in research-orchestrator already follows this pattern. Enhancement opportunity: formalize worktree isolation for dev agents (not just review agents).

**Sources:**
- [AI Coding Agents in 2026: Coherence Through Orchestration](https://mikemason.ca/writing/ai-coding-agents-jan-2026/)
- [AI Agent Orchestration Patterns - Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns)
- [Developer's Guide to Multi-Agent Patterns in ADK](https://developers.googleblog.com/developers-guide-to-multi-agent-patterns-in-adk/)
- [Multi-Agent Systems & AI Orchestration Guide 2026](https://www.codebridge.tech/articles/mastering-multi-agent-orchestration-coordination-is-the-new-scale-frontier)

### 2. Budget/Token Management

**Confidence: HIGH**

Key findings on managing agent budgets:

- **BudgetThinker** framework: periodically inserts control tokens during inference to inform the model of remaining token budget, enabling precise control over thought process length
- **Token-Budget-Aware Reasoning**: dynamically adjusts reasoning tokens based on problem complexity -- simple problems get fewer tokens, complex ones get more
- **Context rot**: systematic degradation of model recall as input tokens accumulate past 100K+ tokens, making agents less reliable in long conversations
- **Graceful degradation strategies**: fallback to simplified responses, cached alternatives, multi-provider load distribution

**Applicable to fyrsmithlabs:** The current fixed 8192 budget per reviewer is suboptimal. Recommendation: adaptive budgets where small PRs (<50 lines) get 4096, medium PRs get 8192, and large PRs (>500 lines) get 12288. The existing progressive summarization protocol (0-80% full, 80-95% high-severity-only, 95%+ force-return) is already well-designed.

**Sources:**
- [Token-Budget-Aware LLM Reasoning - ACL 2025](https://aclanthology.org/2025.findings-acl.1274/)
- [BudgetThinker: Empowering Budget-aware LLM Reasoning](https://openreview.net/forum?id=ahatk5qrmB)
- [LLM Token Optimization - Redis](https://redis.io/blog/llm-token-optimization-speed-up-apps/)

### 3. Consensus Mechanisms

**Confidence: HIGH**

Research from ACL 2025 systematically evaluates 7 decision protocols beyond simple majority:

| Protocol | Best For | Performance Gain |
|----------|----------|-----------------|
| Majority Vote | Reasoning tasks | +13.2% over baseline |
| Supermajority (66%) | Mixed tasks | Moderate improvement |
| Unanimity | Knowledge/fact tasks | +2.8% over baseline |
| All-Agents Drafting (AAD) | Complex tasks | +3.3% improvement |
| Collective Improvement (CI) | Iterative refinement | +7.4% improvement |
| Dynamic Routing | Large agent pools | Skips redundant agents |
| Debate-Based Consensus | Controversial decisions | Iterative convergence |

**Key insight:** Voting protocols excel at reasoning tasks while consensus protocols excel at knowledge-based tasks. The current fyrsmithlabs system uses a single 70% threshold -- it should gate protocol selection by task type.

**Applicable to fyrsmithlabs:** Code reviews (reasoning-heavy) should use majority vote. Documentation reviews (knowledge-heavy) should use consensus. Security reviews should retain unanimity with veto power.

**Sources:**
- [Voting or Consensus? Decision-Making in Multi-Agent Debate - ACL 2025](https://aclanthology.org/2025.findings-acl.606/)
- [arxiv: Voting or Consensus?](https://arxiv.org/abs/2502.19130)
- [Multi-Agent Collaboration Mechanisms: A Survey](https://arxiv.org/html/2501.06322v1)

### 4. Partial Results Handling

**Confidence: MEDIUM**

Approaches for handling context window limits in parallel agents:

- **Self-Manager pattern**: spawns subthreads asynchronously with contexts isolated between threads, each returning results to the main thread's most recent observation
- **Summary-based compression**: replace conversational histories with structured context representations that explicitly preserve key information
- **Context folding at subtask granularity**: already implemented in fyrsmithlabs as the context-folding skill
- **Extended context windows**: Claude 4 Sonnet offers 200K standard, 1M beta -- but larger windows still suffer from context rot

**Applicable to fyrsmithlabs:** The existing progressive summarization protocol handles this well. Enhancement: add automatic summarization triggers when agent output exceeds a configurable threshold (e.g., 50K tokens -> auto-summarize to 10K).

**Sources:**
- [Self-Manager: Parallel Agent Loop for Long-form Deep Research](https://arxiv.org/html/2601.17879v1)
- [Claude AI Context Window and Memory](https://www.datastudios.org/post/claude-ai-context-window-token-limits-and-memory-how-large-context-reasoning-actually-works-for-l)
- [Parallel Agents - Google ADK](https://google.github.io/adk-docs/agents/workflow-agents/parallel-agents/)

### 5. Agent Specialization vs. Generalist

**Confidence: HIGH**

Strong consensus across sources that **specialization outperforms generalist** agents:

- Specialist agents with focused system prompts produce higher-quality, more consistent results
- The diminishing returns threshold appears at 8-10 specialized agents per review (beyond that, overhead exceeds benefit)
- Dynamic routing can skip agents whose expertise is not relevant to the current diff
- The Planner/Worker/Judge pattern (from Cursor 2.0 research) separates planning, execution, and quality assessment roles

**Applicable to fyrsmithlabs:** The current 6 reviewer agents + 7 research agents is well within the effective range. Consider adding dynamic routing to skip irrelevant reviewers (e.g., skip go-reviewer for markdown-only changes).

---

## Recommendations for fyrsmithlabs

1. **Implement adaptive budgets** in consensus-review skill based on diff complexity
2. **Add task-type-gated consensus protocols** -- voting for code, consensus for docs, unanimity+veto for security
3. **Add dynamic reviewer routing** to skip irrelevant agents based on file types in the diff
4. **Formalize worktree management** as a skill for parallel dev agent dispatch
5. **Add automatic summarization triggers** when agent outputs exceed context thresholds
