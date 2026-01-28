# Plugin Test Framework

**Version:** 1.0.0
**Purpose:** TDD and stress testing for fyrsmithlabs marketplace plugins
**Target:** NEW USER simulation in Docker containers

---

## Quick Start

```bash
# Build test container
docker build -f Dockerfile.test -t marketplace-test .

# Run validation tests
docker run --rm marketplace-test

# Run interactive tests (requires API key)
docker run -it --rm \
  -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  marketplace-test \
  bash -c "claude --plugin-dir /home/testuser/marketplace"
```

---

## Test Categories

| Category | Purpose | Automation |
|----------|---------|------------|
| **Validation** | Schema and structure | Automated |
| **Hook Tests** | Event triggers | Semi-automated |
| **Command Tests** | Slash commands | Manual prompts |
| **Agent Tests** | Subagent behavior | Manual prompts |
| **Skill Tests** | Model invocation | Manual prompts |
| **Integration** | End-to-end workflows | Manual prompts |
| **Stress Tests** | Edge cases, failures | Manual prompts |

---

## 1. Validation Tests (Automated)

Run via Dockerfile.test:

```bash
# Validate all plugins
claude plugin validate /home/testuser/marketplace/.claude-plugin/marketplace.json
claude plugin validate /home/testuser/marketplace/plugins/contextd/.claude-plugin/plugin.json
claude plugin validate /home/testuser/marketplace/plugins/fs-design/.claude-plugin/plugin.json

# Verify plugin loading
claude --plugin-dir /home/testuser/marketplace --version
```

**Expected:**
- All validations pass
- No errors on plugin load
- Version outputs correctly

---

## 2. Hook Tests

### 2.1 PreToolUse Hook (Write|Edit)

**Hook Location:** `hooks/hooks.json`

| Test | Prompt | Expected |
|------|--------|----------|
| Block agent artifact in root | `Create a file called TODO.md in the project root` | BLOCK with explanation |
| Allow agent artifact in docs | `Create docs/.claude/PLAN.md with a test plan` | ALLOW |
| Block secrets | `Create config.js with: const API_KEY = "sk-abc123"` | BLOCK with secret warning |
| Enforce kebab-case | `Create a file called MyComponent.js` | NUDGE for kebab-case |
| Allow kebab-case | `Create a file called my-component.js` | ALLOW |

**Test Script:**
```bash
# In Claude Code session:

# Test 1: Should BLOCK
> Create a file called TODO.md in the current directory with "test content"

# Test 2: Should ALLOW
> Create docs/.claude/PLAN.md with "# Test Plan"

# Test 3: Should BLOCK
> Create test-config.js containing: export const SECRET = "password123"

# Test 4: Should NUDGE
> Create a file called TestHelper.js

# Test 5: Should ALLOW
> Create a file called test-helper.js
```

### 2.2 PreCompact Hook

**Hook Location:** `hooks/hooks.json`
**Trigger:** Context compaction (manual or auto)

| Test | Trigger | Expected |
|------|---------|----------|
| Manual compact | `/compact` | Outputs checkpoint instructions |
| Auto compact | Fill context | Outputs checkpoint instructions |

**Test Script:**
```bash
# Test manual compact
> /compact

# Expected output should include:
# - Session ID
# - Checkpoint instructions
# - Recent file changes
```

### 2.3 SessionStart Hook (contextd)

**Hook Location:** `plugins/contextd/hooks/hooks.json`
**Trigger:** Session start/resume

| Test | Condition | Expected |
|------|-----------|----------|
| contextd installed | MCP configured | "✓ contextd MCP server is configured" |
| contextd missing | Not installed | "⚠️ contextd is not installed" |
| MCP not configured | Binary only | "⚠️ contextd is installed but MCP not configured" |

### 2.4 Setup Hook (contextd)

**Hook Location:** `plugins/contextd/hooks/hooks.json`
**Trigger:** `claude --init`

| Test | Condition | Expected |
|------|-----------|----------|
| Fresh install | No contextd | Downloads and installs contextd |
| Already installed | contextd present | Skips install, verifies MCP config |

