---
name: brainstorm
description: Use when designing a feature, planning implementation, exploring approaches, or needing to think through a change before coding. Runs an interactive interview to understand requirements, assess complexity, explore alternatives, and create GitHub Issues. Say "let's brainstorm", "help me design", or "plan this feature".
arguments:
  - name: topic
    description: "Brief description of what to build (optional - will be asked if not provided)"
    required: false
  - name: reuse
    description: "Resume previous brainstorm session from checkpoint"
    required: false
---

# /brainstorm

Interactive design refinement using interview format with complexity-aware questioning.

## Execution

**Agent:** `contextd:contextd-task-executor`
**Context Folding:** Yes - isolate complexity assessment and approach exploration
**Output:**
- Interview artifacts in `.claude/brainstorms/<generated-title>/`
- GitHub Issues via github-planning skill

## Workflow

### Phase 1: Pre-Flight (Context Gathering)

```
1. mcp__contextd__memory_search(
     project_id: "<project>",
     query: "brainstorm design planning"
   )
   → Load past brainstorm outcomes and patterns

2. mcp__contextd__semantic_search(
     project_path: ".",
     query: "<topic or general codebase patterns>"
   )
   → Understand existing codebase context

3. Glob for existing specs/plans:
   - docs/**/*.md
   - .claude/brainstorms/**/*
   - **/*.spec.md

4. If --reuse flag:
   mcp__contextd__checkpoint_resume(
     checkpoint_id: "<previous-brainstorm>",
     level: "context"
   )
```

### Phase 2: Complexity Assessment (Context Folded)

```
mcp__contextd__branch_create(
  session_id: "<session>",
  description: "Assess task complexity",
  budget: 4096,
  timeout_seconds: 120
)
```

**Apply complexity-assessment skill:**

1. If topic not provided, ask:
```
AskUserQuestion(
  questions: [{
    question: "What would you like to build or change?",
    header: "Topic",
    options: [
      { label: "New feature", description: "Add new functionality to the codebase" },
      { label: "Enhancement", description: "Improve existing functionality" },
      { label: "Bug fix", description: "Fix incorrect behavior" },
      { label: "Refactoring", description: "Restructure without changing behavior" }
    ],
    multiSelect: false
  }]
)
```

2. Analyze 5 dimensions:
   - Scope (files to touch)
   - Integration (external dependencies)
   - Infrastructure (config/infra changes)
   - Knowledge (expertise required)
   - Risk (blast radius)

3. Calculate tier: SIMPLE (5-8), STANDARD (9-12), COMPLEX (13-15)

```
mcp__contextd__branch_return(
  branch_id: "<branch>",
  message: "Tier: <tier> (Score: <total>/15). Key factors: <top dimensions>"
)
```

### Phase 3: Initial Understanding (AskUserQuestion)

Question depth based on tier:
- **SIMPLE:** 3-5 questions
- **STANDARD:** 8-12 questions
- **COMPLEX:** 15+ questions

**Question Areas:**

1. **Purpose & Goals**
```
AskUserQuestion(
  questions: [{
    question: "What's the primary goal of this change?",
    header: "Goal",
    options: [
      { label: "User-facing feature", description: "End users will interact with this" },
      { label: "Developer experience", description: "Improves how developers work" },
      { label: "Performance", description: "Makes things faster or more efficient" },
      { label: "Technical debt", description: "Pays down accumulated shortcuts" }
    ],
    multiSelect: false
  }]
)
```

2. **Constraints & Requirements**
```
AskUserQuestion(
  questions: [{
    question: "What constraints should guide this design?",
    header: "Constraints",
    options: [
      { label: "Backwards compatible", description: "Must not break existing behavior" },
      { label: "Performance critical", description: "Speed/efficiency is paramount" },
      { label: "Security sensitive", description: "Handles sensitive data or operations" },
      { label: "Minimal changes", description: "Smallest possible diff preferred" }
    ],
    multiSelect: true
  }]
)
```

3. **Success Criteria**
```
AskUserQuestion(
  questions: [{
    question: "How will we know this is complete?",
    header: "Done Criteria",
    options: [
      { label: "Tests pass", description: "Automated tests verify behavior" },
      { label: "Manual QA", description: "Human verification required" },
      { label: "Metrics improve", description: "Observable improvement in metrics" },
      { label: "User feedback", description: "Users confirm it works for them" }
    ],
    multiSelect: true
  }]
)
```

Continue questioning until sufficient context gathered.

### Phase 4: Approach Exploration

Present 2-3 approaches with trade-offs:

