---
name: orchestrate
description: Execute a multi-task orchestration plan with parallel agents, consensus reviews, and automatic remediation using contextd for memory, checkpoints, and context folding. Use for complex multi-feature development phases. Say "orchestrate this plan", "execute phase 2", or "run the orchestration".
arguments:
  - name: plan-file
    description: "Path to orchestration plan file (markdown with task definitions)"
    required: false
  - name: groups
    description: "Comma-separated list of group numbers to execute (e.g., '2,3,4')"
    required: false
  - name: review-threshold
    description: "Consensus review pass threshold: 'strict' (100%), 'standard' (no vetoes), 'advisory' (report only)"
    required: false
  - name: resume
    description: "Resume from checkpoint name (e.g., 'group-2-complete')"
    required: false
---

# /orchestrate

Execute a multi-task orchestration plan with parallel agents, dependency management, consensus reviews, and automatic remediation. Uses contextd for cross-session memory, checkpoints, and context folding.

## Execution

**Agent:** `fyrsmithlabs:contextd-orchestrator`
**Context Folding:** Yes - each task group runs in isolated context branch
**Memory:** Records learnings, decisions, and remediations to contextd
**Checkpoints:** Saved after each group for resume capability
**Output:** Completed tasks, merged code, review reports

## Usage

```bash
# Execute orchestration from plan file
/orchestrate PHASE2-ORCHESTRATION-PLAN.md

# Execute specific groups only
/orchestrate --groups "3,4,5"

# Execute with strict review (100% findings addressed)
/orchestrate --review-threshold strict

# Resume from checkpoint after interruption
/orchestrate --resume "group-2-complete"
```

## Contextd Integration

### Memory Tools Used
- `mcp__contextd__memory_search` - Find relevant past orchestrations
- `mcp__contextd__memory_record` - Record learnings and decisions
- `mcp__contextd__memory_consolidate` - Consolidate similar learnings

### Checkpoint Tools Used
- `mcp__contextd__checkpoint_save` - Save state after each group
- `mcp__contextd__checkpoint_resume` - Resume from saved state
- `mcp__contextd__checkpoint_list` - List available checkpoints

### Context Folding Tools Used
- `mcp__contextd__branch_create` - Isolate complex sub-tasks
- `mcp__contextd__branch_return` - Return with compressed summary
- `mcp__contextd__branch_status` - Check branch token usage

### Remediation Tools Used
- `mcp__contextd__remediation_record` - Record bug fixes and patterns
- `mcp__contextd__remediation_search` - Find past similar fixes

## Workflow

### Phase 0: Initialization (Contextd Setup)

```
1. MANDATORY: Read engineering practices before any work:
   Read("CLAUDE.md")
   Read("engineering-practices.md") OR Read("docs/engineering-practices.md")
   → Load project-specific guidelines, security requirements, and coding standards
   → These practices MUST be followed throughout the orchestration
   → If engineering-practices.md not found, check for:
     - docs/CONTRIBUTING.md
     - .github/CONTRIBUTING.md
     - README.md (development section)

2. Search for relevant past orchestrations:
   mcp__contextd__memory_search(
     project_id: "<repo>",
     query: "orchestration <plan_name>",
     limit: 5
   )
   → Load learnings from previous runs

3. Check for existing checkpoints if resuming:
   if --resume:
     mcp__contextd__checkpoint_list(
       session_id: "orchestrate-<plan>",
       project_path: "."
     )
     → Find matching checkpoint

     mcp__contextd__checkpoint_resume(
       checkpoint_id: "<checkpoint>",
       session_id: "orchestrate-<plan>"
     )
     → Restore state, skip completed groups

4. Create orchestration context branch:
   mcp__contextd__branch_create(
     session_id: "<session>",
     description: "Orchestration: <plan_name>",
     budget: 16384
   )
   → Isolate orchestration context

5. Save initial checkpoint:
   mcp__contextd__checkpoint_save(
     session_id: "orchestrate-<plan>",
     project_path: ".",
     name: "orchestrate-start",
     description: "Starting orchestration: <plan_name>",
     summary: "{n} tasks in {g} groups planned",
     auto_created: false
   )
```

### Phase 1: Plan Discovery

