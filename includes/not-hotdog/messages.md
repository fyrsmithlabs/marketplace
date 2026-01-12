# Message Assembly Logic

Assembles final nudge messages from detected patterns, character templates, and context.

---

## Message Structure

Each nudge consists of:

1. **Header** — Character identification
2. **Character Quote** — The personality-driven observation
3. **Context Block** — What triggered the nudge
4. **Simpler Path** — Concrete before/after suggestion
5. **Footer** — Dismiss/snooze/config options

---

## Assembly Process

### Step 1: Select Character

Based on pattern type:

| Pattern | Character |
|---------|-----------|
| `abstraction_creep` | The Cynic |
| `config_driven` | The Executive |
| `speculative_generality` | The Insecure Dev |
| `premature_optimization` | The Perfectionist |
| `dead_code` | The Minimalist |
| `swiss_army_knife` | The Bro |
| `scope_creep` | The Realist |
| `file_explosion` | The Confused |
| `time_based` | The Supporter |

### Step 2: Select Quote Template

From `characters.md`, select a quote template for the character and pattern. Rotate through available templates to avoid repetition.

### Step 3: Fill Template Variables

Common variables:

| Variable | Source |
|----------|--------|
| `{{filename}}` | Current file being written/edited |
| `{{pattern}}` | The matched pattern (e.g., "Factory") |
| `{{original_task}}` | From session state |
| `{{file_count}}` | Files touched this session |
| `{{new_files}}` | New files created this session |
| `{{duration}}` | Time since session start |
| `{{context_percent}}` | Current context usage |
| `{{lines}}` | Lines of code affected |
| `{{function_name}}` | Specific function if applicable |

### Step 4: Generate Context Block

Format depends on pattern:

**For abstraction_creep**:
```
You created: {{filepath}}
Task stated: "{{original_task}}"
```

**For scope_creep**:
```
Original goal: {{original_task}}
Current trajectory: {{files_list}} ({{file_count}} files)
```

**For time_based**:
```
Session duration: {{duration}}
Context usage: {{context_percent}}%
Files touched: {{file_count}}
Original task: "{{original_task}}"
```

**For dead_code**:
```
Found in: {{filepath}}
- {{lines}} lines of commented-out code
- {{unused_count}} unused imports/functions
```

### Step 5: Generate Simpler Path

Look up the pattern in `examples/simpler-paths.md` and provide a relevant before/after.

If the specific case matches a known example, use that. Otherwise, generate a generic suggestion:

**Generic suggestions by pattern**:

| Pattern | Generic Suggestion |
|---------|-------------------|
| `abstraction_creep` | "Consider calling the underlying function directly" |
| `config_driven` | "Could this just be a constant or hardcoded value?" |
| `speculative_generality` | "Remove the abstraction until you have 2+ concrete uses" |
| `premature_optimization` | "Write the simple version first, optimize after profiling" |
| `dead_code` | "Delete it. Git remembers." |
| `swiss_army_knife` | "Build the specific solution, not the platform" |
| `scope_creep` | "Create a separate task for the additional work" |
| `file_explosion` | "Consider consolidating related code into fewer files" |
| `time_based` | "Check if current work still serves the original goal" |

### Step 6: Assemble Final Message

```
┌─────────────────────────────────────────────────────────────┐
│ 🤠 middle-out: {{character_name}}                           │
└─────────────────────────────────────────────────────────────┘

{{filled_character_quote}}

{{context_block}}

**Simpler path:**
{{simpler_path_suggestion}}

───────────────────────────────────────
Dismiss: "I know what I'm doing"
Snooze: "Back off for this session"
Adjust: /not-hotdog config

Sensitivity: {{sensitivity}} | Pattern: {{pattern_name}}
```

---

## Response Handling

### On "I know what I'm doing"

- Log dismissal in session state
- Increment nudge count for backoff calculation
- Continue without further action for this instance

### On "Back off for this session"

- Add pattern to snooze list in session state
- Pattern will not fire again this session

### On "/not-hotdog config"

- Show current configuration
- Offer to adjust sensitivity or disable specific patterns
- Update config file if changes requested

---

## Rate Limiting

Never fire more than one nudge per tool call. If multiple patterns detect issues:

1. Prioritize by severity (blocking concerns first, though nothing actually blocks)
2. Pick the most specific pattern
3. Queue others for potential later mention

Priority order:
1. `scope_creep` (highest signal-to-noise)
2. `abstraction_creep`
3. `swiss_army_knife`
4. `config_driven`
5. `speculative_generality`
6. `premature_optimization`
7. `dead_code`
8. `file_explosion`
9. `time_based` (lowest priority, The Supporter waits patiently)
