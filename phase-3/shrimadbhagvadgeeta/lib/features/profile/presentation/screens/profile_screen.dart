import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/settings/settings_provider.dart';
import '../../../../core/settings/settings_state.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../../../core/theme/widgets/sutra_progress_bar.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../bookmarks/presentation/providers/bookmarks_state_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfileScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Sacred Editorial Profile — matches the "The Sacred Soul" design.
///
/// Sections:
///   - Avatar + name + role subtitle
///   - Stats row (streak / verses read / verses bookmarked)
///   - Spiritual Progress card
///   - PREFERENCES section (Theme + Font Size + Account)
///   - Sign Out
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final bookmarkCount = ref.watch(bookmarksStreamProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header bar ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileAppBar(),
          ),

          // ── Avatar + name ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHero(
              email: authUser?.email ?? '',
            ),
          ),

          // ── Stats row ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: _StatsRow(bookmarkCount: bookmarkCount),
            ),
          ),

          // ── Spiritual progress ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: const _SpiritualProgressCard(),
            ),
          ),

          // ── Preferences ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0,
              ),
              child: _SectionLabel('PREFERENCES'),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: _PreferencesCard(settings: settings),
            ),
          ),

          // ── Sign out ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0,
              ),
              child: _SignOutButton(),
            ),
          ),

          // ── Bottom breathing room ──────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.editorial),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0,
        ),
        child: Row(
          children: [
            Text(
              'The Sacred Soul',
              style: AppTypography.titleLarge.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.settings_outlined,
              size: 22,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero section
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.email});

  final String email;

  /// Derive a display name from the email address.
  /// "arjun.sharma@gmail.com" → "Arjun Sharma"
  String get _displayName {
    if (email.isEmpty) return 'Seeker';
    final local = email.split('@').first;
    return local
        .split(RegExp(r'[._\-]'))
        .map((w) => w.isEmpty
        ? ''
        : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .where((w) => w.isNotEmpty)
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md,
      ),
      child: Column(
        children: [
          // Avatar circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHighest,
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'S',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 32,
                  color: scheme.primary,
                  height: 1.0,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            _displayName,
            style: AppTypography.headlineSmall.copyWith(
              color: scheme.onSurface,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            'SEEKER OF WISDOM',
            style: AppTypography.caption.copyWith(
              color: scheme.secondary,
              letterSpacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.bookmarkCount});

  final int bookmarkCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCell(value: '—', label: 'DAY STREAK'),
        _StatDivider(),
        _StatCell(value: '$bookmarkCount', label: 'VERSES SAVED'),
        _StatDivider(),
        _StatCell(value: '—', label: 'MIN READ'),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: SectionContainer(
        tier: SurfaceTier.low,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        borderRadius: AppRadius.mdBorder,
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headlineSmall.copyWith(
                color: scheme.primary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: scheme.secondary,
                letterSpacing: 1.2,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: AppSpacing.xs);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spiritual progress card
// ─────────────────────────────────────────────────────────────────────────────

class _SpiritualProgressCard extends StatelessWidget {
  const _SpiritualProgressCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SectionContainer(
      tier: SurfaceTier.low,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadius.mdBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Spiritual Progress',
                style: AppTypography.titleSmall.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '—%',
                style: AppTypography.headlineSmall.copyWith(
                  color: scheme.primary,
                  fontSize: 20,
                ),
              ),
              Text(
                '  GITA',
                style: AppTypography.caption.copyWith(
                  color: scheme.secondary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Begin reading to track your journey',
            style: AppTypography.caption.copyWith(
              color: scheme.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SutraProgressBar(progress: 0.0),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INTRO',
                style: AppTypography.caption.copyWith(
                  color: scheme.secondary,
                  letterSpacing: 1.5,
                  fontSize: 9,
                ),
              ),
              Text(
                'ENLIGHTENMENT',
                style: AppTypography.caption.copyWith(
                  color: scheme.secondary,
                  letterSpacing: 1.5,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preferences card
// ─────────────────────────────────────────────────────────────────────────────

class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard({required this.settings});

  final SettingsState settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionContainer(
      tier: SurfaceTier.low,
      borderRadius: AppRadius.mdBorder,
      child: Column(
        children: [
          // Theme row
          _ThemeRow(currentMode: settings.themeMode),
          _PrefDivider(),
          // Font size row
          _FontSizeRow(currentScale: settings.fontScale),
        ],
      ),
    );
  }
}

class _PrefDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      color: scheme.outlineVariant.withValues(alpha: 0.08),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme preference row
// ─────────────────────────────────────────────────────────────────────────────

class _ThemeRow extends ConsumerWidget {
  const _ThemeRow({required this.currentMode});

  final ThemeMode currentMode;

  String get _label => switch (currentMode) {
    ThemeMode.dark => 'Dark Sanctuary',
    ThemeMode.light => 'Light Manuscript',
    ThemeMode.system => 'System',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return _PrefRow(
      icon: Icons.dark_mode_outlined,
      title: 'Theme',
      trailing: GestureDetector(
        onTap: () => _showThemePicker(context, ref),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label,
              style: AppTypography.caption.copyWith(
                color: scheme.secondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: scheme.secondary,
            ),
          ],
        ),
      ),
      onTap: () => _showThemePicker(context, ref),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: Consumer(
          builder: (ctx, r, __) => Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadius.lgBorder,
            ),
            padding: AppEdgeInsets.bottomSheet,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: AppTypography.titleLarge.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ...ThemeMode.values.map((mode) {
                  final label = switch (mode) {
                    ThemeMode.dark => 'Dark Sanctuary',
                    ThemeMode.light => 'Light Manuscript',
                    ThemeMode.system => 'Follow System',
                  };
                  final icon = switch (mode) {
                    ThemeMode.dark => Icons.dark_mode_rounded,
                    ThemeMode.light => Icons.light_mode_rounded,
                    ThemeMode.system => Icons.brightness_auto_rounded,
                  };
                  final isCurrent = r.watch(themeModeProvider) == mode;

                  return GestureDetector(
                    onTap: () {
                      r.read(settingsProvider.notifier).setThemeMode(mode);
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                        horizontal: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 20,
                            color: isCurrent
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            label,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isCurrent
                                  ? scheme.primary
                                  : scheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          if (isCurrent)
                            Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: scheme.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Font size preference row
// ─────────────────────────────────────────────────────────────────────────────

class _FontSizeRow extends ConsumerWidget {
  const _FontSizeRow({required this.currentScale});

  final double currentScale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PrefRow(
      icon: Icons.format_size_rounded,
      title: 'Reading Text Size',
      trailing: _FontScaleStepper(currentScale: currentScale),
    );
  }
}

/// Four-step text size stepper shown inline in the preferences row.
/// Labels: S · A · A · A (increasing size, matching iOS-style text size pickers).
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
        // Font sizes for the four steps: 11, 13, 15, 18
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
                  color: isActive ? scheme.primary : scheme.onSurfaceVariant,
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
// Reusable preference row
// ─────────────────────────────────────────────────────────────────────────────

class _PrefRow extends StatelessWidget {
  const _PrefRow({
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: scheme.onSurface,
              ),
            ),
            const Spacer(),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: AppTypography.caption.copyWith(
        color: scheme.secondary,
        letterSpacing: 2.5,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign out button
// ─────────────────────────────────────────────────────────────────────────────

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isLoading = ref.watch(authActionsProvider).isLoading;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () => ref.read(authActionsProvider.notifier).logout(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: isLoading
              ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: scheme.error,
            ),
          )
              : Text(
            'SIGN OUT',
            style: AppTypography.caption.copyWith(
              color: scheme.error,
              letterSpacing: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}