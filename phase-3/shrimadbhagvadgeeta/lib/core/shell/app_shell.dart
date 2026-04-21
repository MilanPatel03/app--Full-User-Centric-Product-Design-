import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
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
/// 0 — Home       (placeholder until Step 7C)
/// 1 — Explore    (ChaptersScreen — existing)
/// 2 — Library    (BookmarksScreen — existing, to be expanded in 7C)
/// 3 — Profile    (ProfileScreen — new)
class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTabSelected,
  });

  /// The currently active routed screen.
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
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
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'HOME'),
    (icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'EXPLORE'),
    (icon: Icons.library_books_outlined, activeIcon: Icons.library_books_rounded, label: 'LIBRARY'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
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
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
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
            AnimatedSwitcher(
              duration: AppAnimations.quick,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: Icon(
                widget.isActive ? widget.activeIcon : widget.icon,
                key: ValueKey(widget.isActive),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: AppAnimations.quick,
              style: AppTypography.caption.copyWith(
                color: color,
                letterSpacing: 1.0,
                fontSize: 9,
              ),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}