**Test Script:**
```bash
# In container without contextd:
claude --init --plugin-dir /home/testuser/marketplace/plugins/contextd

# Expected:
# - Downloads contextd via brew or binary
# - Configures MCP
# - Reports success
```

---

## 3. Command Tests

### 3.1 fs-dev Commands

#### /init
```
Prompt: /init
Expected:
- Scans project for compliance
- Reports gaps in standards
- Offers to fix issues
- Records to contextd if available

Variations:
- /init --check (audit only)
- /init on compliant repo (should report clean)
```

#### /yagni
```
Prompt: /yagni
Expected:
- Shows YAGNI status
- Displays current configuration

Prompt: /yagni why
Expected:
- Explains last YAGNI nudge (if any)

Prompt: /yagni principles
Expected:
- Displays YAGNI/KISS guidelines
```

#### /plan
```
Prompt: /plan add user authentication
Expected:
- Runs complexity assessment (SIMPLE/STANDARD/COMPLEX)
- Creates GitHub Issue
- For STANDARD+: runs brainstorm
- Sets up worktree for COMPLEX

Prompt: /plan fix typo
Expected:
- SIMPLE tier (5-6 range)
- Minimal workflow
- No brainstorm needed
```

#### /standup
```
Prompt: /standup
Expected:
- Queries GitHub for recent activity
- Loads contextd checkpoint if available
- Synthesizes priorities
- Shows cross-project dependencies

Prompt: /standup --brief
Expected:
- Condensed output

Prompt: /standup --since 48h
Expected:
- Custom lookback period
```

#### /discover
```
Prompt: /discover
Expected:
- Analyzes codebase structure
- Reports findings by lens (architecture, testing, etc.)

Prompt: /discover --lens security
Expected:
- Focused security analysis
```

### 3.2 contextd Commands

#### /contextd:init
```
Prompt: /contextd:init
Expected:
- Checks contextd availability
- Generates/updates CLAUDE.md
- Indexes repository

Prompt: /contextd:init --full
Expected:
- Full onboarding with analysis
- Extracts team patterns
```

#### /contextd:search
```
Prompt: /contextd:search authentication patterns
Expected:
- Searches memories, remediations, code
- Returns ranked results

Prompt: /contextd:search (no query)
Expected:
- Prompts for search query via AskUserQuestion
```

#### /contextd:remember
```
Prompt: /contextd:remember
Expected:
- Prompts for what to remember
- Records with appropriate tags
- Confirms recording

Prompt: Remember that path.resolve() should be used for file operations
Expected:
- Natural language trigger
- Records the learning
```

#### /contextd:checkpoint
```
Prompt: /contextd:checkpoint
Expected:
- Saves session state
- Reports checkpoint ID
- Shows resume instructions
```

#### /contextd:diagnose
```
Prompt: /contextd:diagnose TypeError: Cannot read property 'foo' of undefined
Expected:
- Searches past remediations
- Provides AI diagnosis
- Suggests fixes
```

#### /contextd:orchestrate
```
Prompt: /contextd:orchestrate
Expected:
- Prompts for issue numbers via AskUserQuestion
- Loads issues from GitHub
- Creates execution plan
- Runs parallel agents with context-folding
```

### 3.3 fs-design Commands

#### /fs-design:check
```
Prompt: /fs-design:check
Expected:
- Scans default locations (static/css, templates)
- Reports violations by severity

Prompt: /fs-design:check static/css/main.css
Expected:
- Focused scan on specific file

Test with violations:
- Hardcoded color: background: #ea580c → CRITICAL
- Missing alt text: <img src="x"> → ERROR
- Brand inconsistency: "Fyrsmith Labs" → WARNING
```

---

## 4. Agent Tests

### 4.1 Review Agents (fs-dev)

#### security-reviewer (VETO)
```
Test: Review code with SQL injection
Code: db.query("SELECT * FROM users WHERE id = " + userId)
Expected: BLOCK with explanation

Test: Review code with hardcoded secret
Code: const API_KEY = "sk-abc123def456"
Expected: BLOCK with secret detected

Test: Review secure code
Code: db.query("SELECT * FROM users WHERE id = ?", [userId])
Expected: APPROVE
```

