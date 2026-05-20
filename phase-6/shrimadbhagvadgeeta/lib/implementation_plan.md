# Sacred Editorial — Flutter Design System Implementation Plan

## 1. Color System: Surface Hierarchy & Tonal Layers

### Problem
Flutter's `ColorScheme` gives us `surface`, `surfaceContainerLow`, `surfaceContainerHigh`, etc. — which maps 1:1 to the spec. But we need **more control**: opacity overrides, gradient pairs, and glass-specific tokens that `ColorScheme` doesn't natively support.

### Decision: `ColorScheme` + Extension Class

We will use two constructs:

#### A. Standard `ColorScheme.dark()` — for Material widgets
Map the spec tokens directly:

| Spec Token | `ColorScheme` Property | Hex |
|---|---|---|
| `surface` | `surface` | `#131313` |
| `surface-container-lowest` | `surfaceContainerLowest` | `#141414` |
| `surface-container-low` | `surfaceContainerLow` | `#1C1B1B` |
| `surface-container` | `surfaceContainer` | `#201F1F` |
| `surface-container-high` | `surfaceContainerHigh` | `#2B2A2A` |
| `surface-container-highest` | `surfaceContainerHighest` | `#353534` |
| `primary` | `primary` | `#FFC08D` (Saffron Gold) |
| `primaryContainer` | `primaryContainer` | `#FF9933` |
| `onPrimaryContainer` | `onPrimaryContainer` | `#693800` |
| `secondary` | `secondary` | Muted Sage |
| `onSurface` | `onSurface` | `#E5E2E1` |
| `outlineVariant` | `outlineVariant` | For ghost borders |

This means all Material widgets (`Scaffold`, `Card`, `AppBar`) will *automatically* inherit the correct dark surface tones without per-widget overrides.

#### B. `AppSurfaceColors` Extension on `ThemeData`
For tokens that live outside Material's vocabulary:

```
extension AppSurfaceColors on ThemeData {
  Color get glassBackground => colorScheme.surfaceContainerHighest.withOpacity(0.6);
  LinearGradient get primaryGradient => LinearGradient(
    colors: [colorScheme.primary, colorScheme.primaryContainer],
  );
  Color get ghostBorder => colorScheme.outlineVariant.withOpacity(0.15);
}
```

**Why extension, not a separate class?** Because it's accessible anywhere via `Theme.of(context)` — no extra providers, no dependency injection, no import confusion.

#### C. Light Mode Strategy
Define a second `ColorScheme.light()` with inverted luminance but the **same hue family**. Saffron stays saffron; surfaces become warm off-whites (`#FAF7F2`, `#F0EDE8`, `#E8E4DF`). Light mode is a secondary concern; we build dark-first and layer light as a variant.

---

## 2. Typography: Noto Serif + Inter Dual System

### Problem
Flutter's `TextTheme` supports one font family by default. We need **two families** assigned to specific semantic roles: Noto Serif for "wisdom" content, Inter for "utility" text.

### Decision: Custom `TextTheme` with explicit `fontFamily` per style

#### Implementation Strategy

We will define a single `TextTheme` where each style explicitly sets its `fontFamily`:

| Spec Token | Maps to `TextTheme` | Font | Size | Weight | Line Height |
|---|---|---|---|---|---|
| `display-lg` | `displayLarge` | Noto Serif | 56px (3.5rem) | 400 | 1.15 |
| `headline-md` | `headlineMedium` | Noto Serif | 28px (1.75rem) | 500 | 1.3 |
| `title-sm` | `titleSmall` | Noto Serif | 16px (1rem) | 500 | 1.5 |
| `body-lg` | `bodyLarge` | Noto Serif | 16px (1rem) | 400 | 1.8 (generous) |
| `label-md` | `labelMedium` | Inter | 12px (0.75rem) | 500 | 1.4 |

**Rem-to-px conversion**: Flutter is pixel-based, not rem-based. We'll use `1rem = 16px` as the base, but wrap sizes in a `AppTypography` class to allow future scaling (e.g., accessibility font-size slider in settings).

```
class AppTypography {
  static const double baseRem = 16.0;
  static double rem(double value) => value * baseRem;
}
```

#### Why `google_fonts` package?
Noto Serif and Inter are both Google Fonts. The `google_fonts` package downloads them at runtime (with bundling option). We'll use `GoogleFonts.notoSerif()` and `GoogleFonts.inter()` to generate `TextStyle` objects, then assign them into the `TextTheme`.

#### Semantic Helper Methods
To enforce the "Serif = Wisdom, Sans = Utility" rule in the codebase:

```
// In a ThemeExtension or utility:
TextStyle wisdomDisplay(BuildContext ctx) => Theme.of(ctx).textTheme.displayLarge!;
TextStyle wisdomHeadline(BuildContext ctx) => Theme.of(ctx).textTheme.headlineMedium!;
TextStyle wisdomBody(BuildContext ctx) => Theme.of(ctx).textTheme.bodyLarge!;
TextStyle utilityLabel(BuildContext ctx) => Theme.of(ctx).textTheme.labelMedium!;
```

