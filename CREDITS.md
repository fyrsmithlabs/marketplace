# Credits

## Auto-Claude Adaptation

Core planning and discovery concepts in this marketplace are adapted from
**Auto-Claude** by [AndyMik90](https://github.com/AndyMik90/Auto-Claude).

**License:** MIT

### Adapted Concepts

| Concept | Source | Adaptation |
|---------|--------|------------|
| Complexity Assessment | `complexity_assessor.md` | `skills/complexity-assessment` |
| 5 Dimensions Model | `complexity_assessor.md` | Scope, Integration, Infrastructure, Knowledge, Risk |
| Spec Gathering | `spec_gatherer.md` | Enhanced `/brainstorm` interview phases |
| Ideation Agents | `ideation_*.md` | Lens-based analyzers in `roadmap-discovery` |
| Severity Framework | `ideation_*.md` | CRITICAL/MAJOR/MINOR/SUGGESTION |
| Roadmap Discovery | `roadmap_discovery.md` | `skills/roadmap-discovery` |
| Verification Criteria | `planner.md`, `qa_reviewer.md` | Auto-generated verification per task type |

### Key Differences from Auto-Claude

| Aspect | Auto-Claude | fyrsmithlabs |
|--------|-------------|--------------|
| Output | Local JSON/markdown files | GitHub Issues/Projects via gh CLI |
| Storage | File-based state | contextd memory + checkpoints |
| Workflow | Direct branch commits | Worktree isolation + PR flow |
| Review | Single QA agent | 5-agent consensus with veto power |
| Recovery | attempt_history.json | contextd remediation_search |

### Repository

- **Source:** https://github.com/AndyMik90/Auto-Claude
- **Branch:** develop
- **Path:** `apps/backend/prompts/`

---

*This attribution follows fyrsmithlabs standards for crediting adapted work.*