```
AskUserQuestion(
  questions: [{
    question: "Which approach should we take?",
    header: "Approach",
    options: [
      { label: "<Approach A> (Recommended)", description: "<trade-offs and benefits>" },
      { label: "<Approach B>", description: "<trade-offs and benefits>" },
      { label: "<Approach C>", description: "<trade-offs and benefits>" }
    ],
    multiSelect: false
  }]
)
```

Lead with recommended option and explain reasoning.

### Phase 5: Design Presentation

Present design in 200-300 word sections:

1. **Architecture Overview**
2. **Component Breakdown**
3. **Data Flow**
4. **Error Handling**
5. **Testing Strategy**

After each section:
```
AskUserQuestion(
  questions: [{
    question: "Does this section look right?",
    header: "Validate",
    options: [
      { label: "Looks good", description: "Continue to next section" },
      { label: "Needs changes", description: "I have feedback on this section" },
      { label: "Wrong direction", description: "Let's reconsider the approach" }
    ],
    multiSelect: false
  }]
)
```

### Phase 6: Output Generation

**1. Write artifacts to `.claude/brainstorms/<title>/`:**
```
.claude/brainstorms/<topic>-<date>/
├── design.md           # Full design document
├── decisions.md        # Key decisions and rationale
└── notes.md           # Interview notes and context
```

**2. Create GitHub Issues (MANDATORY):**

Invoke github-planning skill based on tier. **Do NOT skip this step.**

```
# Pre-flight: Verify gh CLI is authenticated
gh auth status

# SIMPLE tier: Single issue with checklist
gh issue create \
  --title "<feature-name>" \
  --label "task" \
  --body "<design overview + task checklist + verification criteria>"

# STANDARD tier: Epic + sub-issues
gh issue create --title "[EPIC] <feature-name>" --label "epic" --body "..."
# Capture epic number, then create sub-issues with "Contributes to #<epic>"
gh issue create --title "<task-1>" --label "task" --body "... Contributes to #<epic>"
# Update epic body with sub-issue links

# COMPLEX tier: Epic + sub-issues + project board
# Same as STANDARD, plus:
gh project create --owner <owner> --title "<feature-name>"
gh project item-add <project-number> --owner <owner> --url <epic-url>
```

See `skills/github-planning/SKILL.md` for full templates and mandatory checklists.

**3. Offer implementation:**
```
AskUserQuestion(
  questions: [{
    question: "Design complete. GitHub Issues created. How would you like to proceed?",
    header: "Next Steps",
    options: [
      { label: "Create worktree", description: "Set up isolated workspace for implementation" },
      { label: "Review issues", description: "I'll review the GitHub Issues first" },
      { label: "Done for now", description: "Save progress and continue later" }
    ],
    multiSelect: false
  }]
)
```

### Phase 7: Memory Recording (Post-Flight)

```
mcp__contextd__memory_record(
  project_id: "<project>",
  title: "Brainstorm: <topic>",
  content: "Tier: <tier>. Approach: <selected approach>.
            Key decisions: <list>. GitHub: <issue URLs>.
            Outcome: <summary>.",
  outcome: "success",
  tags: ["brainstorm", "<tier>", "<topic-tag>"]
)

mcp__contextd__checkpoint_save(
  session_id: "<session>",
  project_path: ".",
  name: "brainstorm-<topic>-<date>",
  description: "Brainstorm session for <topic>",
  summary: "Tier: <tier>. Created <issue-count> GitHub issues.",
  context: "<key context for resume>",
  full_state: "<complete session state>",
  token_count: <estimate>,
  threshold: 0.0,
  auto_created: false
)
```

## Generated Title Logic

Title generated from:
1. Topic (sanitized to kebab-case)
2. Date stamp (YYYY-MM-DD)

Format: `<topic>-<YYYY-MM-DD>`
Example: `user-authentication-2026-01-12`

## Reuse Flag

When `--reuse` is passed:
1. Search for previous brainstorm checkpoints
2. Present list to user for selection
3. Load selected checkpoint context
4. Continue from where previous session ended

## Key Principles

- **One question at a time** - Don't overwhelm
- **Multiple choice preferred** - Easier to answer
- **YAGNI ruthlessly** - Remove unnecessary features
- **Explore alternatives** - 2-3 approaches before settling
- **Incremental validation** - Validate each design section
- **Be flexible** - Go back if something doesn't make sense

## Attribution

Adapted from Auto-Claude spec_gatherer and superpowers brainstorming concepts.
See CREDITS.md for full attribution.
