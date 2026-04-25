import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppShell — persistent bottom navigation host
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps the four main tab destinations behind a Sacred Editorial bottom nav.
///
/// Navigation is index-based (no GoRouter sub-navigation here). Deep links
/// into chapter/verse detail push on top of this shell via GoRouter's
/// ShellRoute mechanism — the shell stays visible for the four root tabs,
/// but disappears for nested detail screens.
///
/// ## Tab order (matches designs)
/// 0 — Home       (HomeScreen)
/// 1 — Explore    (ChaptersScreen)
/// 2 — Library    (BookmarksScreen — combined)
/// 3 — Profile    (ProfileScreen)
class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTabSelected,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: widget.child,
      bottomNavigationBar: _SacredBottomNav(
        currentIndex: widget.currentIndex,
        onTabSelected: widget.onTabSelected,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sacred bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _SacredBottomNav extends StatelessWidget {
  const _SacredBottomNav({
    required this.currentIndex,
    required this.onTabSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  static const _tabs = [
    (icon: Icons.menu_book_outlined,    activeIcon: Icons.menu_book_rounded,       label: 'HOME'),
    (icon: Icons.explore_outlined,      activeIcon: Icons.explore_rounded,          label: 'EXPLORE'),
    (icon: Icons.collections_bookmark_outlined, activeIcon: Icons.collections_bookmark_rounded, label: 'LIBRARY'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,          label: 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      // No border — pure surface separation per Sacred Editorial no-line rule.
      // Depth conveyed via surface tier contrast (surfaceContainerLow vs surface).
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        // Subtle ambient top shadow — replaces hard border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: _NavItem(
                  icon: tab.icon,
                  activeIcon: tab.activeIcon,
                  label: tab.label,
                  isActive: isActive,
                  onTap: () => onTabSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
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
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.82).animate(
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
    final color = widget.isActive ? scheme.primary : scheme.onSurfaceVariant;

    return GestureDetector(
      onTapDown: (_) => _scale.forward(),
      onTapUp: (_) {
        _scale.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scale.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Amber pill indicator behind active icon ──────────────────────
            AnimatedContainer(
              duration: AppAnimations.meditative,
              curve: AppAnimations.defaultCurve,
              width: widget.isActive ? 48 : 32,
              height: 26,
              decoration: BoxDecoration(
                color: widget.isActive
                    ? scheme.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(13)),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppAnimations.quick,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: Icon(
                    widget.isActive ? widget.activeIcon : widget.icon,
                    key: ValueKey(widget.isActive),
                    color: color,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AnimatedDefaultTextStyle(
              duration: AppAnimations.quick,
              style: AppTypography.caption.copyWith(
                color: color,
                letterSpacing: 0.8,
                fontSize: 9,
                fontWeight:
                    widget.isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}