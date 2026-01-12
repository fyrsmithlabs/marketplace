# Verification Criteria for Issues

Reference for including verification in GitHub Issues.

## Markdown Table Format

Include verification as a table in Issue body:

```markdown
## Verification

| Type | Details | Expected |
|------|---------|----------|
| command | `npm test` | All tests pass |
| api | POST /api/users | 201 with user object |
| browser | Navigate to /dashboard | No console errors |
```

## Type Icons (Optional)

For visual clarity:

| Type | Icon | Usage |
|------|------|-------|
| command | `>_` | CLI commands |
| api | `{}` | HTTP requests |
| browser | `🌐` | Manual browser checks |
| e2e | `🎭` | Playwright/Cypress |
| manual | `✋` | Human verification |

## Inline Format

For simple issues, use inline format:

```markdown
**Verify:** Run `npm test -- auth` - expect all tests pass
```

## Per-Task Verification

For epics with sub-issues, each sub-issue gets its own verification:

**Epic:** High-level success criteria
```markdown
## Success Criteria
- All sub-issues completed
- Integration tests pass
- No regression in existing functionality
```

**Sub-issue:** Specific verification
```markdown
## Verification
| Type | Details | Expected |
|------|---------|----------|
| command | `npm test -- user.spec.ts` | All user tests pass |
```

## Reference

See `includes/verification-criteria/` for:
- Full type definitions: `types.md`
- Auto-generation logic: `generators.md`