#### vulnerability-reviewer (VETO)
```
Test: Review outdated dependency
package.json: "lodash": "4.17.0" (known CVE)
Expected: BLOCK with CVE reference

Test: Review GPL in Apache project
Expected: WARNING about license incompatibility

Test: Review current dependencies
Expected: APPROVE
```

#### code-quality-reviewer (NO VETO)
```
Test: Review complex function (high cyclomatic complexity)
Expected: SUGGEST refactoring, no block

Test: Review clean code
Expected: APPROVE with minor suggestions
```

### 4.2 contextd Agents

#### task-agent
```
Prompt: Use task-agent to debug this error: [error message]
Expected:
- Searches remediations
- Analyzes error
- Proposes solution
- Records if successful
```

#### orchestrator
```
Prompt: Use orchestrator to review this PR for security, performance, and style
Expected:
- Spawns multiple sub-agents
- Coordinates results
- Handles failures gracefully
- Records learnings
```

### 4.3 fs-design Agents

#### consistency-reviewer
```
Prompt: Use consistency-reviewer to audit static/css/
Expected:
- Scans all CSS files
- Reports design system violations
- Groups by severity
```

---

## 5. Skill Tests

### 5.1 Complexity Assessment
```
Prompt: Assess complexity for "fix typo in README"
Expected: SIMPLE (5-6)

Prompt: Assess complexity for "add OAuth2 authentication"
Expected: STANDARD (9-12)

Prompt: Assess complexity for "rewrite database layer"
Expected: COMPLEX (13-15)
```

### 5.2 Git Workflows
```
Prompt: Set up git workflow for this repo
Expected:
- Configures consensus review
- Sets up branch protection recommendations
- Documents PR requirements
```

### 5.3 YAGNI Skill
```
Trigger: Create AbstractFactoryManagerProvider class
Expected:
- YAGNI nudge about over-abstraction
- Suggests simpler alternative
- Offers to proceed if intentional
```

---

## 6. Integration Tests

### 6.1 New Project Setup → First PR
```
Sequence:
1. /init → Set up standards
2. /plan "add feature X" → Plan the work
3. Implement feature (triggers Write/Edit hooks)
4. /contextd:consensus-review → Multi-agent review
5. Create PR → Verify all hooks fired
```

### 6.2 Error Recovery with contextd
```
Sequence:
1. Encounter error during implementation
2. /contextd:diagnose → Analyze error
3. Apply fix
4. /contextd:remember → Record the fix
5. New session → /contextd:search → Find the fix
```

### 6.3 Cross-Session Memory
```
Session 1:
1. /contextd:remember "Always use path.resolve() for file paths"
2. /contextd:checkpoint

Session 2:
1. /contextd:search "file paths"
2. Verify memory is found
3. Apply learning
```

---

## 7. Stress Tests

### 7.1 Hook Edge Cases
```
Test: Rapid file creation
Prompt: Create 10 files: test-1.js through test-10.js
Expected: All hooks fire, no race conditions

Test: Nested hook triggers
Prompt: Edit a file that triggers Write hook, which might trigger another hook
Expected: No infinite loops, proper sequencing

Test: Hook timeout
Prompt: Trigger a hook that takes >60 seconds
Expected: Graceful timeout, session continues
```

### 7.2 Agent Failures
```
Test: Agent with missing MCP
Prompt: /contextd:search (with contextd MCP unavailable)
Expected: Graceful degradation, helpful error message

Test: Parallel agent failure
Prompt: Run consensus review where one agent fails
Expected: Other agents complete, partial results returned
```

### 7.3 Large Context
```
Test: Session approaching context limit
Prompt: Continue working until context is 90% full
Expected: PreCompact hook fires, checkpoint offered

Test: Resume from checkpoint
Prompt: /contextd:checkpoint then /clear then resume
Expected: Context restored, work continues
```

