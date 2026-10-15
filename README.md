# NoteEase 🗒️

> A minimal, beautiful cross-platform notes app with multi-provider sync.

[![Flutter](https://img.shields.io/badge/Flutter-3.47.7-blue?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-fvrvz%2Fnotease-black?logo=github)](https://github.com/fvrvz/notease)

---

## Features

- ✍️ **Rich note editor** — markdown-ready content with color coding
- 🎨 **Accordion fan layout** — notes as collapsible vertical strips; click to expand
- 🌗 **Dark/Light mode** — dark-first design with glassmorphism accents
- 📱 **Cross-platform** — Mac, Windows, Android, iOS, Web from one codebase
- 🔒 **Guest mode** — start taking notes without any account
- ☁️ **Multi-provider sync** — connect Google Drive, OneDrive, Dropbox, or iCloud
- 📌 **Pin & Archive** — organize notes your way
- 🔍 **Search** — instant full-text note search

---

## Screenshots

> _Coming soon_

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.47.7
- Dart SDK ≥ 3.5.0

### Install & Run

```bash
git clone https://github.com/fvrvz/notease.git
cd notease
flutter pub get
flutter run
```

### Platform targets

```bash
flutter run -d macos      # macOS
flutter run -d windows    # Windows
flutter run -d chrome     # Web
flutter run -d <device>   # Android / iOS device
```

---

## Architecture

NoteEase follows **Clean Architecture** with feature-first folder structure:

```
lib/
├── core/           # Theme, routing, constants, utilities
├── domain/         # Models (freezed), repository interfaces
├── data/           # Drift DB, sync adapters, repo implementations
└── features/       # UI features (notes, auth, settings)
    ├── notes/
    ├── auth/
    └── settings/
```

State management: **Riverpod 2.x** with `AsyncNotifier` and reactive streams.

---

## Sync Providers

| Provider | Status |
|---|---|
| Google Drive | 🔜 Planned |
| Microsoft OneDrive | 🔜 Planned |
| Dropbox | 🔜 Planned |
| iCloud | 🔜 Planned |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

MIT © [fvrvz](https://github.com/fvrvz)

