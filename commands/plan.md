---
name: plan
description: Use when starting a new feature or task from scratch. Orchestrates the full workflow - assesses complexity, runs brainstorming interview, creates GitHub Issues, and offers worktree setup. The complete planning pipeline. Say "plan this feature", "start planning", or "I want to build X".
arguments:
  - name: topic
    description: "Brief description of what to build"
    required: true
  - name: skip-brainstorm
    description: "Skip interactive brainstorming (use for spec-driven work)"
    required: false
  - name: discover-first
    description: "Run discovery before planning to gather context"
    required: false
---

# /plan

Unified planning command that orchestrates the full workflow from idea to implementation-ready state.

## Execution

**Agent:** Task tool or direct execution
**Context Folding:** If contextd available
**Output:** GitHub Issues + worktree (optional)

## Contextd Integration (Optional)

If contextd MCP is available:
- `memory_search` for past plans
- `branch_create/return` for isolated phases
- `memory_record` for plan outcomes

If contextd is NOT available:
- Skip memory search (fresh context)
- Run phases inline without isolation
- Still creates GitHub Issues and worktrees

## Usage

```bash
# Full planning workflow
/plan "add user authentication"

# Skip brainstorming (already have spec)
/plan "implement auth per spec" --skip-brainstorm

# Run discovery first for context
/plan "improve performance" --discover-first
```

## Workflow

### Phase 1: Pre-Flight

```
1. Check contextd availability (look for mcp__contextd__* tools)

2. If contextd_available:
   mcp__contextd__memory_search(
     project_id: "<project>",
     query: "planning <topic>"
   )
   → Load relevant past plans

3. If --discover-first (MANDATORY when flag present):
   a. Run discovery analysis:
      mcp__contextd__branch_create(
        session_id: "<session>",
        description: "Pre-planning discovery",
        budget: 8192
      )

   b. Execute roadmap-discovery skill with all lenses:
      - security, quality, perf, docs
      - Auto-index repository if needed
      - Cap findings per skill requirements

   c. Return discovery summary:
      mcp__contextd__branch_return(
        branch_id: "<branch>",
        message: "Discovery: <total> findings. CRITICAL: <n>, MAJOR: <n>"
      )

   d. Present findings and ask confirmation:
      AskUserQuestion(
        questions: [{
          question: "Discovery found <n> issues. Proceed with planning?",
          header: "Confirm",
          options: [
            { label: "Continue planning", description: "Use findings to inform design" },
            { label: "Address critical first", description: "Fix CRITICAL findings before planning" },
            { label: "View details", description: "Show full discovery report" }
          ],
          multiSelect: false
        }]
      )

   e. Record discovery in contextd:
      mcp__contextd__memory_record(
        project_id: "<project>",
        title: "Pre-plan discovery: <topic>",
        content: "Found <total> issues before planning. Key: <top 3>",
        outcome: "success",
        tags: ["discovery", "pre-plan", "<topic>"]
      )

   f. DO NOT skip steps a-e when flag is present

3. Validate topic provided or prompt for it
```

### Phase 2: Complexity Assessment

```
mcp__contextd__branch_create(
  session_id: "<session>",
  description: "Assess complexity for: <topic>",
  budget: 4096
)
```

Apply complexity-assessment skill:
1. Analyze 5 dimensions
2. Calculate tier (SIMPLE/STANDARD/COMPLEX)
3. Record in contextd

```
mcp__contextd__branch_return(
  branch_id: "<branch>",
  message: "Tier: <tier> (Score: <n>/15)"
)
```

### Phase 3: Branching by Tier

**If SIMPLE (5-8):**
```
Quick planning flow:
1. Ask 3-5 clarifying questions
2. Propose single approach
3. Create single GitHub Issue with checklist
4. Done - no worktree needed
```

**If STANDARD (9-12):**
```
Standard planning flow:
1. Run full /brainstorm workflow (if not --skip-brainstorm)
2. Create Epic + sub-Issues
3. Offer worktree creation
```

**If COMPLEX (13-15):**
```
Extended planning flow:
1. Run full /brainstorm workflow with extended questions
2. Create Epic + sub-Issues + Project board
3. Worktree creation recommended
4. Consider breaking into phases
```

### Phase 4: Skip Brainstorm Path

If `--skip-brainstorm`:

```
AskUserQuestion(
  questions: [{
    question: "Skipping brainstorm. What's your existing spec source?",
    header: "Spec Source",
    options: [
      { label: "Existing doc", description: "Point me to a spec file in the repo" },
      { label: "GitHub Issue", description: "There's already a detailed issue" },
      { label: "Verbal description", description: "I'll describe it now" },
      { label: "External doc", description: "Spec is in external system (Notion, etc.)" }
    ],
    multiSelect: false
  }]
)
```

Then:
1. Read/gather spec from source
2. Extract tasks from spec
3. Generate verification criteria
4. Create GitHub Issues
5. Offer worktree

### Phase 5: Worktree Decision

```
AskUserQuestion(
  questions: [{
    question: "Planning complete. Ready to start implementation?",
    header: "Implementation",
    options: [
      { label: "Create worktree (Recommended)", description: "Isolated workspace for this work" },
      { label: "Work in current branch", description: "No isolation needed for this change" },
      { label: "Later", description: "I'll review the plan first" }
    ],
    multiSelect: false
  }]
)
```

**If worktree selected:**

Use git worktree:
```bash
# Create branch
git branch <feature-branch> main

# Create worktree
git worktree add ../<project>-<feature> <feature-branch>

# Output path to user
echo "Worktree created at: ../<project>-<feature>"
echo "Switch with: cd ../<project>-<feature>"
```

### Phase 6: Memory Recording

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Plan: <topic>",
  content: "Tier: <tier>. Brainstormed: <yes/no>.
            Issues: <count>. Worktree: <path or 'none'>.
            Ready for implementation.",
  outcome: "success",
  tags: ["plan", "<tier>", "<topic-tag>"]
)

mcp__contextd__checkpoint_save(
  session_id: "<session>",
  project_path: ".",
  name: "plan-<topic>-<date>",
  description: "Planning complete for <topic>",
  summary: "Tier: <tier>. Issues: <urls>. Worktree: <path>",
  context: "<key decisions>",
  full_state: "<complete state>",
  token_count: <estimate>,
  threshold: 0.0,
  auto_created: false
)
```

## Output Summary

At completion, display:

```
┌─────────────────────────────────────────────────────────────┐
│ Planning Complete                                            │
└─────────────────────────────────────────────────────────────┘

Topic: <topic>
Complexity: <tier> (<score>/15)

GitHub Issues:
  Epic: #42 - [EPIC] <title>
  Tasks:
    - #43: <task 1>
    - #44: <task 2>
    - #45: <task 3>

Worktree: ../<project>-<feature>

Next Steps:
  1. cd ../<project>-<feature>
  2. Review issues: gh issue view 42
  3. Start implementation
```

## Tier Quick Reference

| Tier | Questions | GitHub Output | Worktree |
|------|-----------|---------------|----------|
| SIMPLE | 3-5 | Single Issue | Optional |
| STANDARD | 8-12 | Epic + sub-Issues | Recommended |
| COMPLEX | 15+ | Epic + sub-Issues + Project | Required |

## Attribution

Orchestrates complexity-assessment, github-planning, and brainstorming.
See CREDITS.md for full attribution.