### 7.4 Malformed Input
```
Test: Invalid issue number
Prompt: /contextd:orchestrate with issue #99999
Expected: Error handling, no crash

Test: Empty search
Prompt: /contextd:search ""
Expected: Prompts for valid query
```

---

## 8. Docker Test Runner

### Dockerfile.test Updates

```dockerfile
FROM node:20-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Create test user
RUN useradd -m -s /bin/bash testuser

# Copy marketplace plugins
COPY --chown=testuser:testuser . /home/testuser/marketplace

USER testuser
WORKDIR /home/testuser

# Set up Claude config directory
RUN mkdir -p /home/testuser/.claude

# Validation test script
COPY --chown=testuser:testuser tests/run-validation.sh /home/testuser/run-validation.sh
RUN chmod +x /home/testuser/run-validation.sh

CMD ["/home/testuser/run-validation.sh"]
```

### run-validation.sh

```bash
#!/bin/bash
set -e

echo "=== Plugin Validation ==="

echo -e "\n--- fs-dev plugin ---"
claude plugin validate /home/testuser/marketplace/.claude-plugin/marketplace.json

echo -e "\n--- contextd plugin ---"
claude plugin validate /home/testuser/marketplace/plugins/contextd/.claude-plugin/plugin.json

echo -e "\n--- fs-design plugin ---"
claude plugin validate /home/testuser/marketplace/plugins/fs-design/.claude-plugin/plugin.json

echo -e "\n=== MCP Configuration Check ==="
if [ -f /home/testuser/marketplace/plugins/contextd/.mcp.json ]; then
    echo "✓ contextd .mcp.json present"
    jq . /home/testuser/marketplace/plugins/contextd/.mcp.json
else
    echo "✗ contextd .mcp.json missing"
    exit 1
fi

echo -e "\n=== Hook Configuration Check ==="
for hook_file in /home/testuser/marketplace/hooks/hooks.json /home/testuser/marketplace/plugins/contextd/hooks/hooks.json; do
    if [ -f "$hook_file" ]; then
        echo "✓ Found: $hook_file"
        jq '.hooks | keys' "$hook_file"
    fi
done

echo -e "\n=== Script Permissions Check ==="
for script in /home/testuser/marketplace/plugins/contextd/scripts/*.sh; do
    if [ -x "$script" ]; then
        echo "✓ Executable: $(basename $script)"
    else
        echo "✗ Not executable: $(basename $script)"
        exit 1
    fi
done

echo -e "\n=== Loading Plugins (dry run) ==="
echo "Testing plugin loading with --plugin-dir..."
claude --plugin-dir /home/testuser/marketplace --version

echo -e "\n=== All Validation Tests Passed ==="
```

---

## 9. Manual Test Checklist

Use this checklist when running interactive tests:

### Pre-Test Setup
- [ ] Container built successfully
- [ ] API key configured (if needed)
- [ ] Fresh session (no prior state)

### fs-dev Plugin
- [ ] /init runs without errors
- [ ] /yagni shows status
- [ ] /plan creates complexity assessment
- [ ] /standup synthesizes GitHub activity
- [ ] /discover analyzes codebase
- [ ] Write hook blocks agent artifacts in root
- [ ] Write hook allows files in docs/.claude/
- [ ] Write hook blocks secrets
- [ ] Review agents return structured feedback

### contextd Plugin
- [ ] SessionStart hook reports contextd status
- [ ] /contextd:init initializes project
- [ ] /contextd:search returns results (if MCP available)
- [ ] /contextd:remember records learnings
- [ ] /contextd:checkpoint saves state
- [ ] /contextd:orchestrate prompts for issues
- [ ] Graceful degradation without MCP

### fs-design Plugin
- [ ] /fs-design:check scans files
- [ ] Reports hardcoded colors as CRITICAL
- [ ] Reports missing alt text as ERROR
- [ ] consistency-reviewer returns structured audit

### Integration
- [ ] Full workflow: init → plan → implement → review → PR
- [ ] Cross-session memory works
- [ ] Checkpoint resume works
- [ ] Hook ordering is correct

---

## 10. Test Results Template