This makes code reviews trivial: if `utilityLabel` is on a verse, something is wrong.

---

## 3. Spacing & Layout Philosophy: Editorial, Asymmetric

### Problem
Most Flutter apps use symmetric padding (`EdgeInsets.all(16)`) and centered layouts. The spec demands **editorial placement** — intentional asymmetry, generous breathing room, staggered grids.

### Decision: `AppSpacing` constants + `EditorialLayout` widget

#### A. Spacing Scale

| Token | Value | Usage |
|---|---|---|
| `xs` | 4px | Icon-to-text gap |
| `sm` | 8px | Tight internal padding |
| `md` | 16px | Standard gutter |
| `lg` | 24px | Card internal padding (spec-mandated minimum) |
| `xl` | 32px | Section gaps |
| `xxl` | 48px | Hero section breathing room |
| `editorial` | 64px | Top-of-screen, verse display margins |

#### B. Asymmetric Padding Helper

```
class AppEdgeInsets {
  /// Editorial left-heavy padding (verse display pattern)
  static const verseContainer = EdgeInsets.only(
    left: 24, right: 32, top: 16, bottom: 24,
  );
  
  /// Right-aligned Sanskrit, left-aligned translation
  static const sanskritAlign = EdgeInsets.only(left: 48, right: 24);
  static const translationAlign = EdgeInsets.only(left: 24, right: 48);
}
```

#### C. Staggered / Overlapping Layouts
For verse displays where elements overlap (e.g., chapter number overlapping a card):
- Use `Stack` + `Positioned` with calculated offsets
- Wrap in an `EditorialOverlap` widget that parameterizes the overlap percentage

**Key principle**: Spacing is never "auto" or "fill". Every pixel of negative space is intentional.

---

## 4. The "No-Line" Rule: Enforcement Strategy

### Problem
Flutter's defaults add `Divider()`, `UnderlineInputBorder()`, and `Card` borders everywhere. We need to **systematically strip** these and replace them with surface-level separation.

### Decision: Theme-level overrides + Custom wrapper widgets

#### A. Theme-Level Stripping

In `ThemeData`, override:

```
dividerTheme: DividerThemeData(
  color: Colors.transparent,  // Kill all Divider widgets
  thickness: 0,
),
cardTheme: CardTheme(
  elevation: 0,              // No default shadow
  shape: RoundedRectangleBorder(
    side: BorderSide.none,    // No borders
    borderRadius: BorderRadius.circular(12), // md roundedness
  ),
  color: surfaceContainerHigh,
),
inputDecorationTheme: InputDecorationTheme(
  border: UnderlineInputBorder(...), // Underline-only, no box
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: outlineVariant.withOpacity(0.15)),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: primary, width: 2),
  ),
),
```

#### B. Surface Separation Widget

Instead of `Divider()`, create:

```dart
class SurfaceShift extends StatelessWidget {
  /// A zero-height widget that transitions background color
  /// from the parent's surface to the next tier.
  /// Use between sections instead of Divider.
}
```

#### C. `SectionContainer` Widget

A replacement for manual `Container` + `color` patterns:

```dart
class SectionContainer extends StatelessWidget {
  final SurfaceTier tier; // .low, .medium, .high, .highest
  final Widget child;
  // Automatically resolves the correct surface color from theme
}
```

This means developers write `SectionContainer(tier: .high, child: ...)` instead of manually picking hex colors.

---

## 5. Elevation System: Layer-Based, Not Shadow-First

### Problem
Material Design reaches for `elevation: 4` (which creates a drop shadow). The spec says: **change the background surface tier first**. Only use shadows for truly floating modals.

### Decision: Zero-elevation theme + `AmbientShadow` widget for exceptions

#### A. Default: No Shadows
Set `elevation: 0` on all Material component themes (`CardTheme`, `AppBarTheme`, `BottomSheetTheme`, etc.). Depth comes from **surface tier nesting**:

```
Scaffold (surface: #131313)
└── SectionContainer (surfaceContainerLow: #1C1B1B)
    └── VerseCard (surfaceContainerHigh: #2B2A2A)
        └── Content appears "lifted" without any shadow
```

#### B. Exception: The `AmbientShadow` Widget
For floating elements (modals, current-verse overlay):

```dart
class AmbientShadow extends StatelessWidget {
  final double blurRadius;  // 40-60px per spec
  final double opacity;     // 0.06 - 0.10
  final Color? tint;        // Defaults to onSurface darkened, NOT black
  final Widget child;
}
```

