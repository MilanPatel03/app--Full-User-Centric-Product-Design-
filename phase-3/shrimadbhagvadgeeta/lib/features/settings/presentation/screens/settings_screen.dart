import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/settings/settings_provider.dart';
import '../../../../core/settings/settings_state.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/editorial_layout.dart';
import '../../../../core/theme/widgets/section_container.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SettingsScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Full editorial Settings screen, pushed from anywhere (no bottom nav).
///
/// Mirrors the preference controls in ProfileScreen but in a standalone
/// context. Users can reach it from the Profile tab's settings icon.
///
/// ## Sections
/// - Appearance (Theme: Dark / Light / System)
/// - Reading (Font size stepper, transliteration placeholder)
/// - About
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return EditorialLayout(
      leading: _BackButton(),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SettingsHeader(),
          ),

          // ── APPEARANCE section ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionLabel(
              'APPEARANCE',
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _AppearanceCard(currentMode: settings.themeMode),
            ),
          ),

          // ── READING section ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionLabel(
              'READING',
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _ReadingCard(currentScale: settings.fontScale),
            ),
          ),

          // ── ABOUT section ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionLabel(
              'ABOUT',
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _AboutCard(),
            ),
          ),

          // ── Bottom breathing room ─────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.editorial),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'विन्यास',
            style: AppTypography.sanskritDisplay.copyWith(
              color: scheme.onSurface,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Settings',
            style: AppTypography.headlineMedium.copyWith(
              color: scheme.onSurface,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Appearance card
// ─────────────────────────────────────────────────────────────────────────────

class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard({required this.currentMode});
  final ThemeMode currentMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final modes = [
      (
        mode: ThemeMode.dark,
        icon: Icons.dark_mode_rounded,
        label: 'Dark Sanctuary',
      ),
      (
        mode: ThemeMode.light,
        icon: Icons.light_mode_rounded,
        label: 'Light Manuscript',
      ),
      (
        mode: ThemeMode.system,
        icon: Icons.brightness_auto_rounded,
        label: 'Follow System',
      ),
    ];

    return SectionContainer(
      tier: SurfaceTier.low,
      borderRadius: AppRadius.lgBorder,
      child: Column(
        children: modes.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == modes.length - 1;
          final isCurrent = currentMode == item.mode;

          return Column(
            children: [
              GestureDetector(
                onTap: () => ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(item.mode),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: AppAnimations.quick,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 18,
                        color: isCurrent
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isCurrent
                                ? scheme.primary
                                : scheme.onSurface,
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: AppAnimations.quick,
                        opacity: isCurrent ? 1.0 : 0.0,
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  color: scheme.outlineVariant.withValues(alpha: 0.08),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reading card
// ─────────────────────────────────────────────────────────────────────────────

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.currentScale});
  final double currentScale;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      tier: SurfaceTier.low,
      borderRadius: AppRadius.lgBorder,
      child: _FontSizeRow(currentScale: currentScale),
    );
  }
}

/// Four-step text size stepper (matches ProfileScreen implementation).
class _FontSizeRow extends ConsumerWidget {
  const _FontSizeRow({required this.currentScale});
  final double currentScale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_size_rounded,
            size: 18,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Reading Text Size',
            style: AppTypography.bodyMedium.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const Spacer(),
          _FontScaleStepper(currentScale: currentScale),
        ],
      ),
    );
  }
}

class _FontScaleStepper extends ConsumerWidget {
  const _FontScaleStepper({required this.currentScale});
  final double currentScale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: SettingsState.fontScaleSteps.asMap().entries.map((entry) {
        final idx = entry.key;
        final step = entry.value;
        final isActive = (currentScale - step.value).abs() < 0.01;
        final displaySize = [11.0, 13.0, 15.0, 18.0][idx];

        return GestureDetector(
          onTap: () =>
              ref.read(settingsProvider.notifier).setFontScale(step.value),
          child: AnimatedContainer(
            duration: AppAnimations.quick,
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? scheme.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: AppRadius.smBorder,
              border: Border.all(
                color: isActive
                    ? scheme.primary.withValues(alpha: 0.5)
                    : scheme.outlineVariant.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                step.label,
                style: TextStyle(
                  fontFamily: 'NotoSerif',
                  fontSize: displaySize,
                  color:
                      isActive ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// About card
// ─────────────────────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SectionContainer(
      tier: SurfaceTier.low,
      borderRadius: AppRadius.lgBorder,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shrimad Bhagavad Gita',
            style: AppTypography.titleSmall.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'श्रीमद् भगवद्गीता',
            style: AppTypography.sanskritSmall.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Version 1.0.0\n18 Chapters · 700 Verses',
            style: AppTypography.caption.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.3,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.padding});
  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: scheme.secondary,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.pop(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}