```markdown
# Test Run: [DATE]

## Environment
- Claude Code Version: X.X.X
- Container Image: marketplace-test:latest
- Plugins Tested: fs-dev, contextd, fs-design

## Validation Results
| Plugin | Status | Notes |
|--------|--------|-------|
| fs-dev | PASS/FAIL | |
| contextd | PASS/FAIL | |
| fs-design | PASS/FAIL | |

## Hook Tests
| Hook | Test | Status | Notes |
|------|------|--------|-------|
| PreToolUse | Block artifact | PASS/FAIL | |
| PreToolUse | Allow correct path | PASS/FAIL | |
| SessionStart | Status check | PASS/FAIL | |
| Setup | Install contextd | PASS/FAIL | |

## Command Tests
| Command | Status | Notes |
|---------|--------|-------|
| /init | PASS/FAIL | |
| /yagni | PASS/FAIL | |
| /plan | PASS/FAIL | |
| /contextd:search | PASS/FAIL | |
| /fs-design:check | PASS/FAIL | |

## Issues Found
1. [Issue description]
2. [Issue description]

## Recommendations
1. [Recommendation]
2. [Recommendation]
```

---

## Appendix: Component Inventory

### Commands (21 total)
| Plugin | Command | Tested |
|--------|---------|--------|
| fs-dev | /init | [ ] |
| fs-dev | /yagni | [ ] |
| fs-dev | /plan | [ ] |
| fs-dev | /standup | [ ] |
| fs-dev | /brainstorm | [ ] |
| fs-dev | /discover | [ ] |
| fs-dev | /test-skill | [ ] |
| fs-dev | /app-interview | [ ] |
| fs-dev | /spec-refinement | [ ] |
| fs-dev | /comp-analysis | [ ] |
| contextd | /contextd:init | [ ] |
| contextd | /contextd:search | [ ] |
| contextd | /contextd:remember | [ ] |
| contextd | /contextd:checkpoint | [ ] |
| contextd | /contextd:diagnose | [ ] |
| contextd | /contextd:status | [ ] |
| contextd | /contextd:reflect | [ ] |
| contextd | /contextd:consensus-review | [ ] |
| contextd | /contextd:orchestrate | [ ] |
| contextd | /contextd:help | [ ] |
| fs-design | /fs-design:check | [ ] |

### Agents (10 total)
| Plugin | Agent | Veto | Tested |
|--------|-------|------|--------|
| fs-dev | security-reviewer | Yes | [ ] |
| fs-dev | vulnerability-reviewer | Yes | [ ] |
| fs-dev | code-quality-reviewer | No | [ ] |
| fs-dev | documentation-reviewer | No | [ ] |
| fs-dev | user-persona-reviewer | No | [ ] |
| fs-dev | product-owner | N/A | [ ] |
| contextd | task-agent | N/A | [ ] |
| contextd | orchestrator | N/A | [ ] |
| fs-design | consistency-reviewer | N/A | [ ] |
| fs-design | task-executor | N/A | [ ] |

### Skills (16 total)
| Plugin | Skill | Tested |
|--------|-------|--------|
| fs-dev | git-repo-standards | [ ] |
| fs-dev | git-workflows | [ ] |
| fs-dev | init | [ ] |
| fs-dev | yagni | [ ] |
| fs-dev | complexity-assessment | [ ] |
| fs-dev | github-planning | [ ] |
| fs-dev | roadmap-discovery | [ ] |
| fs-dev | product-owner | [ ] |
| fs-dev | context-folding | [ ] |
| contextd | using-contextd | [ ] |
| contextd | setup | [ ] |
| contextd | workflow | [ ] |
| contextd | consensus-review | [ ] |
| contextd | orchestration | [ ] |
| contextd | self-reflection | [ ] |
| fs-design | check | [ ] |

### Hooks (4 total)
| Plugin | Event | Matcher | Tested |
|--------|-------|---------|--------|
| fs-dev | PreCompact | * | [ ] |
| fs-dev | PreToolUse | Write\|Edit | [ ] |
| contextd | Setup | init | [ ] |
| contextd | SessionStart | startup\|resume | [ ] |
