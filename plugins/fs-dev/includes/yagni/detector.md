# YAGNI Pattern Detector

Detect over-engineering patterns. Output structured, actionable nudges.

## Patterns

| Pattern | Trigger |
|---------|---------|
| `abstraction` | Filename contains: Factory, Manager, Provider, Handler, Helper, Utils, Base, Abstract, Wrapper, Builder, Coordinator, Orchestrator |
| `config-addiction` | Feature flag, env var, or config for single-use behavior |
| `scope-creep` | Task with "fix/typo/rename/tweak" touches 5+ files |
| `dead-code` | Large commented blocks (10+ lines), unused imports |

## Skip Detection

- Path contains: `generated/`, `vendor/`, `node_modules/`, `migrations/`
- Test files: `*.test.*`, `*.spec.*`, `__tests__/`
- Excluded in `.claude/yagni.local.md`

## Output Format

```
⚠️ YAGNI: [pattern]
├─ Trigger: [what triggered]
├─ Concern: [why this matters]
└─ Simpler: [alternative]

Options: Dismiss | Snooze | /yagni config
```

## Example

```
⚠️ YAGNI: abstraction
├─ Trigger: Creating ConfigManagerFactory.ts
├─ Concern: Factory for single config type
└─ Simpler: Export config directly from config.ts

Options: Dismiss | Snooze | /yagni config
```

## Detection Rules

**abstraction**: Filename matches pattern list + file is new (Write, not Edit)

**config-addiction**: New env var/config option + only one usage in codebase

**scope-creep**: TodoWrite completion + simple-task keyword + 5+ files touched

**dead-code**: Write/Edit adds 10+ commented lines or unused imports

## Mode

Always `notify` (inform, don't block). Developer decides.
