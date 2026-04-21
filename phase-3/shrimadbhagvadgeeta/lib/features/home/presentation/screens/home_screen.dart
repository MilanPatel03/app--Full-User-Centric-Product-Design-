import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Sacred Editorial Home — Tab 0.
///
/// Layout (CustomScrollView):
///   [Greeting header]   ← Sanskrit welcome, time-aware
///   [Featured verse]    ← Nishkama Karma — BG 2.47 (hardcoded MVP)
///   [Quick links]       ← Start Reading / Search
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
          // ── Greeting header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HomeHeader(),
          ),

          // ── Featured verse card ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _FeaturedVerseCard(
                onTap: () => context.push(
                  '/explore/chapter/2/verse/BG_2_47',
                ),
              ),
            ),
          ),

          // ── Quick actions ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm,
              ),
              child: _QuickActions(),
            ),
          ),

          // ── Section: Explore the Gita ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md,
              ),
              child: _SectionLabel('EXPLORE THE GITA'),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _ChapterTeaser(),
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
// Greeting header
// ─────────────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'नमस्ते';        // Night
    if (hour < 12) return 'सुप्रभातम्';   // Morning
    if (hour < 17) return 'नमस्ते';       // Afternoon
    return 'शुभ संध्या';                  // Evening
  }

  String get _greetingEnglish {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Still Night, Seeker';
    if (hour < 12) return 'Good Morning, Seeker';
    if (hour < 17) return 'Good Afternoon, Seeker';
    return 'Good Evening, Seeker';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ॐ',
              style: AppTypography.sanskritBody.copyWith(
                fontSize: 20,
                color: scheme.primary.withValues(alpha: 0.45),
                height: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _greeting,
              style: AppTypography.sanskritDisplay.copyWith(
                color: scheme.onSurface,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _greetingEnglish,
              style: AppTypography.headlineMedium.copyWith(
                color: scheme.onSurface,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'The Bhagavad Gita awaits your contemplation.',
              style: AppTypography.bodyMedium.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Featured verse card — BG 2.47 (Nishkama Karma)
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturedVerseCard extends StatefulWidget {
  const _FeaturedVerseCard({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_FeaturedVerseCard> createState() => _FeaturedVerseCardState();
}

class _FeaturedVerseCardState extends State<_FeaturedVerseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale;
  late final Animation<double> _scaleAnim;

  // Hardcoded BG 2.47 for MVP home
  static const _chapterLabel = '2.47';
  static const _sanskrit =
      'कर्मण्येवाधिकारस्ते\nमा फलेषु कदाचन।\nमा कर्मफलहेतुर्भूः\nमा ते सङ्गोऽस्त्वकर्मणि॥';
  static const _translation =
      'You have a right to perform your prescribed duties, '
      'but you are not entitled to the fruits of your actions.';
  static const _eyebrow = 'TODAY\'S VERSE · NISHKAMA KARMA';

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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 12,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: AppRadius.smBorder,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _eyebrow,
                    style: AppTypography.caption.copyWith(
                      color: scheme.primary,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const Spacer(),
                  // Verse reference pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.fullBorder,
                    ),
                    child: Text(
                      _chapterLabel,
                      style: AppTypography.caption.copyWith(
                        color: scheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Sanskrit text
              Text(
                _sanskrit,
                style: AppTypography.sanskritDisplay.copyWith(
                  color: scheme.onSurface,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Translation
              Text(
                _translation,
                style: AppTypography.bodyMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Read more row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'READ VERSE',
                    style: AppTypography.caption.copyWith(
                      color: scheme.secondary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: scheme.secondary,
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
// Quick action row
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: Icons.explore_rounded,
            label: 'BEGIN\nREADING',
            onTap: () => context.go('/explore'),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.search_rounded,
            label: 'SEARCH\nVERSES',
            onTap: () => context.push(AppConstants.routeSearch),
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: AppAnimations.quick,
      value: 1.0,
    );
    _anim = Tween<double>(begin: 1.0, end: 0.97).animate(
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
        scale: _anim,
        child: SectionContainer(
          tier: SurfaceTier.high,
          borderRadius: AppRadius.mdBorder,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, size: 22, color: scheme.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.label,
                style: AppTypography.caption.copyWith(
                  color: scheme.onSurface,
                  letterSpacing: 1.5,
                  height: 1.6,
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
// Chapter teaser strip
// ─────────────────────────────────────────────────────────────────────────────

class _ChapterTeaser extends StatelessWidget {
  // First three chapters as static teasers
  static final _teasers = [
    (num: 1, name: 'Arjuna Grieves', sanskrit: 'अर्जुनविषाद'),
    (num: 2, name: 'Transcendent Knowledge', sanskrit: 'सांख्ययोग'),
    (num: 3, name: 'Path of Action', sanskrit: 'कर्मयोग'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _teasers.map((t) {
        return _ChapterTeaserItem(
          num: t.num,
          name: t.name,
          sanskrit: t.sanskrit,
        );
      }).toList(),
    );
  }
}

class _ChapterTeaserItem extends StatefulWidget {
  const _ChapterTeaserItem({
    required this.num,
    required this.name,
    required this.sanskrit,
  });

  final int num;
  final String name;
  final String sanskrit;

  @override
  State<_ChapterTeaserItem> createState() => _ChapterTeaserItemState();
}

class _ChapterTeaserItemState extends State<_ChapterTeaserItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: AppAnimations.quick,
      value: 1.0,
    );
    _anim = Tween<double>(begin: 1.0, end: 0.98).animate(
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
        context.push('/explore/chapter/${widget.num}');
      },
      onTapCancel: () => _scale.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _anim,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              // Chapter number
              SectionContainer(
                tier: SurfaceTier.high,
                borderRadius: AppRadius.smBorder,
                width: 40,
                height: 40,
                child: Center(
                  child: Text(
                    '${widget.num}',
                    style: AppTypography.titleSmall.copyWith(
                      color: scheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: AppTypography.titleSmall.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      widget.sanskrit,
                      style: AppTypography.sanskritSmall.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
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