```
1. If plan-file provided:
   Read(plan-file)
   → Parse task definitions, dependencies, groups

2. If no plan-file:
   Glob("*-PLAN.md", "*-ORCHESTRATION-PLAN.md")
   → Present options if multiple found

3. Extract from plan:
   - Task list with dependencies
   - Parallel execution groups
   - Success criteria per task
   - Review requirements

4. Record plan analysis:
   mcp__contextd__memory_record(
     project_id: "<repo>",
     title: "Plan Analysis: <plan_name>",
     content: "Parsed {n} tasks, {g} groups. Dependencies: {dep_summary}",
     outcome: "success",
     tags: ["orchestration", "planning", "<plan_name>"]
   )
```

### Phase 2: Dependency Resolution

```
1. Build dependency graph from plan:
   deps = {}
   for task in tasks:
     deps[task.id] = task.depends_on

2. Generate parallel groups (topological sort):
   groups = []
   while unscheduled_tasks:
     ready = [t for t in tasks if all deps satisfied]
     groups.append(ready)
     mark_scheduled(ready)

3. Validate no circular dependencies:
   if circular_detected:
     mcp__contextd__memory_record(
       title: "Dependency Error",
       content: "Circular dependency detected: {cycle}",
       outcome: "failure",
       tags: ["orchestration", "error", "dependency"]
     )
     Error("Circular dependency: {cycle}")
```

### Phase 3: Group Execution (Parallel with Context Folding)

For each group in execution order:

```
1. Create context branch for group:
   mcp__contextd__branch_create(
     session_id: "<session>",
     description: "Group {n}: {task_names}",
     budget: 8192
   )

2. Create task tracking:
   TaskCreate(
     subject: "Execute Group {n}: {task_names}",
     description: "Parallel execution of {count} tasks",
     activeForm: "Executing Group {n}"
   )

3. Launch parallel task agents:
   for task in group:
     Task(
       subagent_type: "fyrsmithlabs:contextd-task-agent",
       prompt: |
         {task.prompt}

         ## Engineering Practices (MANDATORY)
         - Read and follow CLAUDE.md and engineering-practices.md
         - Follow project security requirements and coding standards
         - Apply TDD: write tests BEFORE implementation
         - Run tests before considering task complete

         ## Contextd Integration
         - Record architectural decisions with mcp__contextd__memory_record
         - Record bug fixes with mcp__contextd__remediation_record
         - Search for relevant past learnings before starting
       description: "Task {n}: {task.name}",
       run_in_background: true
     )

4. Monitor completion:
   while agents_running:
     TaskOutput(task_id, block=false, timeout=30000)

     # Check context budget
     mcp__contextd__branch_status(branch_id: "<branch>")
     if usage > 80%:
       # Force early return if approaching limit
       summarize_progress()

5. Collect results and return from branch:
   mcp__contextd__branch_return(
     branch_id: "<branch>",
     message: "Group {n} complete: {task_count} tasks, {coverage}% avg coverage"
   )
```

### Phase 4: Consensus Review

After each group completes:

```
1. Launch review agents in parallel:
   Task(
     subagent_type: "fyrsmithlabs:security-reviewer",
     prompt: |
       Security review Group {n} files: {file_list}

       Focus on: Injection, auth, secrets, OWASP Top 10
       You have VETO power on critical/high findings.

       Record any security patterns found to contextd memory.
     description: "Security review Group {n}"
   )

   Task(
     subagent_type: "fyrsmithlabs:code-quality-reviewer",
     prompt: |
       Code quality review Group {n} files: {file_list}

       Focus on: Logic errors, test coverage, complexity
       Advisory only (no veto power).
     description: "Code quality review Group {n}"
   )

2. Collect verdicts:
   security_verdict = await security_agent
   quality_verdict = await quality_agent

3. Record review results:
   mcp__contextd__memory_record(
     project_id: "<repo>",
     title: "Review: Group {n}",
     content: "Security: {verdict}, Quality: {verdict}. Findings: {count}",
     outcome: security_verdict.approved ? "success" : "failure",
     tags: ["orchestration", "review", "group-{n}"]
   )

4. Check thresholds:
   if review_threshold == "strict":
     if any findings:
       → Remediate ALL findings before proceeding
   elif review_threshold == "standard":
     if security_verdict.veto or vulnerability_verdict.veto:
       → Remediate CRITICAL/HIGH findings
   else: # advisory
     → Log findings, continue execution
```

### Phase 5: Remediation Loop

If review findings require fixes:

```
1. Search for similar past remediations:
   mcp__contextd__remediation_search(
     project_id: "<repo>",
     query: "{finding.type} {finding.category}",
     limit: 3
   )
   → Apply known fixes if available

2. For each finding:
   a. Read the affected file
   b. Apply the recommended fix (or past remediation)
   c. Run tests to verify fix
   d. Record the remediation:
      mcp__contextd__remediation_record(
        project_id: "<repo>",
        error_signature: "{finding.type}",
        root_cause: "{finding.description}",
        solution: "{fix_applied}",
        prevention: "{how_to_prevent}",
        tags: ["orchestration", "security-fix"]
      )

3. Re-run consensus review on fixed files:
   if still_has_findings:
     if iteration < max_iterations:
       goto step 1
     else:
       AskUserQuestion("Review failed after {n} attempts. Continue anyway?")

4. Mark remediation complete:
   TaskUpdate(task_id, status: "completed")
```

### Phase 6: Checkpoint After Group

After each group passes review:

```
mcp__contextd__checkpoint_save(
  session_id: "orchestrate-<plan>",
  project_path: ".",
  name: "group-{n}-complete",
  description: "Group {n} complete with reviews passed",
  summary: |
    Completed: {completed_tasks}
    Remaining: {remaining_tasks}
    Coverage: {avg_coverage}%
    Findings fixed: {remediation_count}
  context: "{key_decisions}",
  auto_created: false
)
```

### Phase 7: RALPH Loop Analysis

After completing all groups, run reflection:

```
1. Analyze patterns from this orchestration:
   mcp__contextd__reflect_analyze(
     project_id: "<repo>",
     period_days: 1
   )
   → Identify improvement opportunities

2. Consolidate similar learnings:
   mcp__contextd__memory_consolidate(
     project_id: "<repo>",
     similarity_threshold: 0.8,
     dry_run: false
   )
   → Reduce memory noise

3. Generate reflection report:
   mcp__contextd__reflect_report(
     project_id: "<repo>",
     format: "markdown",
     period_days: 1
   )
   → Summary of learnings for future orchestrations
```

### Phase 8: Final Summary

After all groups complete:

```
1. Return from main orchestration branch:
   mcp__contextd__branch_return(
     branch_id: "<main_branch>",
     message: |
       Orchestration complete: {task_count} tasks, {group_count} groups
       Coverage: {avg_coverage}% | Reviews: {review_summary}
       Findings: {total_findings} identified, {fixed_count} remediated
   )

2. Display summary:
   ┌─────────────────────────────────────────────────────────┐
   │ Orchestration Complete                                   │
   └─────────────────────────────────────────────────────────┘

   Tasks: 7/7 completed
   Coverage: avg 87.3% (min: 63.6%, max: 100%)
   Reviews: All passed (Security: APPROVED, Quality: APPROVED)
   Findings: 12 identified, 12 remediated
   Learnings: 8 recorded to contextd memory
   Remediations: 5 recorded for future reference

   Files Changed: 24
   Tests Added: 156

   Ready for merge: Yes

3. Final memory record:
   mcp__contextd__memory_record(
     project_id: "<repo>",
     title: "Orchestration Complete: <plan_name>",
     content: |
       Successfully completed {n} tasks in {g} groups.
       Key metrics: {coverage}% coverage, {findings} findings fixed.
       Key learnings: {top_3_learnings}
     outcome: "success",
     tags: ["orchestration", "complete", "<plan_name>"]
   )

4. Save final checkpoint:
   mcp__contextd__checkpoint_save(
     session_id: "orchestrate-<plan>",
     name: "orchestrate-complete",
     description: "Orchestration finished successfully",
     summary: "All {n} tasks complete, ready for merge"
   )
```

## Plan File Format

The orchestration plan should be a markdown file with this structure:

```markdown
# Phase X Orchestration Plan

**Orchestration Pattern:** Contextd Multi-Agent with RALPH Loop
**Agents:** fyrsmithlabs:contextd-orchestrator + fyrsmithlabs:contextd-task-agent

## Tasks

### Task 1: Feature Name
**Priority:** P0
**Depends On:** None

#### Agent Prompt
\`\`\`markdown
# Task: Feature Name

## Context
Brief description of what this task accomplishes.

## Objectives
1. Objective 1
2. Objective 2

## Files to Create
- path/to/file1.go
- path/to/file2.go

## RALPH Requirements
- Record: Document design decisions in memory
- Analyze: Run consensus review
- Learn: Capture patterns for future use
- Plan: Update approach based on learnings
- Hypothesize: Test if approach improves metrics

## Completion Criteria
- [ ] Unit tests (80%+ coverage)
- [ ] Integration test
- [ ] Security review: PASS
- [ ] Memory recorded: Key decisions
- [ ] Remediation recorded: Bugs fixed
\`\`\`

### Task 2: Another Feature
**Depends On:** Task 1
...

## Dependency Graph

\`\`\`
Task 1 ──► Task 3 ──► Task 5
Task 2 ──► Task 4 ──► Task 5
\`\`\`

## Parallel Groups

- **Group 1:** Task 1, Task 2 (parallel)
- **Group 2:** Task 3, Task 4 (parallel, after Group 1)
- **Group 3:** Task 5 (after Group 2)

## Success Metrics

- [ ] All tasks complete
- [ ] 0 Critical security findings
- [ ] Average coverage > 80%
- [ ] All reviews passed
- [ ] Learnings recorded to contextd
```

