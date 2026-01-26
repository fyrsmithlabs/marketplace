---
name: orchestrate
description: Execute a multi-task orchestration plan with parallel agents, consensus reviews, and automatic remediation. Use for complex multi-feature development phases. Say "orchestrate this plan", "execute phase 2", or "run the orchestration".
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
---

# /orchestrate

Execute a multi-task orchestration plan with parallel agents, dependency management, consensus reviews, and automatic remediation of findings.

## Execution

**Agent:** Main session (coordinates sub-agents)
**Context Folding:** Yes - each task group runs in isolated context
**Output:** Completed tasks, merged code, review reports

## Usage

```bash
# Execute orchestration from plan file
/orchestrate PHASE2-ORCHESTRATION-PLAN.md

# Execute specific groups only
/orchestrate --groups "3,4,5"

# Execute with strict review (100% findings addressed)
/orchestrate --review-threshold strict
```

## Workflow

### Phase 1: Plan Discovery

```
1. If plan-file provided:
   Read(plan-file)
   → Parse task definitions, dependencies, groups

2. If no plan-file:
   Search for *-PLAN.md or *-ORCHESTRATION-PLAN.md in repo
   → Present options if multiple found

3. Extract from plan:
   - Task list with dependencies
   - Parallel execution groups
   - Success criteria per task
   - Review requirements
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
     Error("Circular dependency: {cycle}")
```

### Phase 3: Group Execution (Parallel)

For each group in execution order:

```
1. Create task tracking:
   TaskCreate(
     subject: "Execute Group {n}: {task_names}",
     description: "Parallel execution of {count} tasks"
   )

2. Launch parallel agents:
   for task in group:
     Task(
       subagent_type: "fyrsmithlabs:contextd-task-agent",
       prompt: task.prompt,
       description: "Task {n}: {task.name}",
       run_in_background: true
     )

3. Monitor completion:
   while agents_running:
     TaskOutput(task_id, block=false, timeout=30000)
     Update progress display

4. Collect results:
   for agent in completed_agents:
     results[agent.task_id] = agent.output
```

### Phase 4: Consensus Review

After each group completes:

```
1. Launch review agents in parallel:
   Task(
     subagent_type: "fyrsmithlabs:security-reviewer",
     prompt: "Security review Group {n} files: {file_list}",
     description: "Security review Group {n}"
   )
   Task(
     subagent_type: "fyrsmithlabs:code-quality-reviewer",
     prompt: "Code quality review Group {n} files: {file_list}",
     description: "Code quality review Group {n}"
   )

2. Collect verdicts:
   security_verdict = await security_agent
   quality_verdict = await quality_agent

3. Check thresholds:
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
1. Parse findings from review output:
   findings = []
   for line in review_output:
     if matches("[x] " or "- [ ]"):
       findings.append(parse_finding(line))

2. For each finding:
   a. Read the affected file
   b. Apply the recommended fix
   c. Run tests to verify fix
   d. If tests fail, rollback and flag for manual review

3. Re-run consensus review on fixed files:
   if still_has_findings:
     if iteration < max_iterations:
       goto step 1
     else:
       AskUserQuestion("Review failed after {n} attempts. Continue anyway?")

4. Mark remediation complete:
   TaskUpdate(task_id, status: "completed")
```

### Phase 6: Progress Tracking

Throughout execution:

```
1. Display progress table:
   ┌──────────────────────────────────────────────────┐
   │ Orchestration Progress                            │
   └──────────────────────────────────────────────────┘

   Group 1: [████████████████████] 100% - COMPLETE
   Group 2: [██████████░░░░░░░░░░]  50% - Task 3 running
   Group 3: [░░░░░░░░░░░░░░░░░░░░]   0% - PENDING

   Reviews: 2/5 passed | Findings: 3 fixed, 1 pending

2. Update on each event:
   - Task started → Mark in_progress
   - Task completed → Mark complete, show coverage
   - Review completed → Show verdict
   - Finding fixed → Update counter
```

### Phase 7: Final Summary

After all groups complete:

```
1. Generate summary:
   ┌─────────────────────────────────────────────────────────┐
   │ Orchestration Complete                                   │
   └─────────────────────────────────────────────────────────┘

   Tasks: 7/7 completed
   Coverage: avg 87.3% (min: 63.6%, max: 100%)
   Reviews: All passed (Security: APPROVED, Quality: APPROVED)
   Findings: 12 identified, 12 remediated

   Files Changed: 24
   Tests Added: 156

   Ready for merge: Yes

2. Record learnings:
   mcp__contextd__memory_record(
     project_id: "<project>",
     title: "Orchestration: <plan_name>",
     content: "Completed {n} tasks in {groups} groups. Key learnings: {summary}",
     outcome: "success",
     tags: ["orchestration", "phase-completion"]
   )
```

## Plan File Format

The orchestration plan should be a markdown file with this structure:

```markdown
# Phase X Orchestration Plan

## Tasks

### Task 1: Feature Name
**Priority:** P0
**Depends On:** None

#### Prompt
\`\`\`markdown
# Task: Feature Name

## Objectives
1. Objective 1
2. Objective 2

## Files to Create
- path/to/file1.go
- path/to/file2.go

## Completion Criteria
- [ ] Unit tests (80%+ coverage)
- [ ] Integration test
- [ ] Security review: PASS
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
```

## Review Agent Configuration

| Agent | Veto Power | Focus |
|-------|------------|-------|
| Security Reviewer | YES | Injection, auth, secrets, OWASP |
| Vulnerability Reviewer | YES | CVEs, outdated deps, supply chain |
| Code Quality Reviewer | NO | Logic errors, coverage, complexity |
| Documentation Reviewer | NO | README, comments, CHANGELOG |

## Example Session

```
User: /orchestrate PHASE2-ORCHESTRATION-PLAN.md --review-threshold strict

Claude: Reading orchestration plan...

Found 7 tasks in 5 groups:
- Group 1: Task 1 (MCP Config), Task 2 (GitHub API)
- Group 2: Task 3 (Memory)
- Group 3: Task 4 (Learning), Task 7 (Folding)
- Group 4: Task 5 (Collaboration)
- Group 5: Task 6 (Composition)

Starting Group 1 execution...

[Launches parallel agents for Task 1 and Task 2]

Task 1 completed: Dynamic MCP Config (78.5% coverage)
Task 2 completed: GitHub API Integration (41% coverage)

Running consensus review on Group 1...

Security Review: APPROVED (0 critical, 0 high)
Code Quality Review: APPROVED (2 medium findings)

Remediating findings...
- Fixed: Code duplication in handlers
- Fixed: Missing error logging

Group 1 complete. Starting Group 2...

[Continues through all groups]

═══════════════════════════════════════════════════════
Orchestration Complete

Tasks: 7/7 completed
Coverage: 87.3% average
Reviews: All passed
Duration: ~4 hours

Branch ready for PR: fix/issue-19-missing-authentication
═══════════════════════════════════════════════════════
```

## Attribution

Uses fyrsmithlabs:security-reviewer, fyrsmithlabs:code-quality-reviewer,
fyrsmithlabs:contextd-task-agent, and Task tool for parallel execution.
