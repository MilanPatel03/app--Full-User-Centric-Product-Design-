import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — Tab 0
// ─────────────────────────────────────────────────────────────────────────────

/// Sacred Editorial Home — matches the "The Sacred Editorial" Stitch design.
///
/// Layout (CustomScrollView):
///   [Top bar]           ← "The Sacred Editorial" + search icon
///   [Daily Sadhana]     ← Streak + motivational quote
///   [Verse of the Day]  ← Sanskrit (large) + translation + Reflect CTA
///   [Themes of Wisdom]  ← 4 icon+label rows
///   [Continue Reading]  ← Chapter thumbnail + progress bar + Play button
///   [Curated Insights]  ← 3 editorial insight cards
///   [Breathing room]
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _HomeAppBar()),

          // ── Daily Sadhana / Streak block ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl,
              ),
              child: _DailySadhanaBlock(),
            ),
          ),

          // ── Verse of the Day ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _VerseOfTheDayCard(
                onReflect: () =>
                    context.push('/explore/chapter/2/verse/BG_2_47'),
              ),
            ),
          ),

          // ── Themes of Wisdom ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm,
              ),
              child: _SectionLabel('THEMES OF WISDOM'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _ThemesOfWisdom(),
            ),
          ),

          // ── Continue Reading ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _SectionLabel('CONTINUE READING'),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go('/library'),
                    child: Text(
                      'LIBRARY',
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.7),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _ContinueReadingCard(
                onTap: () => context.push('/explore/chapter/6'),
              ),
            ),
          ),

          // ── Curated Insights ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm,
              ),
              child: _SectionLabel('CURATED INSIGHTS'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _CuratedInsights(),
            ),
          ),

          // ── Bottom breathing room ────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.editorial),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar — "The Sacred Editorial" + search
