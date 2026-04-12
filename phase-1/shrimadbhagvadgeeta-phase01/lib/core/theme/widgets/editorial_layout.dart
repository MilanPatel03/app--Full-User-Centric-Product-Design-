import 'package:flutter/material.dart';

import '../app_spacing.dart';

/// Sacred Editorial — Base Screen Layout
///
/// Replaces [Scaffold] + [AppBar] with a pure surface-layered shell.
///
/// ## Design Rules
/// - NO AppBar (violates editorial rule)
/// - Background = [ColorScheme.surface] (deepest tonal layer)
/// - SafeArea handles OS insets
/// - [leading] → optional back-navigation icon, floats top-left
/// - [actions] → optional icon row, floats top-right
///
/// Usage (root screen — no back button):
/// ```dart
/// EditorialLayout(
///   actions: [_SearchIcon(), _SettingsIcon()],
///   child: CustomScrollView(slivers: [...]),
/// )
/// ```
///
/// Usage (nested screen — back button required):
/// ```dart
/// EditorialLayout(
///   leading: _BackIcon(),
///   child: CustomScrollView(slivers: [...]),
/// )
/// ```
class EditorialLayout extends StatelessWidget {
  const EditorialLayout({
    super.key,
    required this.child,
    this.leading,
    this.actions = const [],
  });

  /// The scrollable or full-screen content.
  final Widget child;

  /// Optional back-navigation widget, floated top-left.
  /// Typically a [GestureDetector] wrapping an arrow icon.
  final Widget? leading;

  /// Floating icon buttons stacked at the top-right over the header.
  /// Should be limited to 3 max to prevent crowding.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          // ── Main content ─────────────────────────────────────────────────
          SafeArea(child: child),

          // ── Back / leading — floats top-left ─────────────────────────────
          if (leading != null)
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xs,
                    top: AppSpacing.xs,
                  ),
                  child: leading!,
                ),
              ),
            ),

          // ── Floating actions — overlay the header ─────────────────────────
          if (actions.isNotEmpty)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: AppSpacing.xs,
                    top: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
