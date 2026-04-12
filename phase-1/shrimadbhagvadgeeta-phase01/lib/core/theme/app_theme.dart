import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';
import 'app_radius.dart';
import 'app_animations.dart';

/// Assembles the complete [ThemeData] for the Sacred Editorial design system.
///
/// Usage in MaterialApp:
///   theme: AppTheme.light()
///   darkTheme: AppTheme.dark()
///   themeMode: ThemeMode.dark
abstract final class AppTheme {
  static ThemeData dark() => _build(scheme: buildDarkColorScheme());
  static ThemeData light() => _build(scheme: buildLightColorScheme());

  static ThemeData _build({required ColorScheme scheme}) {
    final isDark = scheme.brightness == Brightness.dark;
    final textTheme = AppTypography.buildTextTheme(
      primaryColor: scheme.onSurface,
      mutedColor: scheme.onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,

      // ── AppBar: editorial left-aligned, no elevation ───────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
        actionsIconTheme: IconThemeData(color: scheme.onSurface, size: 24),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent),
      ),

      // ── No-Line Rule: kill all dividers ───────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        thickness: 0,
        space: 0,
      ),
      dividerColor: Colors.transparent,

      // ── Cards: surface-based depth, zero elevation ────────────────────
      cardTheme: CardTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        color: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ── Input: underline-only, no boxed borders ───────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        labelStyle:
            AppTypography.labelMedium.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: AppTypography.labelMedium
            .copyWith(color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
        errorStyle: AppTypography.caption.copyWith(color: scheme.error),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        floatingLabelStyle:
            AppTypography.labelMedium.copyWith(color: scheme.primary),
      ),

      // ── Buttons: theme defaults (use SacredButton widget for spec) ─────
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((s) {
            if (s.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: 0.12);
            }
            if (s.contains(WidgetState.pressed)) {
              return scheme.primaryContainer.withValues(alpha: 0.85);
            }
            return scheme.primaryContainer;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((s) {
            if (s.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: 0.38);
            }
            return scheme.onPrimaryContainer;
          }),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          textStyle: WidgetStateProperty.all(AppTypography.labelLarge),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          ),
          animationDuration: AppAnimations.standard,
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((s) {
            if (s.contains(WidgetState.pressed)) {
              return AppColors.surfaceBright.withValues(alpha: 0.08);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.all(scheme.onSurface),
          side: WidgetStateProperty.all(
            BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.15)),
          ),
          textStyle: WidgetStateProperty.all(AppTypography.labelLarge),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
          ),
          animationDuration: AppAnimations.standard,
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
          ),
          elevation: WidgetStateProperty.all(0),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(scheme.secondary),
          textStyle: WidgetStateProperty.all(AppTypography.labelLarge),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          animationDuration: AppAnimations.standard,
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
          ),
        ),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.topOnly),
        dragHandleColor: scheme.outlineVariant.withValues(alpha: 0.5),
      ),

      // ── Navigation Bar ────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer.withValues(alpha: 0.25),
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: AppRadius.fullBorder,
        ),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.all(
          AppTypography.caption.copyWith(color: scheme.onSurface),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((s) {
          if (s.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary, size: 24);
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
        }),
      ),

      // ── List Tile ─────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        titleTextStyle:
            AppTypography.bodyMedium.copyWith(color: scheme.onSurface),
        subtitleTextStyle:
            AppTypography.caption.copyWith(color: scheme.onSurfaceVariant),
      ),

      // ── Progress Indicator ────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.outlineVariant.withValues(alpha: 0.3),
        linearMinHeight: 2.0,
        circularTrackColor: scheme.outlineVariant.withValues(alpha: 0.15),
      ),

      // ── Chip ─────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primaryContainer.withValues(alpha: 0.3),
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.fullBorder),
        labelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 16),
      ),

      // ── Snack Bar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle:
            AppTypography.labelMedium.copyWith(color: scheme.onSurface),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // ── Dialog ────────────────────────────────────────────────────────
      dialogTheme: DialogTheme(
        backgroundColor: scheme.surfaceContainerHigh,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
        titleTextStyle:
            AppTypography.headlineSmall.copyWith(color: scheme.onSurface),
        contentTextStyle:
            AppTypography.bodyMedium.copyWith(color: scheme.onSurfaceVariant),
      ),

      // ── Switch ────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((s) {
          if (s.contains(WidgetState.selected)) return scheme.primary;
          return scheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((s) {
          if (s.contains(WidgetState.selected)) {
            return scheme.primaryContainer.withValues(alpha: 0.5);
          }
          return scheme.onSurface.withValues(alpha: 0.12);
        }),
      ),

      // ── Slider ────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.outlineVariant.withValues(alpha: 0.3),
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        trackHeight: 2.0,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),

      // ── Icons ─────────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      primaryIconTheme: IconThemeData(color: scheme.primary, size: 24),

      // ── Page Transitions: Cupertino slide for meditative feel ─────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