// ─────────────────────────────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.md, 0,
        ),
        child: Row(
          children: [
            // Hamburger / editorial wordmark area
            Icon(
              Icons.menu_rounded,
              size: 22,
              color: scheme.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'The Sacred Editorial',
              style: AppTypography.titleLarge.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push(AppConstants.routeSearch),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Daily Sadhana block — streak + quote
// ─────────────────────────────────────────────────────────────────────────────

class _DailySadhanaBlock extends StatelessWidget {
  // Mock streak — matches Stitch design (12 Day Streak)
  static const int _streakDays = 12;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: eyebrow + headline
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DAILY SADHANA',
                style: AppTypography.caption.copyWith(
                  color: scheme.secondary,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$_streakDays Day\n',
                      style: AppTypography.headlineMedium.copyWith(
                        color: scheme.onSurface,
                        fontSize: 30,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'Streak',
                      style: AppTypography.headlineMedium.copyWith(
                        color: scheme.onSurface,
                        fontSize: 30,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Right: motivational quote
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              '"Steady as a lamp in a windless place."',
              style: AppTypography.bodyMedium.copyWith(
                color: scheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verse of the Day card — BG 2.47
// ─────────────────────────────────────────────────────────────────────────────

class _VerseOfTheDayCard extends StatefulWidget {
  const _VerseOfTheDayCard({required this.onReflect});
  final VoidCallback onReflect;

  @override
  State<_VerseOfTheDayCard> createState() => _VerseOfTheDayCardState();
}

class _VerseOfTheDayCardState extends State<_VerseOfTheDayCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale;
  late final Animation<double> _scaleAnim;

  static const _sanskrit =
      'कर्मण्येवाधिकारस्ते\nमा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूः\nमा ते सङ्गोऽस्त्वकर्मणि॥';
  static const _translation =
      '"You have a right to perform your prescribed duties, '
      'but you are not entitled to the fruits of your actions."';
  static const _chapterRef = 'Chapter 2 · Sankhya Yoga · Verse 47';

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: AppAnimations.quick,
      value: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scale, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _scale.forward(),
      onTapUp: (_) => _scale.reverse(),
      onTapCancel: () => _scale.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SectionContainer(
          tier: SurfaceTier.low,
          borderRadius: AppRadius.lgBorder,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Eyebrow ─────────────────────────────────────────────
              Text(
                'VERSE OF THE DAY',
                style: AppTypography.caption.copyWith(
                  color: scheme.secondary,
                  letterSpacing: 2.5,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Sanskrit — large Devanagari ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.06),
                  borderRadius: AppRadius.mdBorder,
                ),
                child: Text(
                  _sanskrit,
                  style: AppTypography.sanskritDisplay.copyWith(
                    color: scheme.primary,
                    fontSize: 22,
                    height: 2.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Translation ─────────────────────────────────────────
              Text(
                _translation,
                style: AppTypography.bodyMedium.copyWith(
                  color: scheme.onSurface,
                  fontStyle: FontStyle.italic,
                  height: 1.8,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Chapter ref + Reflect button ─────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _chapterRef,
                      style: AppTypography.caption.copyWith(
                        color: scheme.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Amber "Reflect" CTA pill — matches Stitch
                  GestureDetector(
                    onTap: widget.onReflect,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: AppRadius.fullBorder,
                      ),
                      child: Text(
                        'Reflect',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.onPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Themes of Wisdom — 4 icon + label rows
// ─────────────────────────────────────────────────────────────────────────────

class _ThemesOfWisdom extends StatelessWidget {
  static const _themes = [
    (icon: Icons.self_improvement_rounded, label: 'Inner Peace'),
    (icon: Icons.balance_rounded,          label: 'Righteous Duty'),
    (icon: Icons.lightbulb_outline_rounded, label: 'True Knowledge'),
    (icon: Icons.favorite_border_rounded,  label: 'Shakti Yoga'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: _themes.map((t) {
        return _ThemeRow(icon: t.icon, label: t.label);
      }).toList(),
    );
  }
}

class _ThemeRow extends StatefulWidget {
  const _ThemeRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  State<_ThemeRow> createState() => _ThemeRowState();
}

class _ThemeRowState extends State<_ThemeRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: AppAnimations.quick,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _fade.animateTo(0.5),
      onTapUp: (_) {
        _fade.animateTo(1.0);
        context.push('/explore');
      },
      onTapCancel: () => _fade.animateTo(1.0),
      behavior: HitTestBehavior.opaque,
      child: FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: scheme.secondary),
              const SizedBox(width: AppSpacing.md),
              Text(
                widget.label,
                style: AppTypography.titleSmall.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Continue Reading card — Chapter 6 mock (Dhyana Yoga)
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueReadingCard extends StatefulWidget {
  const _ContinueReadingCard({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ContinueReadingCard> createState() => _ContinueReadingCardState();
}

class _ContinueReadingCardState extends State<_ContinueReadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: AppAnimations.quick,
      value: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scale, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _scale.forward(),
      onTapUp: (_) {
        _scale.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scale.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SectionContainer(
          tier: SurfaceTier.low,
          borderRadius: AppRadius.lgBorder,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // ── Chapter thumbnail ──────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: AppRadius.mdBorder,
                ),
                child: Center(
                  child: Text(
                    '6',
                    style: AppTypography.displayLarge.copyWith(
                      fontSize: 28,
                      color: scheme.primary.withValues(alpha: 0.5),
                      height: 1.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // ── Chapter info ───────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter 6: Dhyāna Yoga',
                      style: AppTypography.titleSmall.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '"When the mind..."',
                      style: AppTypography.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Progress dots
                    Row(
                      children: [
                        ...List.generate(3, (i) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == 0
                                  ? scheme.primary
                                  : scheme.onSurface.withValues(alpha: 0.15),
                            ),
                          ),
                        )),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Verse 13 of 47',
                          style: AppTypography.caption.copyWith(
                            color: scheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // ── Play arrow ────────────────────────────────────────
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: scheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Curated Insights — 3 editorial insight cards
// ─────────────────────────────────────────────────────────────────────────────

class _CuratedInsights extends StatelessWidget {
  static const _insights = [
    (
      icon: Icons.spa_rounded,
      title: 'Mindfulness in Action',
      body:
          'Modern interpretations of Karma Yoga for the professional world.',
    ),
    (
      icon: Icons.park_outlined,
      title: 'The Ecology of Spirit',
      body: 'Understanding our connection to the Prakriti (Nature).',
    ),
    (
      icon: Icons.diamond_outlined,
      title: 'The Indestructible Self',
      body: 'Meditations on the immortality of the soul as told in Ch. 2.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _insights
          .map((ins) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _InsightCard(
                  icon: ins.icon,
                  title: ins.title,
                  body: ins.body,
                ),
              ))
          .toList(),
    );
  }
}

class _InsightCard extends StatefulWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  State<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<_InsightCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: AppAnimations.quick,
      value: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scale, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _scale.forward(),
      onTapUp: (_) => _scale.reverse(),
      onTapCancel: () => _scale.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SectionContainer(
          tier: SurfaceTier.low,
          borderRadius: AppRadius.lgBorder,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon in tinted square
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smBorder,
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: scheme.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTypography.titleSmall.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.body,
                      style: AppTypography.bodyMedium.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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