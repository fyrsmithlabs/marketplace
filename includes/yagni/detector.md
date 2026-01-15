# yagni Pattern Detector

This hook runs on `PostToolUse` for Write and Edit operations. It analyzes file changes and session context to detect over-engineering patterns.

---

## Detection Logic

When a Write or Edit tool completes, analyze the change for these patterns:

### 1. Abstraction Creep (The Cynic)

**Trigger**: New file created with suspicious naming patterns

**Check filename against**:
- `*Factory*`
- `*Manager*`
- `*Provider*`
- `*Handler*`
- `*Helper*`
- `*Utils*`
- `*Base*`
- `*Abstract*`
- `*Wrapper*`
- `*Adapter*`
- `*Builder*`
- `*Coordinator*`
- `*Orchestrator*`

**Severity modifiers**:
- +1 if file is in a `factories/`, `managers/`, `utils/` directory
- +1 if this creates a 3+ layer deep call chain
- +1 if there's already a similar abstraction in the codebase

**Skip if**:
- Path matches allowlist (generated, vendor, etc.)
- Project config explicitly allows the pattern
- This is a test file

### 2. Config-Driven Everything (The Executive)

**Trigger**: Adding configuration for single-use behavior

**Detect**:
- New environment variable references (`process.env.FEATURE_*`, `os.getenv`)
- New entries in config files for behavior that exists once
- Feature flag patterns (`if (config.features.*)`, `featureFlags.isEnabled`)

**Severity modifiers**:
- +1 if the configured behavior exists in only one file
- +1 if the config key name suggests a one-off (`ENABLE_NEW_BUTTON`)
- -1 if this is a known config pattern (database URLs, API keys)

### 3. Speculative Generality (The Insecure Dev)

**Trigger**: Abstractions without multiple concrete uses

**Detect**:
- Interface/type with only one implementing class
- Generic type parameters that are only ever one type
- Abstract classes with single subclass
- Function parameters that are always the same value

**This requires codebase analysis**:
- Search for implementations of new interfaces
- Check generic instantiation sites
- Look for subclass count

### 4. Premature Optimization (The Perfectionist)

**Trigger**: Optimization patterns without evidence of need

**Detect patterns**:
- `useMemo`, `useCallback`, `React.memo` in React
- LRU/cache implementations
- Lazy loading / code splitting
- Connection pooling
- Debounce/throttle for things that don't need it

**Skip if**:
- There's a comment referencing profiling/benchmarks
- This is a known hot path (marked in config)
- The optimization pattern is framework-standard

### 5. Dead Code (The Minimalist)

**Trigger**: Code that serves no purpose

**Detect**:
- Large blocks of commented-out code (3+ lines)
- `// TODO: remove`, `// deprecated`, `// old implementation`
- Unused imports (if linter not running)
- Functions with no call sites

### 6. Swiss Army Knife (The Bro)

**Trigger**: Over-architected solutions for simple problems

**Detect**:
- Plugin/extension system files (`PluginManager`, `ExtensionLoader`)
- Event bus / message queue for local-only events
- Dependency injection containers for small apps
- Strategy pattern with single strategy

**Context matters**:
- Compare architecture complexity to task simplicity
- Flag if task is simple ("add button", "fix typo") but solution is elaborate

### 7. Scope Creep (The Realist)

**Trigger**: Changes exceed task scope

**Track per session**:
- Original task (from first user message or todo list)
- Files touched
- Files created
- Lines changed

**Thresholds (moderate)**:
- 5+ files touched for task with "simple" keywords
- 3+ new files created
- 10x more lines changed than task implies

**Simple task keywords**:
- "fix", "typo", "rename", "update", "change", "tweak"
- "add button", "add field", "remove"

### 8. File Explosion (The Confused)

**Trigger**: Too many new files in session

**Track**:
- Count of new files created this session
- File naming patterns (are they related?)

**Thresholds**:
- 5+ new files: Confused (The Confused)
- 8+ new files: Very confused (The Confused)

---

## Session State

Track across the session:

```yaml
session_state:
  original_task: "string - first substantive user request"
  files_touched: ["list of file paths"]
  files_created: ["list of new file paths"]
  tool_calls: 0
  context_percent: 0
  nudges_fired:
    - pattern: "abstraction_creep"
      count: 1
      last_fired: "timestamp"
      dismissed: false
  snoozes:
    - pattern: "time_based"
      until: "end_of_session"
```

---

## Backoff Logic

Avoid warning fatigue:

```
first_trigger_at = threshold
next_trigger = last_trigger + (base_increment * backoff_multiplier^nudge_count)
```

For time-based (The Supporter):
- First: 50% context
- Second: 75% context (50 + 25*1.5^0)
- Third: 87.5% context (75 + 25*1.5^1)
- Effectively stops after 3 nudges

For tool calls:
- First: 30 calls
- Second: 50 calls
- Third: 80 calls

---

## Output Format

When a pattern is detected, output the nudge in this format:

```
┌─────────────────────────────────────────────────────────────┐
│ 🤠 yagni: {{character_name}}                           │
└─────────────────────────────────────────────────────────────┘

{{character_message}}

{{context_block}}

{{simpler_path_suggestion}}

───────────────────────────────────────
Dismiss: "I know what I'm doing"
Snooze: "Back off for this session"
Adjust: /yagni config

Sensitivity: {{sensitivity}} | Pattern: {{pattern_name}}
```

---

## Configuration Loading

1. Check `~/.claude/yagni.yaml` for global config
2. Check `.claude/yagni.local.md` for project overrides
3. Merge with project overriding global
4. Apply sensitivity multipliers to thresholds:
   - conservative: thresholds * 1.5
   - moderate: thresholds * 1.0
   - aggressive: thresholds * 0.7
