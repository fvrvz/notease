# Contributing to NoteEase

Thank you for your interest in contributing! This document covers the conventions and workflow.

## Branch Naming

```
feature/<short-description>    e.g. feature/google-drive-sync
fix/<short-description>        e.g. fix/note-save-debounce
chore/<short-description>      e.g. chore/update-dependencies
docs/<short-description>       e.g. docs/sync-architecture
```

Always branch from `develop`, not `main`.

## Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): short description

[optional body]

[optional footer]
```

### Types

| Type | Description |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `chore` | Maintenance, CI, dependencies |
| `docs` | Documentation only |
| `style` | Code formatting (no logic change) |
| `refactor` | Refactoring without behavior change |
| `test` | Tests |
| `perf` | Performance improvement |

### Examples

```
feat(notes): add accordion strip expand animation
fix(db): correct null handling in note update query
chore(deps): upgrade flutter_riverpod to 2.6.1
docs(arch): document sync conflict resolution strategy
```

## Pull Request Flow

1. Fork → branch from `develop`
2. Make changes with conventional commits
3. Open PR targeting `develop`
4. Pass all CI checks
5. Request review

## Code Style

- Run `flutter analyze` before committing
- Follow effective Dart style
- Use `const` constructors where possible
- Prefer `freezed` immutable models
- No raw `setState` in screens that have Riverpod providers

