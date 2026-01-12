---
name: spec-refinement
description: Use when refining an existing specification document, drilling into technical details, exploring edge cases, or validating design decisions. Conducts deep-dive interview about implementation, UI/UX, concerns, and tradeoffs. Say "refine this spec", "drill into the details", or "let's validate this design".
arguments:
  - name: spec_file
    description: Path to the spec file to refine (required)
    required: true
---

# /spec-refinement

Conduct an in-depth interview about a specification file, refining it through non-obvious questions about technical implementation, UI/UX, concerns, and tradeoffs.

## Execution

**Agent:** `contextd:contextd-task-executor`
**Context Folding:** Yes - isolate interview context
**Output:** Refined spec written to original location; working drafts in `docs/.claude/specs/<spec-name>/`

## Workflow

### Phase 1: Context Loading (Pre-Flight)

```
1. mcp__contextd__memory_search(
     project_id: "<project>",
     query: "spec refinement patterns decisions"
   )
   → Load past refinement learnings

2. mcp__contextd__semantic_search(
     query: "related specs requirements",
     project_path: "."
   )
   → Find related context

3. Read the spec file: {{spec_file}}
   → Parse and understand current state

4. Create working directory:
   docs/.claude/specs/<spec-name>/
   → Store interview drafts and iterations
```

### Phase 2: Interview Loop

**Goal:** Ask non-obvious, in-depth questions until sufficient context is gathered.

**Question Categories:**
- Technical implementation details
- UI/UX considerations
- Edge cases and error handling
- Performance and scalability concerns
- Security implications
- Integration points
- Tradeoffs and alternatives
- User journey and workflows
- Data models and state management
- Testing and validation approaches

**Interview Rules:**
1. Use `AskUserQuestion` tool for EVERY question
2. Questions must be NON-OBVIOUS (not directly answerable from spec)
3. Probe deeper on vague or incomplete areas
4. Challenge assumptions respectfully
5. Offer the user option to:
   - Continue interview
   - End interview and generate refined spec
   - Skip current topic area
6. Adapt questions based on previous answers

**Question Format:**
```
AskUserQuestion(
  questions: [{
    question: "[Specific, non-obvious question]",
    header: "[Topic Area]",
    options: [
      { label: "[Option A]", description: "[What this means]" },
      { label: "[Option B]", description: "[Alternative approach]" },
      { label: "[Option C]", description: "[Different tradeoff]" },
      { label: "Skip this topic", description: "Move to next area" }
    ],
    multiSelect: false
  }]
)
```

**Completion Detection:**
Agent should offer to complete when:
- All major topic areas have been covered
- User has provided detailed answers to 8+ substantive questions
- Remaining gaps are minor/cosmetic
- User explicitly requests completion

Offer completion option:
```
AskUserQuestion(
  questions: [{
    question: "I believe we have sufficient context. How would you like to proceed?",
    header: "Interview Status",
    options: [
      { label: "Generate refined spec", description: "Write the refined specification now" },
      { label: "Continue - I have more to add", description: "Keep interviewing for more depth" },
      { label: "Review what we have", description: "Show summary before deciding" }
    ],
    multiSelect: false
  }]
)
```

### Phase 3: Draft Generation

```
1. Create context-folding branch:
   mcp__contextd__branch_create(
     session_id: "<session>",
     description: "Generate refined spec draft",
     budget: 8192
   )

2. Synthesize interview answers into coherent spec

3. Write draft to:
   docs/.claude/specs/<spec-name>/draft-<timestamp>.md

4. Return branch with summary:
   mcp__contextd__branch_return(
     branch_id: "<branch>",
     message: "Draft generated: [key improvements]"
   )
```

### Phase 4: Final Output

```
1. Present summary of changes to user

2. Write refined spec to original location:
   {{spec_file}}

3. Record decisions in contextd:
   mcp__contextd__memory_record(
     project_id: "<project>",
     title: "Spec refinement: <spec-name>",
     content: "Key decisions: [list]. Tradeoffs: [list].
              Open questions: [list].",
     outcome: "success",
     tags: ["spec-refinement", "decisions", "<spec-name>"]
   )
```

## Working Directory Structure

```
docs/.claude/specs/<spec-name>/
├── draft-001.md          # First iteration
├── draft-002.md          # Second iteration
├── interview-notes.md    # Raw interview context
└── decisions.md          # Key decisions captured
```

## Example Questions (Non-Obvious)

**Technical:**
- "If this system needs to handle 10x current load, which component becomes the bottleneck first?"
- "What happens to in-flight requests if component X crashes mid-operation?"

**UX:**
- "When a user makes this mistake (common in similar systems), how should the system guide them back?"
- "What's the learning curve for a power user vs. a casual user?"

**Tradeoffs:**
- "Would you sacrifice feature X for a 50% reduction in complexity?"
- "If you had to ship in half the time, what would you cut?"

**Edge Cases:**
- "What happens when [unlikely but possible scenario]?"
- "How should the system behave with malformed/adversarial input?"

## Integration with contextd

- Decisions recorded as memories for future reference
- Related past decisions surfaced during interview
- Working drafts preserved in `docs/.claude/specs/`
- Final spec replaces original file
