import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notease/domain/models/note.dart';

class LocalStorageService {
  static const String _notesKey = 'notease_notes_v3';
  final StreamController<List<Note>> _notesController =
      StreamController<List<Note>>.broadcast();

  List<Note> _memoryNotes = [];
  bool _initialized = false;

  LocalStorageService() {
    _init();
  }

  Future<void> _init() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(_notesKey);
        if (raw != null) {
          final List decoded = jsonDecode(raw);
          _memoryNotes = decoded.map((e) => Note.fromJson(e)).toList();
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(p.join(dir.path, 'notes.json'));
        if (await file.exists()) {
          final raw = await file.readAsString();
          final List decoded = jsonDecode(raw);
          _memoryNotes = decoded.map((e) => Note.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('Error initializing local storage: $e');
    }

    // Default sample notes seeded with 50 rich notes
    if (_memoryNotes.isEmpty || _memoryNotes.length < 50) {
      _memoryNotes = _generate50SeedNotes();
      _save();
    }

    _initialized = true;
    _emit();
  }

  static List<Note> _generate50SeedNotes() {
    final now = DateTime.now();
    const colors = NoteColor.values;

    final titlesAndContents = [
      ('Welcome to NoteEase', '# Welcome to NoteEase\n\nA minimal, focused notes workspace.\n- [x] Accordion animated note strips\n- [x] Real-time inline Markdown formatting\n- [ ] Multi-provider cloud synchronization', ['intro', 'welcome']),
      ('Architecture & Tech Stack', '## Technology Stack\n\n- **Framework**: Flutter (AOT native compiled)\n- **State Management**: Riverpod 2.6+\n- **Storage**: Local persistence with offline-first design\n- **Target Platforms**: macOS, Windows, Android, iOS, Web', ['architecture', 'flutter']),
      ('Design Guidelines', '### Design Rules\n\n1. Flat surfaces with crisp 1px borders\n2. Decreased **6px** border radius\n3. Consistent text alignments across elements\n4. Strict adherence to zero drop shadows and zero gradients', ['design', 'ui']),
      ('Markdown Cheatsheet', '## Markdown Cheatsheet\n\nUse `# Header 1`, `## Header 2`, `### Header 3`.\nFormat text with **bold** or *italic*.\nInclude inline code like `var note = Note();`.\n> Important quote or callout block.\n- [ ] Unchecked checklist item\n- [x] Completed item', ['markdown', 'guide']),
      ('Meeting: Cloud Sync Strategy', '### Cloud Sync Options\n\nDiscussing integration adapters:\n- **Google Drive**: Storing notes JSON in appDataFolder\n- **iCloud Drive**: Seamless Apple ecosystem synchronization\n- **OneDrive / Dropbox**: File level bi-directional sync', ['meeting', 'sync']),
      ('Book Recommendations', '### Reading List\n\n- **Designing Data-Intensive Applications** - Martin Kleppmann\n- **Clean Architecture** - Robert C. Martin\n- **The Design of Everyday Things** - Don Norman\n- **Refactoring** - Martin Fowler', ['books', 'learning']),
      ('Weekly Sprint Goals', '### Sprint Tasks\n\n- [x] Animate note expansion and collapse\n- [x] Left-align active note container\n- [x] Real-time inline markdown parsing\n- [ ] Implement cloud sync credentials sheet\n- [ ] Export notes as .md bundle', ['sprint', 'scrum']),
      ('Product Roadmap', '## NoteEase Roadmap\n\n- **v1.0**: Core notes editor, accordion strip layout, guest local mode\n- **v1.1**: Google Drive & iCloud sync integration\n- **v1.2**: Tagging system and note linking', ['roadmap', 'product']),
      ('Code Snippets: Dart extensions', '### Useful Extensions\n\n```dart\nextension StringUtils on String {\n  bool get isBlank => trim().isEmpty;\n}\n```\nKeep utility functions small and testable.', ['dev', 'dart']),
      ('Quick Ideas & Brainstorming', '### Feature Ideas\n\n- Keyboard shortcuts: `Cmd+N` for new note, `Cmd+F` for search\n- Drag and drop reordering of note strips\n- Quick color switcher via keyboard numbers `1-7`', ['ideas', 'ux']),
      ('Impeller Rendering & Metal Backend', '### Graphics Pipeline\n\nImpeller provides deterministic frame pacing on iOS and macOS Metal.\n- Eliminates runtime shader compilation jank\n- Tessellates vector paths efficiently on GPU compute shaders', ['graphics', 'metal']),
      ('Grocery & Market Checklist', '### Weekly Supplies\n\n- [x] Organic oat milk\n- [x] Sourdough bread\n- [ ] Hass avocados\n- [ ] Honeycrisp apples\n- [ ] Colombian roast coffee beans', ['personal', 'shopping']),
      ('State Management with Riverpod 2.6', '### Why Riverpod?\n\n- Compile-time safety without `BuildContext` reliance\n- Auto-dispose unused providers seamlessly\n- Built-in support for asynchronous reactive streams', ['flutter', 'riverpod']),
      ('Rust vs Dart for Desktop Engines', '### Analysis Summary\n\nRust is blazing fast for low-level systems, but Flutter delivers unparalleled UI cross-platform maturity across macOS, Windows, Linux, iOS, Android, and Web.', ['rust', 'benchmark']),
      ('Database Schema & Offline Strategy', '### Local Storage Layer\n\n- Pure Dart models with zero-codegen JSON serialization\n- Atomic filesystem writes with temporary swap files\n- Real-time reactive broadcast stream for instant UI updates', ['database', 'storage']),
      ('Keychain & Biometric Encryption', '### Security Blueprint\n\n- Store cloud refresh tokens in macOS Keychain / Windows DPAPI\n- AES-GCM-256 for local note database encryption\n- Optional TouchID / FaceID app lock', ['security', 'encryption']),
      ('Keyboard Shortcuts Cheat Sheet', '### Global Hotkeys\n\n- `Cmd+N`: Create new note\n- `Cmd+F`: Focus search bar\n- `Cmd+P`: Pin/Unpin current note\n- `Cmd+Shift+P`: Toggle Markdown preview\n- `Cmd+Delete`: Delete note', ['productivity', 'shortcuts']),
      ('Responsive Breakpoints Specification', '### Layout Geometry\n\n- **Desktop** (> 768px): Accordion fans + left-aligned active note\n- **Tablet / Mobile** (< 768px): Vertical card feed with quick header bar', ['responsive', 'design']),
      ('Daily Standup: Monday Oct 19', '### Status Update\n\n- **Yesterday**: Fixed search bar vertical alignment and multi-attribute date filtering\n- **Today**: Implementing live WYSIWYG headers and 50-note horizontal scrolling\n- **Blockers**: None', ['standup', 'agile']),
      ('Quarterly OKRs & Key Milestones', '### Q4 Objectives\n\n1. **Objective**: Deliver a world-class cross-platform notes client\n   - *KR 1*: Sub-10ms note switching animation\n   - *KR 2*: 100% offline functionality without network crash\n   - *KR 3*: Zero-configuration guest onboarding', ['okr', 'management']),
      ('Performance Profiling on macOS', '### Instruments Profiler\n\n- Memory footprint: ~38MB RSS on startup\n- CPU utilization at idle: < 0.2%\n- Frame rate: Solid 120 FPS ProMotion on Apple Silicon M-series', ['performance', 'macos']),
      ('REST vs GraphQL vs gRPC', '### Protocol Comparison\n\n- **REST**: Simple, cacheable, ubiquitous for public APIs\n- **GraphQL**: Efficient querying, avoids over-fetching for mobile\n- **gRPC**: Low-latency binary protobuf for internal microservices', ['networking', 'api']),
      ('Docker Container Build Pipeline', '### Containerization\n\n```dockerfile\nFROM debian:bookworm-slim\nRUN apt-get update && apt-get install -y clang cmake\n```\nMultistage builds keep deployment artifacts lean.', ['devops', 'docker']),
      ('Kubernetes Cluster Architecture', '### Cluster Components\n\n- **Control Plane**: API server, etcd, scheduler\n- **Worker Nodes**: kubelet, containerd, kube-proxy\n- **Ingress**: Traefik with automatic TLS certs via Let\'s Encrypt', ['kubernetes', 'cloud']),
      ('GitHub Actions CI/CD Configuration', '### Pipeline Automation\n\n- Automated test runner on `main` and `develop`\n- Code formatting & static analysis checks (`flutter analyze`)\n- Multi-platform binary release artifact builds', ['ci', 'github']),
      ('TypeScript to Dart Equivalents', '### Type Systems\n\n- `type Foo = A | B` -> Dart sealed classes & pattern matching\n- `Record<string, T>` -> `Map<String, T>`\n- `Promise<T>` -> `Future<T>`\n- `async/await` syntax is virtually identical', ['typescript', 'dart']),
      ('WebAssembly & Flutter Web', '### WASM Compilation\n\n- Dart 3.5 compiles directly to WasmGC\n- Up to 2x faster startup and 3x smoother animation on Chrome & Firefox\n- Reduces payload size compared to standard JS compilation', ['wasm', 'web']),
      ('Engineering Podcasts List', '### Recommended Listening\n\n- **Software Engineering Daily**\n- **Changelog**: Interviews with open-source pioneers\n- **Frontend Happy Hour**: Web and mobile architecture discussions\n- **Syntax.fm**: Modern web development tooling', ['podcasts', 'learning']),
      ('Strength Training Routine', '### Weekly Split\n\n- **Day 1**: Squats, Romanian Deadlifts, Calves\n- **Day 2**: Bench Press, Overhead Press, Dips\n- **Day 3**: Pull-ups, Barbell Rows, Face Pulls\n- **Day 4**: Active recovery & 5km run', ['fitness', 'workout']),
      ('Specialty Coffee Brewing Guide', '### Pour-Over Technique (V60)\n\n- **Ratio**: 1:16 (15g coffee to 240g water)\n- **Water Temp**: 93°C (200°F)\n- **Bloom**: 45g water for 45 seconds\n- **Pour**: Gentle concentric circles finishing by 2:30', ['coffee', 'hobbies']),
      ('Travel Itinerary: Japan 2026', '### Tokyo & Kyoto Plan\n\n- **Day 1-3**: Shinjuku, Shibuya Sky, Akihabara\n- **Day 4-6**: Shinkansen to Kyoto, Fushimi Inari, Arashiyama Bamboo Grove\n- **Day 7**: Traditional tea ceremony & Gion district', ['travel', 'japan']),
      ('Personal Budget & Savings Plan', '### 50/30/20 Rule\n\n- **50% Needs**: Rent, utilities, groceries, healthcare\n- **30% Wants**: Dining out, gadgets, travel\n- **20% Savings**: Emergency fund & index investments', ['finance', 'budget']),
      ('Design System: Component Specs', '### Token Definitions\n\n- **Radii**: 6.0px strictly across all cards and buttons\n- **Borders**: 1.0px solid with muted contrast\n- **Transitions**: 200-300ms easeInOut curves', ['design-system', 'tokens']),
      ('System Design: Distributed Cache', '### Cache Design Questions\n\n- Eviction policies: LRU, LFU, FIFO\n- Cache-aside vs Write-through vs Write-behind\n- Consistent hashing for partitioned memcached nodes', ['system-design', 'interview']),
      ('Token Bucket Rate Limiting Algorithm', '### Implementation Logic\n\n```python\ncurrent_time = time.time()\ntokens += (current_time - last_time) * refill_rate\nif tokens >= 1:\n    tokens -= 1\n    return True\nreturn False\n```', ['algorithms', 'backend']),
      ('Event-Driven Architecture Patterns', '### Message Broker Highlights\n\n- Event sourcing for immutable audit logs\n- CQRS (Command Query Responsibility Segregation)\n- Dead-letter queues for unhandled exception retries', ['event-driven', 'kafka']),
      ('Redis Caching Patterns & TTLs', '### Cache Optimization\n\n- Always set TTLs to avoid memory leaks\n- Use Redis pipelining for batch read/write operations\n- Redis streams for lightweight messaging queues', ['redis', 'caching']),
      ('Linux Syscalls & OS Fundamentals', '### Key Syscalls\n\n- `fork()`, `execve()`, `waitpid()` for process management\n- `epoll()` for scalable asynchronous I/O polling\n- `mmap()` for zero-copy file access', ['linux', 'os']),
      ('Neovim Configuration Notes', '### Editor Setup\n\n- Package manager: `lazy.nvim`\n- LSP client: Built-in Neovim LSP with `mason.nvim`\n- Fuzzy finder: `telescope.nvim` with fzf native extension', ['tools', 'neovim']),
      ('Git Conventional Commits Standard', '### Format Specifications\n\n- `feat`: A new user-facing feature\n- `fix`: A bug fix\n- `docs`: Documentation updates\n- `refactor`: Code refactoring without behavior changes\n- `perf`: Performance improvements', ['git', 'conventions']),
      ('Branch Protection Policy Rules', '### Branch Strategy\n\n- `main`: Protected production branch, merge via PRs\n- `develop`: Development branch for staging changes\n- `feature/*`: Topic branches for new capabilities\n- `bugfix/*` & `hotfix/*`: Targeted fixes', ['git', 'devops']),
      ('Accessibility & WCAG AAA Guidelines', '### Visual Contrast\n\n- Text contrast ratio at least 7:1 for normal text\n- Avoid using color alone to convey critical state\n- High-visibility keyboard focus rings', ['a11y', 'standards']),
      ('Dart Streams & Reactive Programming', '### Stream Controllers\n\n- Single-subscription streams vs Broadcast streams\n- Handling backpressure and asynchronous transformations with `asyncMap`', ['dart', 'reactive']),
      ('Testing Strategy: Unit, Widget & Integration', '### Test Pyramid\n\n- 70% Unit tests for business logic & providers\n- 20% Widget tests for UI interactions and rendering\n- 10% End-to-end integration tests on real platform engines', ['testing', 'quality']),
      ('Error Handling & Crash Telemetry', '### Robust Catching\n\n- `runZonedGuarded` to intercept unhandled asynchronous errors\n- Friendly user notifications without crashing the rendering tree', ['errors', 'resilience']),
      ('Internationalization (i18n) Strategy', '### Localization Plan\n\n- Extract all UI strings into ARB files (`intl` package)\n- Support RTL layouts for Arabic and Hebrew\n- Format dates and currency according to system locale', ['i18n', 'localization']),
      ('Zero-Downtime Deployment Blueprints', '### Release Strategies\n\n- Blue-Green deployments with instant traffic switching\n- Canary deployments routing 5% traffic to test error rates\n- Automatic rollback on elevated 5xx error threshold', ['cloud', 'devops']),
      ('User Feedback & Feature Requests', '### Top User Requests\n\n- [x] Smooth ease-in-out expand/collapse animation\n- [x] Floating search results on the left\n- [x] Live WYSIWYG markdown support\n- [ ] Bi-directional note linking with `[[WikiLinks]]`', ['feedback', 'community']),
      ('NoteEase 2.0 Feature Planning', '### Version 2.0 Roadmap\n\n- Full offline-first peer-to-peer sync via WebRTC\n- End-to-end encrypted backup files\n- Canvas & visual diagram embeds\n- Multi-window support on macOS & Windows', ['release', 'v2']),
      ('Quotes & Philosophy', '### Mindset\n\n> "Simplicity is prerequisite for reliability."\n> — Edsger W. Dijkstra\n\n> "Make it work, make it right, make it fast."\n> — Kent Beck', ['quotes', 'philosophy']),
    ];

    final notes = <Note>[];
    for (int i = 0; i < titlesAndContents.length; i++) {
      final item = titlesAndContents[i];
      final color = colors[i % colors.length];
      final daysAgo = (i * 2) % 60;
      final hoursAgo = (i * 5) % 24;
      final created = now.subtract(Duration(days: daysAgo + 2, hours: hoursAgo));
      final updated = now.subtract(Duration(days: daysAgo, hours: hoursAgo));

      notes.add(Note(
        id: '${i + 1}',
        title: item.$1,
        content: item.$2,
        color: color,
        createdAt: created,
        updatedAt: updated,
        isPinned: i < 3,
        tags: item.$3,
      ));
    }

    return notes;
  }

  void _emit() {
    final active = _memoryNotes.where((n) => !n.isArchived).toList()
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
    _notesController.add(active);
  }

  Future<void> _save() async {
    try {
      final jsonString = jsonEncode(_memoryNotes.map((e) => e.toJson()).toList());
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_notesKey, jsonString);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(p.join(dir.path, 'notes.json'));
        await file.writeAsString(jsonString);
      }
    } catch (e) {
      debugPrint('Error saving notes to storage: $e');
    }
  }

  Stream<List<Note>> watchActiveNotes() async* {
    if (_initialized) {
      yield _memoryNotes.where((n) => !n.isArchived).toList()
        ..sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
    }
    yield* _notesController.stream;
  }

  Future<List<Note>> searchNotes(String query) async {
    final q = query.toLowerCase();
    return _memoryNotes.where((n) =>
        !n.isArchived &&
        (n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q))
    ).toList();
  }

  Future<Note?> getNoteById(String id) async {
    try {
      return _memoryNotes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNote(Note note) async {
    final index = _memoryNotes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _memoryNotes[index] = note;
    } else {
      _memoryNotes.insert(0, note);
    }
    await _save();
    _emit();
  }

  Future<void> deleteNote(String id) async {
    _memoryNotes.removeWhere((n) => n.id == id);
    await _save();
    _emit();
  }

  void dispose() {
    _notesController.close();
  }
}