## Review Agent Configuration

| Agent | Veto Power | Focus |
|-------|------------|-------|
| fyrsmithlabs:security-reviewer | YES | Injection, auth, secrets, OWASP |
| fyrsmithlabs:vulnerability-reviewer | YES | CVEs, outdated deps, supply chain |
| fyrsmithlabs:code-quality-reviewer | NO | Logic errors, coverage, complexity |
| fyrsmithlabs:documentation-reviewer | NO | README, comments, CHANGELOG |

## Example Session

```
User: /orchestrate PHASE2-ORCHESTRATION-PLAN.md --review-threshold strict

Claude: Initializing orchestration with contextd...

Searching for relevant past orchestrations...
Found 2 related memories:
- "Phase 1 Orchestration: Security patterns"
- "MCP integration learnings"

Creating orchestration branch (budget: 16384 tokens)...
Saving initial checkpoint: orchestrate-start

Found 7 tasks in 5 groups:
- Group 1: Task 1 (MCP Config), Task 2 (GitHub API)
- Group 2: Task 3 (Memory)
- Group 3: Task 4 (Learning), Task 7 (Folding)
- Group 4: Task 5 (Collaboration)
- Group 5: Task 6 (Composition)

═══════════════════════════════════════════════════════
Executing Group 1 (context branch: 8192 tokens)
═══════════════════════════════════════════════════════

[Launches fyrsmithlabs:contextd-task-agent for Task 1]
[Launches fyrsmithlabs:contextd-task-agent for Task 2]

Task 1 completed: Dynamic MCP Config (78.5% coverage)
  → Recorded 3 memories, 1 remediation
Task 2 completed: GitHub API Integration (41% coverage)
  → Recorded 2 memories

Returning from group branch with summary...

Running consensus review...
  Security Review: APPROVED (0 critical, 0 high)
  Code Quality Review: APPROVED (2 medium findings)

Searching past remediations for "code duplication"...
  Found: "Extract helper function pattern"

Remediating findings...
  ✓ Fixed: Code duplication in handlers
  ✓ Fixed: Missing error logging
  → Recorded 2 new remediations

Saving checkpoint: group-1-complete

═══════════════════════════════════════════════════════
[Continues through all groups with same pattern]
═══════════════════════════════════════════════════════

Running RALPH reflection analysis...
  Patterns identified: 3
  Memories consolidated: 5 → 2
  Reflection report generated

═══════════════════════════════════════════════════════
Orchestration Complete
═══════════════════════════════════════════════════════

Tasks: 7/7 completed
Coverage: 87.3% average
Reviews: All passed
Learnings: 12 recorded to contextd
Remediations: 8 recorded

Checkpoints saved:
  - orchestrate-start
  - group-1-complete
  - group-2-complete
  - group-3-complete
  - group-4-complete
  - group-5-complete
  - orchestrate-complete

Branch ready for PR: fix/issue-19-missing-authentication
```

## Resume Example

```
User: /orchestrate --resume "group-2-complete"

Claude: Resuming orchestration from checkpoint...

Loading checkpoint: group-2-complete
  Completed: Task 1, Task 2, Task 3
  Remaining: Task 4, Task 5, Task 6, Task 7
  Last coverage: 72.4%

Continuing from Group 3...

[Continues execution from where it left off]
```

## Attribution

Uses contextd MCP tools for memory, checkpoints, and context folding.
Uses fyrsmithlabs:security-reviewer, fyrsmithlabs:vulnerability-reviewer,
fyrsmithlabs:code-quality-reviewer, fyrsmithlabs:contextd-task-agent,
and fyrsmithlabs:contextd-orchestrator for parallel execution.

See CREDITS.md for full attribution.
