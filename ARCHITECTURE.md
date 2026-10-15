# Architecture — NoteEase

## Overview

NoteEase is built with **Flutter** following a clean layered architecture with feature-first organization.

## Layer Diagram

```
┌──────────────────────────────────────────────────┐
│                 Presentation                      │
│   Flutter widgets + Riverpod (ConsumerWidget)     │
│   go_router for navigation                        │
└─────────────────────┬────────────────────────────┘
                      │
┌─────────────────────▼────────────────────────────┐
│                   Domain                          │
│   Dart models (freezed/immutable)                 │
│   Repository interfaces (abstract)                │
│   Use case classes                                │
└─────────────────────┬────────────────────────────┘
                      │
┌─────────────────────▼────────────────────────────┐
│                    Data                           │
│   Local: Drift (SQLite — all platforms)           │
│   Remote: Cloud sync adapters                     │
│   Repository implementations                      │
└──────────────────────────────────────────────────┘
```

## Folder Structure

```
lib/
├── core/
│   ├── theme/         # AppTheme, AppColors, ThemeModeNotifier
│   ├── router/        # GoRouter config
│   ├── constants/     # App-wide constants
│   └── utils/         # Helper extensions
│
├── domain/
│   ├── models/        # Note, AppUser (freezed)
│   ├── repositories/  # Abstract interfaces
│   └── usecases/      # Business logic classes
│
├── data/
│   ├── local/         # Drift database, DAOs
│   ├── sync/          # Cloud sync adapters
│   │   ├── google_drive_sync.dart
│   │   ├── onedrive_sync.dart
│   │   ├── dropbox_sync.dart
│   │   └── icloud_sync.dart
│   └── repositories/  # Concrete implementations
│
└── features/
    ├── notes/
    │   ├── presentation/
    │   │   ├── pages/    # NotesHomePage, NoteEditorPage
    │   │   └── widgets/  # NoteAccordionStrip, NoteContentPanel, NavSidebar
    │   └── providers/    # Riverpod providers
    ├── auth/
    │   └── presentation/
    │       └── pages/    # WelcomePage
    └── settings/
        └── presentation/
            └── pages/    # SettingsPage
```

## State Management

Riverpod 2.x with the following patterns:

| Pattern | Use Case |
|---|---|
| `StreamProvider` | Live note list from DB |
| `StateProvider` | Simple UI state (selectedNoteId, searchQuery) |
| `AsyncNotifier` | CRUD operations with loading/error |
| `StateNotifier` | Theme mode persistence |

## Local Storage

**Drift** (SQLite wrapper) provides:
- Type-safe SQL queries with Dart API
- Stream-based reactive queries (`watchActiveNotes()`)
- Works on Android, iOS, macOS, Windows
- Web uses in-memory SQLite (WASM planned)

## Sync Strategy

1. **Guest mode**: All data stored locally only
2. **On connect**: Merge local + remote (last-write-wins by `updatedAt`)
3. **Online**: Sync on app foreground + every 5 minutes
4. **Offline**: Changes queue locally, flush when online
5. **Conflict resolution**: `updatedAt` timestamp wins; future: CRDTs

## UI Design System

### Accordion Fan Layout

```
┌──────────┬──┬──┬──┬──────────────────────┬──┬──┐
│          │  │  │  │                      │  │  │
│   Nav    │N₁│N₂│N₃│   Active Note Panel  │N₄│N₅│
│ Sidebar  │  │  │  │   (full width)       │  │  │
│ (64px)   │  │  │  │                      │  │  │
└──────────┴──┴──┴──┴──────────────────────┴──┴──┘
            collapsed strips (40px each)
```

- Collapsed notes = 40px vertical strips with rotated title
- Hover = expand to 52px with color glow
- Click = animate selected note to center panel
- Mobile = standard list → full screen editor

### Color System

| Token | Dark | Light |
|---|---|---|
| Background | `#0A0A0F` | `#F8F7F4` |
| Surface | `#141418` | `#FFFFFF` |
| Accent | `#7B6EF6` | `#7B6EF6` |
| Note Sage | `#B5C9B7` | `#B5C9B7` |
| Note Lavender | `#C4B5D6` | `#C4B5D6` |
| Note Peach | `#F0C5B3` | `#F0C5B3` |
| Note Sky | `#B3CDE8` | `#B3CDE8` |
| Note Butter | `#EDE4A6` | `#EDE4A6` |

## Branch Strategy

```
main          ← production-ready (protected)
develop       ← integration branch
feature/*     ← feature branches
fix/*         ← bug fixes
chore/*       ← maintenance
```

## Commit Convention

Conventional Commits (`type(scope): message`):

- `feat`: New feature
- `fix`: Bug fix
- `chore`: Maintenance, deps
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructure
- `test`: Tests

