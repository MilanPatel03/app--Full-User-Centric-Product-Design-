/// Sacred Editorial Design System — Barrel Export
///
/// Single import for all theme tokens and design system widgets:
///
/// ```dart
/// import 'package:shrimadbhagvadgeeta/core/theme/theme.dart';
/// ```
///
/// Provides access to:
/// - [AppColors], [buildDarkColorScheme], [buildLightColorScheme]
/// - [AppTypography], [TypographyContext] extension
/// - [AppSpacing], [AppEdgeInsets]
/// - [AppRadius]
/// - [AppAnimations]
/// - [AppShadows]
/// - [AppTheme] (ThemeData builders)
/// - [SectionContainer], [SurfaceTier]
/// - [GlassContainer]
/// - [AmbientShadow]
/// - [GhostBorder]
/// - [SacredButton], [SacredButtonVariant]
/// - [SutraProgressBar]
library;

export 'app_animations.dart';
export 'app_colors.dart';
export 'app_radius.dart';
export 'app_shadows.dart';
export 'app_spacing.dart';
export 'app_theme.dart';
export 'app_typography.dart';
export 'widgets/ambient_shadow.dart';
export 'widgets/editorial_header.dart';
export 'widgets/editorial_layout.dart';
export 'widgets/ghost_border.dart';
export 'widgets/glass_container.dart';
export 'widgets/sacred_button.dart';
export 'widgets/section_container.dart';
export 'widgets/sutra_progress_bar.dart';
