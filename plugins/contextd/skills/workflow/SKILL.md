---
name: workflow
description: Use for session lifecycle management - covers session start/end protocols, checkpoint workflow, and error remediation flow
---

# contextd Workflow

## Session Start Protocol

**Step 1: Search for relevant memories**
```json
{
  "project_id": "contextd",
  "query": "current task context",
  "limit": 5
}
```

**Step 2: Check for checkpoints**
```json
{
  "tenant_id": "fyrsmithlabs",
  "project_path": "/path/to/project",
  "limit": 5
}
```

**Step 3: If checkpoint found**
- Ask user: "Found previous work: '[summary]'. Resume?"
- If yes: `checkpoint_resume(checkpoint_id, tenant_id, level)`
- Levels: `summary` (minimal), `context` (balanced), `full` (complete)

## Checkpoint Workflow

**When to checkpoint:**
- Context >= 70% capacity
- End of work session
- Before risky operations
- Switching tasks

### checkpoint_save

```json
{
  "session_id": "session_abc123",
  "tenant_id": "fyrsmithlabs",
  "project_path": "/path/to/project",
  "name": "Feature implementation checkpoint",
  "summary": "Completed: spec, 2 of 4 skills. Next: remaining skills.",
  "context": "Working on plugin consolidation...",
  "full_state": "Complete conversation state...",
  "token_count": 45000,
  "threshold": 0.7,
  "auto_created": false
}
```

**Summary must include:**
- What was accomplished
- What's in progress
- What's next
- Key decisions made

### Resume Levels

| Level | Tokens | Content |
|-------|--------|---------|
| `summary` | ~100-200 | Name + summary only |
| `context` | ~500-1000 | Summary + context + decisions |
| `full` | Complete | Entire conversation history |

## Error Remediation Flow

**When encountering ANY error:**

```
1. DIAGNOSE the error
   troubleshoot_diagnose(error_message, error_context)

2. SEARCH for past fixes
   remediation_search(query, tenant_id)

3. APPLY fix (use diagnosis + history)

4. RECORD the solution
   remediation_record(title, problem, root_cause, solution, category)
```

### troubleshoot_diagnose

```json
{
  "error_message": "cannot use vectorStore as vectorstore.Store value",
  "error_context": "Running go test after adding new interface method"
}
```

Returns: `root_cause`, `hypotheses`, `recommendations`, `confidence`

### remediation_record

```json
{
  "title": "Mock missing interface method after interface change",
  "problem": "Test fails with 'missing method X'",
  "symptoms": ["go test fails", "cannot use X as Y value"],
  "root_cause": "Mock implementations don't get new interface methods",
  "solution": "Add new method to all mock implementations",
  "category": "syntax",
  "tenant_id": "fyrsmithlabs",
  "scope": "org"
}
```

**Categories:** `syntax`, `runtime`, `logic`, `config`, `dependency`, `network`, `auth`, `data`, `performance`

**Scopes:** `project` (this project), `team` (team members), `org` (entire organization)

## Session End Protocol

**Before `/clear` or ending work:**

1. **Re-index repository**
   ```json
   { "path": "." }
   ```
   Captures code changes and updates branch metadata.

2. **Record learnings**
   ```json
   {
     "project_id": "contextd",
     "title": "Implemented session lifecycle hooks",
     "content": "Used TDD with Registry pattern...",
     "outcome": "success",
     "tags": ["hooks", "lifecycle", "tdd"]
   }
   ```

3. **Checkpoint if resuming later**
   ```json
   { "auto_created": true, "threshold": 0.7, ... }
   ```

## Git Commit Re-index

**After every `git commit`:**
```json
{ "path": "." }
```

Why: Captures changes for semantic search, updates branch metadata.

## Quick Reference

| When | Action |
|------|--------|
| Session start | `memory_search` + `checkpoint_list` |
| After git commit | `repository_index` |
| Context >= 70% | `checkpoint_save` then `/clear` |
| Error encountered | `troubleshoot_diagnose` -> `remediation_search` -> fix -> `remediation_record` |
| Before `/clear` | `memory_record` + `checkpoint_save` |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skipping memory search at start | Always search first |
| Vague checkpoint summaries | Include completed/in-progress/next |
| Waiting until context overflow | Save at 70%, not 95% |
| Not recording before `/clear` | Call `memory_record` first |
| Skipping error diagnosis | `troubleshoot_diagnose` first, always |

---

## Checkpoint Compression (Deltas)

### Delta-Based Storage

Instead of storing full state each time, checkpoints can store deltas:

```json
{
  "checkpoint_id": "cp_002",
  "parent_id": "cp_001",
  "storage_mode": "delta",
  "delta": {
    "added_memories": ["mem_123", "mem_124"],
    "completed_tasks": ["#42", "#43"],
    "new_decisions": ["Use Registry pattern for DI"],
    "files_changed": ["api/handler.go", "internal/store.go"]
  },
  "delta_size_tokens": 150,
  "full_size_tokens": 2500
}
```

### Compression Modes

| Mode | Storage | Restore Speed | Use Case |
|------|---------|---------------|----------|
| `full` | Complete state | Instant | Short sessions, critical points |
| `delta` | Changes only | Requires chain | Long sessions, frequent saves |
| `hybrid` | Full every 5th | Balanced | Default recommendation |

### Checkpoint Chain

```
cp_001 (full) -> cp_002 (delta) -> cp_003 (delta) -> cp_004 (delta) -> cp_005 (full)
                                                                        ^
                                                              Auto-consolidate at 5
```

