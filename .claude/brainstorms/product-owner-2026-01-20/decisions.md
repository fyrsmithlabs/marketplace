# Product Owner Agent - Key Decisions

**Date**: 2026-01-20

---

## Decision 1: Single Agent Role

**Context**: Should we have separate PO, PM, and Scrum Master agents?

**Options Considered**:
1. Single product-owner
2. PO + PM split
3. PO + Scrum Master split
4. Unified product-lead

**Decision**: Single `product-owner` agent

**Rationale**: KISS principle. PM functions already exist in `/app-interview`, `/comp-analysis`, `/spec-refinement`. No need to duplicate.

---

## Decision 2: Output Destination

**Context**: How to get standup outside terminal?

**Options Considered**:
1. Markdown file
2. GitHub Discussion/Issue
3. Clipboard
4. Webhook POST

**Decision**: GitHub Discussion (daily thread)

**Rationale**:
- Already integrated via GitHub MCP
- Provides visibility to team
- Creates audit trail
- No new infrastructure needed

---

## Decision 3: Queue Storage

**Context**: Where should work queue state live?

**Options Considered**:
1. GitHub Issues (labels)
2. contextd memories
3. Local file
4. Hybrid: GitHub + contextd

**Decision**: Hybrid (Phase 3)

**Rationale**: GitHub for visibility, contextd for agent state. But deferred - Phase 1 is recommendation-only.

---

## Decision 4: Phase 1 Scope

**Context**: What to include in Phase 1?

**Decision**: Single repo, terminal + Discussion output only

**Deferred**:
- Cross-project `--platform` (Phase 2)
- Slack integration (Phase 2)
- Autonomous agent queue (Phase 3)
- Supervision loop (Phase 3)

**Rationale**: YAGNI - build simplest useful thing first, expand based on actual needs.

---

## Decision 5: Agent Decision Making (Future)

**Context**: How should agents decide what to work on?

**Decision**: (Phase 3) Context-aware selection + PO-directed assignment + user override

**Approval Triggers**:
- Risk-based threshold
- Confidence-based
- First-time actions
- contextd memory checks

**Rationale**: Deferred to Phase 3. Requires more infrastructure (queue, supervision).

---

## Anti-Decisions (What We're NOT Doing)

| Rejected | Reason |
|----------|--------|
| Slack MCP integration now | Over-engineering for Phase 1 |
| Full bidirectional Slack | Requires decision loop infrastructure |
| Agent autonomy | Humans decide, agents recommend (Phase 1) |
| Multiple agent roles | Single PO is sufficient |
| Sprint/ceremony model | Continuous flow preferred |
