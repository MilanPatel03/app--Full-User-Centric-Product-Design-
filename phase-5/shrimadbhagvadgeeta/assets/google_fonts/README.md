# Google Fonts — Offline Bundling Setup

This directory contains bundled font files for production offline-first font delivery.

## Fonts Used

| Font                    | Package API                            | Usage in App              |
|-------------------------|----------------------------------------|---------------------------|
| **Noto Serif**          | `GoogleFonts.notoSerif()`              | English wisdom content    |
| **Noto Serif Devanagari** | `GoogleFonts.notoSerifDevanagari()`  | Sanskrit shlok text       |
| **Inter**               | `GoogleFonts.inter()`                  | UI utility / labels       |

## One-Time Setup for Production

### Step 1 — Download fonts
From [fonts.google.com](https://fonts.google.com), download:
- [Inter](https://fonts.google.com/specimen/Inter)
- [Noto Serif](https://fonts.google.com/specimen/Noto+Serif)
- [Noto Serif Devanagari](https://fonts.google.com/specimen/Noto+Serif+Devanagari)

### Step 2 — Place files here
The `google_fonts` package looks for files in `assets/google_fonts/` using
the exact filename it would download from the network. You can discover the
expected filename by adding a temporary print:

```dart
print(GoogleFonts.notoSerif().fontFamily);
```

Typically files are named like: `NotoSerif-Regular.ttf`, `Inter-Medium.ttf`, etc.

### Step 3 — Enable offline-only mode
In `lib/main.dart`, inside `_initializeDependencies()`, uncomment:

```dart
GoogleFonts.config.allowRuntimeFetching = false;
```

### Step 4 — Verify pubspec.yaml
Confirm this directory is declared in assets:

```yaml
assets:
  - assets/google_fonts/
```

## Development Note

During development, fonts are **downloaded on first launch and cached locally**.
This is acceptable for development. For production distribution, complete the
steps above to eliminate all network dependencies.