Resume from delta:
```
checkpoint_resume(checkpoint_id: "cp_003")
  -> Loads cp_001 (full base)
  -> Applies cp_002 delta
  -> Applies cp_003 delta
  -> Returns reconstructed state
```

---

## Checkpoint Branching

### Parallel Work Streams

Create checkpoint branches for exploration:

```json
{
  "checkpoint_id": "cp_main_005",
  "branch": "experiment/new-arch",
  "parent_checkpoint": "cp_main_003",
  "description": "Exploring event-sourcing architecture"
}
```

### Branch Operations

| Operation | Purpose |
|-----------|---------|
| `checkpoint_branch(parent_id, branch_name)` | Create exploration branch |
| `checkpoint_merge(branch_id, target_id)` | Merge learnings back |
| `checkpoint_abandon(branch_id)` | Discard failed experiment |

### Visualizing Branches

```
cp_main_001 -> cp_main_002 -> cp_main_003 -> cp_main_004 -> cp_main_005
                                    \
                                     -> cp_exp_001 -> cp_exp_002 (merged at cp_main_005)
```

---

## Auto-Error Capture via Hooks

### PostToolUse Hook for Error Detection

Automatically capture errors when tools fail:

```json
{
  "hook_type": "PostToolUse",
  "matcher": "Bash|Task",
  "condition": "tool_output.exit_code != 0 OR tool_output.contains('error')",
  "prompt": "An error occurred. Automatically:\n1. Call troubleshoot_diagnose with the error\n2. Search remediation_search for past fixes\n3. If novel error, prepare remediation_record after fix"
}
```

### PreToolUse Hook for Dangerous Operations

Checkpoint before risky operations:

```json
{
  "hook_type": "PreToolUse",
  "matcher": "Bash",
  "condition": "command.matches('rm|drop|delete|truncate|reset --hard')",
  "prompt": "Risky operation detected. Auto-checkpoint before proceeding:\ncheckpoint_save(name: 'pre-risky-op', auto_created: true)"
}
```

### Stop Hook for Session End

Auto-capture learnings when session ends:

```json
{
  "hook_type": "Stop",
  "prompt": "Session ending. Before final response:\n1. Record any unrecorded learnings with memory_record\n2. Save checkpoint if work is in progress\n3. Re-index repository if files changed"
}
```

---

## Unified Memory Type References

All workflow operations should tag with standard types:

| Type | Tag | Purpose |
|------|-----|---------|
| Learning | `type:learning` | Knowledge gained |
| Remediation | `type:remediation` | Error -> fix |
| Decision | `type:decision` | Architecture choice |
| Failure | `type:failure` | What NOT to do |
| Pattern | `type:pattern` | Reusable code |
| Policy | `type:policy` | STRICT constraint |

Example with type:
```json
{
  "title": "Session lifecycle implementation",
  "tags": ["type:learning", "category:workflow", "component:hooks"]
}
```

---

## Hierarchical Namespace Guidance

### Checkpoint Namespaces

Structure checkpoint names for multi-project work:

```
<org>/<project>/<branch>/<checkpoint>

Examples:
  fyrsmithlabs/contextd/main/feature-complete
  fyrsmithlabs/contextd/experiment/event-sourcing
  fyrsmithlabs/marketplace/main/v1.5-release
```

### Cross-Project Checkpoints

Link related checkpoints across projects:

```json
{
  "checkpoint_id": "cp_contextd_005",
  "related_checkpoints": [
    "fyrsmithlabs/marketplace/main/contextd-integration"
  ],
  "cross_project_context": "Marketplace integration depends on contextd v1.2.0"
}
```

---

## Audit Fields

All workflow operations record:

| Field | Description | Auto-set |
|-------|-------------|----------|
| `created_by` | Agent/session ID | Yes |
| `created_at` | ISO timestamp | Yes |
| `updated_at` | Last modification | Yes |
| `usage_count` | Times checkpoint resumed | Yes |
| `last_resumed_at` | Last resume timestamp | Yes |

---

## Claude Code 2.1 Patterns

### Background Checkpoint Save

Save checkpoints without blocking:

```
Task(
  subagent_type: "general-purpose",
  prompt: "Save checkpoint with current state summary",
  run_in_background: true,
  description: "Background checkpoint save"
)

// Continue work immediately
```

### Task Dependencies for Workflow

Chain workflow operations:

```
diagnose_task = Task(prompt: "Diagnose error: {{error}}")
search_task = Task(prompt: "Search remediations", addBlockedBy: [diagnose_task.id])
fix_task = Task(prompt: "Apply fix", addBlockedBy: [search_task.id])
record_task = Task(prompt: "Record remediation", addBlockedBy: [fix_task.id])
```

### PostToolUse Hook Example

Auto-checkpoint after successful operations:

```json
{
  "hook_type": "PostToolUse",
  "tool_name": "Bash",
  "condition": "command.contains('git commit') AND exit_code == 0",
  "prompt": "Commit successful. Auto-checkpoint and re-index repository."
}
```

---

## Event-Driven State Sharing

Workflow emits events for other skills:

```json
{
  "event": "checkpoint_saved",
  "payload": {
    "checkpoint_id": "cp_005",
    "project_id": "fyrsmithlabs/contextd",
    "summary": "Feature complete",
    "token_count": 45000
  },
  "notify": ["orchestration", "self-reflection"]
}
```

Subscribe to workflow events:
- `session_started` - New session began
- `checkpoint_saved` - State preserved
- `checkpoint_resumed` - Previous state loaded
- `error_captured` - Auto-captured error
- `remediation_applied` - Fix successfully applied
