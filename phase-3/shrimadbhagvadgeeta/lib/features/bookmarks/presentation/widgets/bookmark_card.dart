import 'package:flutter/material.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../../domain/entities/bookmark.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BookmarkCard
// ─────────────────────────────────────────────────────────────────────────────

/// Displays a single [Bookmark] in the Library screen.
///
/// ## Design (Sacred Editorial)
/// - [SectionContainer] tier: high — card elevation via surface tier
/// - Verse label (BG_X_Y) as eyebrow
/// - Note text (if present) as secondary body
/// - Trailing: close icon to remove bookmark
/// - Press animation: scale 1.0 → 0.98, 300ms
///
/// ## Interaction
/// - Tap card → navigate to shlok detail
/// - Tap remove icon → [onRemove] callback
class BookmarkCard extends StatefulWidget {
  const BookmarkCard({
    super.key,
    required this.bookmark,
    required this.onTap,
    required this.onRemove,
  });

  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  State<BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<BookmarkCard>
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

  /// Format `BG_2_47` → `BG 2.47`
  String _formatId(String id) {
    final parts = id.split('_');
    if (parts.length == 3) return '${parts[0]} ${parts[1]}.${parts[2]}';
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = _formatId(widget.bookmark.shlokId);

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
          tier: SurfaceTier.high,
          borderRadius: AppRadius.lgBorder,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.md, AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verse ID pill + note
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verse label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.smBorder,
                      ),
                      child: Text(
                        label,
                        style: AppTypography.caption.copyWith(
                          color: scheme.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Note (if any)
                    if (widget.bookmark.note != null &&
                        widget.bookmark.note!.isNotEmpty) ...[
                      Text(
                        widget.bookmark.note!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: scheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ] else ...[
                      Text(
                        'Saved verse',
                        style: AppTypography.bodyMedium.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],

                    // Date
                    Text(
                      _formatDate(widget.bookmark.createdAt),
                      style: AppTypography.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Remove icon
              GestureDetector(
                onTap: widget.onRemove,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    Icons.bookmark_rounded,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