**Why tinted shadows?** The spec says use `onSurface` (#E5E2E1) darkened — not pure black. This creates a warmer, more natural shadow that feels like light passing through translucent paper, not a UI element casting a hard shadow.

---

## 6. Glassmorphism Elements

### Problem
Flutter has `BackdropFilter` but it's expensive. We need it for: floating nav, persistent player, modal overlays.

### Decision: `GlassContainer` composable widget

```dart
class GlassContainer extends StatelessWidget {
  final double blurSigma;     // 20-30 mapped to sigmaX/Y
  final double opacity;       // 0.6 default (surface-variant)
  final BorderRadius radius;
  final Widget child;
  
  // Internally:
  // ClipRRect → BackdropFilter → Container(color with opacity)
}
```

#### Performance guardrails:
- **Never nest** `GlassContainer` inside another `GlassContainer` (blur-on-blur is O(n²) GPU)
- **Limit to max 2** glass surfaces visible at once (bottom nav + one overlay)
- **Use `RepaintBoundary`** around glass widgets to isolate repaint cost
- On low-end devices: fall back to solid `surfaceContainerHighest` at 90% opacity (detect via `MediaQuery.of(context).highContrast` or frame budget monitoring)

#### Gradient on Glass
For hero CTAs or active states, layer the gradient **on top** of the glass:

```
GlassContainer(
  child: Container(
    decoration: BoxDecoration(
      gradient: theme.primaryGradient.withOpacity(0.15),
    ),
  ),
)
```

---

## 7. Enforcing Consistency

### A. File Structure

```
lib/core/theme/
├── app_theme.dart            // ThemeData construction (dark + light)
├── app_colors.dart           // ColorScheme definitions + extension
├── app_typography.dart       // TextTheme construction + semantic helpers
├── app_spacing.dart          // Spacing constants + EdgeInsets helpers
├── app_radius.dart           // Roundedness scale (sm, md, lg, full)
├── app_shadows.dart          // AmbientShadow config
└── widgets/
    ├── section_container.dart  // Surface-tier container
    ├── glass_container.dart    // Glassmorphism wrapper
    ├── ambient_shadow.dart     // Floating element shadow
    ├── ghost_border.dart       // 15% opacity border wrapper
    └── sutra_progress_bar.dart // 2px thin progress indicator
```

### B. Barrel Export

```dart
// lib/core/theme/theme.dart
export 'app_theme.dart';
export 'app_colors.dart';
export 'app_typography.dart';
export 'app_spacing.dart';
export 'app_radius.dart';
export 'widgets/section_container.dart';
export 'widgets/glass_container.dart';
// ...
```

Every feature imports `package:shrimadbhagvadgeeta/core/theme/theme.dart` — one import, full design system access.

### C. Animation Conventions

All transitions must be **300ms+** (meditative pace). Define standard curves:

```dart
class AppAnimations {
  static const Duration standard = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration meditative = Duration(milliseconds: 700);
  static const Curve defaultCurve = Curves.easeOutCubic; // slow-out
}
```

### D. Component Wrappers for Buttons

Three button constructors matching the spec:

| Spec | Flutter Widget |
|---|---|
| Primary (filled saffron) | `SacredButton.primary(label, onTap)` |
| Ghost (no fill, ghost border) | `SacredButton.ghost(label, onTap)` |
| Tertiary (text-only, sage) | `SacredButton.tertiary(label, onTap)` |

These enforce correct colors, text style (Inter/`labelMedium`), roundedness (`md`), and animation durations without any per-use configuration.

### E. Roundedness Constants

```dart
class AppRadius {
  static const double sm = 4.0;    // 0.25rem → tooltips, tags
  static const double md = 12.0;   // 0.75rem → buttons, verse cards
  static const double lg = 16.0;   // 1.0rem  → containers, bottom sheets
  static const double full = 9999; // Pills, chips
  
  static final smBorder = BorderRadius.circular(sm);
  static final mdBorder = BorderRadius.circular(md);
  static final lgBorder = BorderRadius.circular(lg);
  static final fullBorder = BorderRadius.circular(full);
}
```

---

## 8. Execution Order

Once approved, I will implement in this order:

1. **`app_colors.dart`** — `ColorScheme` + `AppSurfaceColors` extension
2. **`app_typography.dart`** — Dual-font `TextTheme` + semantic helpers
3. **`app_spacing.dart`** + **`app_radius.dart`** — Spacing scale + roundedness
4. **`app_shadows.dart`** — Ambient shadow config
5. **`app_theme.dart`** — Assemble `ThemeData.dark()` with all overrides
6. **Design system widgets** — `SectionContainer`, `GlassContainer`, `AmbientShadow`, `GhostBorder`, `SacredButton`, `SutraProgressBar`
7. **Barrel export** — Single import path
8. **`main.dart`** — Wire theme into app root

---

## Open Questions

> [!IMPORTANT]
> **Muted Sage color**: The spec references "Muted Sage" for `secondary` but doesn't provide a hex value. I recommend `#8B9A7B` (a warm, desaturated olive-sage). Does this match your vision, or do you have a specific hex?

> [!IMPORTANT]
> **Noto Serif variant**: Should we use `Noto Serif` (Latin) or `Noto Serif Devanagari` for Sanskrit text? Or both — Devanagari for श्लोक and Latin Noto Serif for transliterated text?

> [!NOTE]
> **Font bundling**: For a production app, I recommend bundling the font files in `assets/fonts/` rather than relying on runtime Google Fonts download. This ensures offline-first works for typography too. Shall I bundle them?
