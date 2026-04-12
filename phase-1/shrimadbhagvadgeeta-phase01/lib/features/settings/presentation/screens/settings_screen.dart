import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';

/// App settings — theme, font size, reading preferences.
///
/// State: will be managed by a settings provider (Step 6).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Settings', style: context.wisdomTitle),
      ),
      body: Center(
        child: SectionContainer(
          tier: SurfaceTier.medium,
          padding: AppEdgeInsets.card,
          borderRadius: AppRadius.lgBorder,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Settings', style: context.wisdomTitle),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Theme mode, font size, and reading\npreferences — Step 6',
                style: context.utilityCaption
                    .copyWith(color: scheme.secondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      // TODO (Step 6): Add theme toggle, font size slider, commentary toggle
    );
  }
}
