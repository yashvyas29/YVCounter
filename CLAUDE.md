# CLAUDE.md

**Purpose**: AI-optimized execution guide for Claude Code agents working with the YVCounter (YVMalaJapCounter) Flutter codebase

---

## CRITICAL RULES (Check Every Task)

| Rule | Trigger | Action |
|------|---------|--------|
| **Check Guides First** | ANY task/prompt | ALWAYS check relevant guides BEFORE searching codebase |
| **Testing** | User says "test", "write tests", "run tests" | ONLY then work on tests |
| **Git Ops** | User says "commit", "push", "PR", "branch" | ONLY then do git operations |
| **Flutter SDK** | ANY `flutter` or `dart` command | Ensure Flutter 3.41.4 is active (`flutter --version`) |
| **Shell** | ANY shell command | ONLY bash/zsh syntax (macOS) |

**Recovery**: If stuck → Check [Troubleshooting](#troubleshooting)

---

## GUIDE IMPORTS

| Category | Guide Path | Purpose |
|----------|------------|---------|
| Architecture | .codemie/guides/architecture/architecture.md | Feature-folder structure, Provider pattern, component responsibilities |
| Data & Database | .codemie/guides/data/data-patterns.md | SQLite (sqflite), SharedPreferences, JSON serialization patterns |
| Development | .codemie/guides/development/development-practices.md | Provider/ChangeNotifier, l10n, state split, async, logging |
| Integrations | .codemie/guides/integrations/google-drive.md | Google Sign-In + Drive API backup/restore |

---

## TASK CLASSIFIER

**Analyze request intent → Match category → Load appropriate guides**

| Category | User Intent / Purpose | Example Requests | P0 Guide | P1 Guide |
|----------|----------------------|------------------|----------|----------|
| **Architecture** | Structure decisions, where to add new features | "Where should I add X?", "How is the app structured?" | .codemie/guides/architecture/architecture.md | - |
| **Data & Database** | Persistence, queries, new models, storage | "Save X to database", "Add new setting", "Read mala history" | .codemie/guides/data/data-patterns.md | - |
| **Development** | Code patterns, state, l10n, style, async | "Add new screen", "Add localized string", "Handle error in widget" | .codemie/guides/development/development-practices.md | .codemie/guides/architecture/architecture.md |
| **Integrations** | Google Drive backup/restore, Google Sign-In | "Add backup", "Fix sign-in", "Upload to Drive" | .codemie/guides/integrations/google-drive.md | - |

### Intent Detection

```
USER REQUEST
    ├─> What is the PRIMARY deliverable? → Primary Category (load P0)
    ├─> What standards must be followed? → Secondary Categories (load P0s)
    └─> How many files affected? → Complexity (1-2: Simple, 3-5: Medium, 6+: High)
```

### Complexity Guide

| Level | Indicators | Action |
|-------|------------|--------|
| **Simple** | 1-2 files, clear pattern | P0 guide if unsure |
| **Medium** | 3-5 files, standard scope | Load P0 guides |
| **High** | 6+ files, architectural impact | All P0+P1 guides, consider planning mode |

---

## EXECUTION WORKFLOW

```
START
  ├─> STEP 1: Parse Request
  │   └─ Match intent to Category → Assess complexity
  │
  ├─> STEP 2: Load Guides
  │   └─ Load P0 guides → Confidence < 80%? → Load P1 or ask user
  │
  ├─> STEP 3: Execute
  │   └─ Apply patterns from guides → Follow Critical Rules
  │
  └─> STEP 4: Validate & Deliver
      └─ Run checklist → All pass? → Deliver
```

### Pre-Delivery Checklist

- [ ] Meets user's request requirements?
- [ ] Follows patterns from loaded guides?
- [ ] Critical Rules followed?
- [ ] No hardcoded secrets or credentials?
- [ ] `debugPrint` used instead of `print`?
- [ ] New strings added to l10n ARB files if user-visible?

---

## COMMANDS

| Task | Command | Notes |
|------|---------|-------|
| **Setup** | `flutter pub get` | After cloning or pubspec changes |
| **Run Dev** | `flutter run` | Requires connected device or emulator |
| **Analyze** | `flutter analyze` | Lint check — must pass before commit |
| **Format** | `dart format lib/` | Auto-formats all Dart files |
| **Test** | `flutter test` | ONLY when user requests |
| **Build Android** | `flutter build apk` | Release APK |
| **Build iOS** | `flutter build ios` | Requires macOS + Xcode |
| **Gen l10n** | `flutter pub get` | Triggered by `generate: true` in pubspec |

---

## PROJECT CONTEXT

### Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Language | Dart | 3.11.1+ |
| Framework | Flutter | 3.41.4 |
| State Management | Provider + ChangeNotifier | 6.1.5+ |
| Local DB | sqflite (SQLite) | 2.4.2 |
| Key-Value Store | shared_preferences | 2.5.5 |
| Cloud Backup | Google Drive API | googleapis 16.0.0 |
| Auth | Google Sign-In | 7.2.0 |
| Localization | Flutter l10n (ARB) | built-in |
| Linting | flutter_lints | 6.0.0 |

### Project Structure

```
lib/
├── mala_japs/          # Main counter feature (home screen)
├── family_members/     # Family list and member detail pages
├── famity_tree/        # Tree visualization + string utilities
│   ├── pages/          # Tree CRUD pages
│   └── tools/          # string_extension.dart
├── settings/           # App settings screen
├── data_model/         # Data classes + ChangeNotifier models
├── common/             # Shared services (DB, Drive, file I/O)
├── l10n/               # ARB localization files (EN + HI)
├── resources/          # Bundled JSON family data assets
├── generated/          # server_client_id.dart (do not edit)
└── main.dart           # Entry point, Provider setup
.codemie/guides/        # Architecture and pattern guides
.github/workflows/      # CI (flutter.yml)
```

### Key Integrations

| Integration | Purpose | Guide |
|-------------|---------|-------|
| Google Drive API | Cloud backup/restore of mala data | .codemie/guides/integrations/google-drive.md |
| Google Sign-In | OAuth authentication for Drive | .codemie/guides/integrations/google-drive.md |

---

## TROUBLESHOOTING

| Symptom | Cause | Solution |
|---------|-------|----------|
| `flutter analyze` fails | Lint errors | Fix reported issues; check `analysis_options.yaml` |
| `flutter pub get` fails | Dependency conflict or network | Check pubspec.yaml versions; try `flutter pub upgrade` |
| Google Sign-In fails | Missing/wrong server client ID | Check `lib/generated/server_client_id.dart`; pass `--dart-define=SERVER_CLIENT_ID=...` |
| SQLite errors on fresh install | Table not yet created | `DBProvider.createTable(name)` must be called before insert |
| l10n strings not found | Generated files stale | Run `flutter pub get` with `generate: true` in pubspec |
| Build fails on iOS | CocoaPods out of sync | Run `pod install` in `ios/` directory |

---

## REMEMBER

### Workflow
1. **Parse** → Match intent to Category (Task Classifier)
2. **Load** → Read P0 guides for matched categories
3. **Check** → Confidence ≥ 80%? No → load more or ask user
4. **Execute** → Apply patterns from guides
5. **Validate** → Checklist must pass
6. **Deliver**

### When to Ask User
- Ambiguous requirements
- Low confidence after reading guides
- Missing information (e.g., which family to operate on)
- Unsure if policy applies
