# assets/fonts/

Bundled font files for the Shrimad Bhagavad Gita app (offline-first).

## Setup (One-Time)

Run from the project root:
```powershell
powershell -ExecutionPolicy Bypass -File scripts/download_fonts.ps1
```

Then uncomment the `fonts:` section in `pubspec.yaml` and run `flutter pub get`.

## Fonts Used

| File | Family | Weight | Usage |
|------|--------|--------|-------|
| `NotoSerif-Regular.ttf` | NotoSerif | 400 | English body text |
| `NotoSerif-Italic.ttf` | NotoSerif | 400 italic | Block quotes |
| `NotoSerif-Medium.ttf` | NotoSerif | 500 | Titles, headers |
| `NotoSerif-Bold.ttf` | NotoSerif | 700 | Display, emphasis |
| `NotoSerifDevanagari-Regular.ttf` | NotoSerifDevanagari | 400 | Sanskrit body |
| `NotoSerifDevanagari-Medium.ttf` | NotoSerifDevanagari | 500 | Sanskrit display |
| `NotoSerifDevanagari-Bold.ttf` | NotoSerifDevanagari | 700 | Sanskrit emphasis |
| `Inter-Regular.ttf` | Inter | 400 | UI labels |
| `Inter-Medium.ttf` | Inter | 500 | UI metadata |
| `Inter-SemiBold.ttf` | Inter | 600 | UI secondary labels |
| `Inter-Bold.ttf` | Inter | 700 | Button text |

## Why Bundled?

The app is offline-first. Fonts must be shipped with the app binary — no network
requests are made at runtime for typography.
