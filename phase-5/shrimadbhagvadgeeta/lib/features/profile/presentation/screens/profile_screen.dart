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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final bookmarkCount =
        ref.watch(bookmarksStreamProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _ProfileAppBar()),
          SliverToBoxAdapter(
            child: _ProfileHero(email: authUser?.email ?? ''),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: _StatsRow(bookmarkCount: bookmarkCount),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: const _SpiritualProgressCard(),
            ),
          ),
          // ── Collections horizontal scroll ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
              child: _SectionLabel('MY COLLECTIONS'),
            ),
          ),
          SliverToBoxAdapter(child: _CollectionsScroll()),
          // ── Milestones ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
              child: _SectionLabel('MILESTONES'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _MilestonesCard(),
            ),
          ),
          // ── Preferences ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
              child: _SectionLabel('PREFERENCES'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: _PreferencesCard(settings: settings),
            ),
          ),
          // ── Sign out ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
              child: _SignOutButton(),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.editorial)),
        ],
      ),
    );
  }
}

// ── App bar ────────────────────────────────────────────────────────────────

class _ProfileAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
        child: Row(
          children: [
            Text(
              'The Sacred Soul',
              style: AppTypography.titleLarge
                  .copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Icon(Icons.settings_outlined,
                size: 22, color: scheme.onSurface.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

// ── Hero section ───────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.email});
  final String email;

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
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHighest,
              border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Center(
              child: Text(
                _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'S',
                style: AppTypography.displayLarge.copyWith(
                    fontSize: 32, color: scheme.primary, height: 1.0),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(_displayName,
              style:
                  AppTypography.headlineSmall.copyWith(color: scheme.onSurface)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'SEEKER OF WISDOM',
            style: AppTypography.caption
                .copyWith(color: scheme.secondary, letterSpacing: 2.5),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.bookmarkCount});
  final int bookmarkCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCell(value: '—', label: 'DAY STREAK'),
        const SizedBox(width: AppSpacing.xs),
        _StatCell(value: '$bookmarkCount', label: 'VERSES READ'),
        const SizedBox(width: AppSpacing.xs),
        _StatCell(value: '—', label: 'MIN MEDITATED'),
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
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        borderRadius: AppRadius.mdBorder,
        child: Column(
          children: [
            Text(value,
                style: AppTypography.headlineSmall
                    .copyWith(color: scheme.primary, height: 1.0)),
            const SizedBox(height: 4),
            Text(label,
                style: AppTypography.caption.copyWith(
                    color: scheme.secondary, letterSpacing: 1.2, fontSize: 9),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Spiritual Progress card ────────────────────────────────────────────────

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
              Text('Spiritual Progress',
                  style: AppTypography.titleSmall
                      .copyWith(color: scheme.onSurface)),
              const Spacer(),
              Text('33%',
                  style: AppTypography.headlineSmall
                      .copyWith(color: scheme.primary, fontSize: 20)),
              Text('  GITA',
                  style: AppTypography.caption
                      .copyWith(color: scheme.secondary, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('6 of 18 chapters explored',
              style:
                  AppTypography.caption.copyWith(color: scheme.secondary)),
          const SizedBox(height: AppSpacing.lg),
          const SutraProgressBar(progress: 0.33),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('INTRO',
                  style: AppTypography.caption.copyWith(
                      color: scheme.secondary,
                      letterSpacing: 1.5,
                      fontSize: 9)),
              Text('ENLIGHTENMENT',
                  style: AppTypography.caption.copyWith(
                      color: scheme.secondary,
                      letterSpacing: 1.5,
                      fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Collections horizontal scroll ─────────────────────────────────────────

class _CollectionsScroll extends StatelessWidget {
  static const _items = [
    (label: 'Favorites', icon: Icons.favorite_border_rounded),
    (label: 'Daily\nSadhana', icon: Icons.wb_sunny_outlined),
    (label: 'Inner\nPeace', icon: Icons.self_improvement_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (ctx, i) {
          final item = _items[i];
          final scheme = Theme.of(ctx).colorScheme;
          return SectionContainer(
            tier: SurfaceTier.low,
            borderRadius: AppRadius.lgBorder,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 22, color: scheme.secondary),
                const SizedBox(height: AppSpacing.xs),
                Text(item.label,
                    style: AppTypography.caption.copyWith(
                        color: scheme.onSurface,
                        height: 1.3,
                        letterSpacing: 0.3),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Milestones card ────────────────────────────────────────────────────────

class _MilestonesCard extends StatelessWidget {
  static const _milestones = [
    (
      timeAgo: 'Today',
      title: 'First Chapter Complete',
      body: 'You finished Chapter 1 — Arjuna Vishada Yoga.',
    ),
    (
      timeAgo: '3 Days Ago',
      title: '7-Day Reading Streak',
      body: 'Consistency is the highest form of discipline.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      tier: SurfaceTier.low,
      borderRadius: AppRadius.mdBorder,
      child: Column(
        children: _milestones.asMap().entries.map((entry) {
          final m = entry.value;
          final isLast = entry.key == _milestones.length - 1;
          return _MilestoneRow(
            timeAgo: m.timeAgo,
            title: m.title,
            body: m.body,
            showDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.timeAgo,
    required this.title,
    required this.body,
    required this.showDivider,
  });

  final String timeAgo;
  final String title;
  final String body;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dot indicator
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(timeAgo,
                        style: AppTypography.caption.copyWith(
                            color: scheme.secondary, letterSpacing: 1.0)),
                    const SizedBox(height: 2),
                    Text(title,
                        style: AppTypography.titleSmall
                            .copyWith(color: scheme.onSurface)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(body,
                        style: AppTypography.bodyMedium.copyWith(
                            color: scheme.onSurfaceVariant, height: 1.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            color: scheme.outlineVariant.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}

// ── Preferences card ───────────────────────────────────────────────────────

class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard({required this.settings});
  final SettingsState settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return SectionContainer(
      tier: SurfaceTier.low,
      borderRadius: AppRadius.mdBorder,
      child: Column(
        children: [
          _ThemeRow(currentMode: settings.themeMode),
          _PrefDivider(),
          _FontSizeRow(currentScale: settings.fontScale),
          _PrefDivider(),
          _PrefRow(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            trailing: Text(
              'Daily Reminder',
              style: AppTypography.caption
                  .copyWith(color: scheme.secondary),
            ),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications — coming soon'),
                duration: Duration(seconds: 2),
              ),
            ),
          ),
          _PrefDivider(),
          _PrefRow(
            icon: Icons.security_outlined,
            title: 'Account Security',
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: scheme.secondary,
            ),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account security — coming soon'),
                duration: Duration(seconds: 2),
              ),
            ),
          ),
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

// ── Theme preference row ───────────────────────────────────────────────────

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
            Text(_label,
                style: AppTypography.caption.copyWith(color: scheme.secondary)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 16, color: scheme.secondary),
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
                Text('Appearance',
                    style: AppTypography.titleLarge
                        .copyWith(color: scheme.onSurface)),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
                      child: Row(children: [
                        Icon(icon,
                            size: 20,
                            color: isCurrent
                                ? scheme.primary
                                : scheme.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.md),
                        Text(label,
                            style: AppTypography.bodyMedium.copyWith(
                                color: isCurrent
                                    ? scheme.primary
                                    : scheme.onSurface)),
                        const Spacer(),
                        if (isCurrent)
                          Icon(Icons.check_rounded,
                              size: 18, color: scheme.primary),
                      ]),
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

// ── Font size row ──────────────────────────────────────────────────────────

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

// ── Reusable preference row ────────────────────────────────────────────────

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
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Text(title,
                style: AppTypography.bodyMedium
                    .copyWith(color: scheme.onSurface)),
            const Spacer(),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.caption.copyWith(
          color: Theme.of(context).colorScheme.secondary, letterSpacing: 2.5),
    );
  }
}

// ── Sign out button ────────────────────────────────────────────────────────

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isLoading = ref.watch(authActionsProvider).isLoading;
    return GestureDetector(
      onTap:
          isLoading ? null : () => ref.read(authActionsProvider.notifier).logout(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: scheme.error))
              : Text(
                  'SIGN OUT',
                  style: AppTypography.caption.copyWith(
                      color: scheme.error, letterSpacing: 2.5),
                ),
        ),
      ),
    );
  }
}