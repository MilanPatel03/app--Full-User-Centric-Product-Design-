import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/widgets/section_container.dart';
import '../providers/auth_state_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoginScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Authentication entry point.
///
/// ## States handled
/// - Idle: form with optional error
/// - Loading: form disabled, spinner
/// - Signup success (email confirmation required): shows confirmation notice,
///   clears form, switches to sign-in mode
/// - Login success: GoRouter redirect fires via [authStateProvider]
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isSignup = false;
  bool _obscurePass = true;

  // Shown after successful signup when email confirmation is required.
  bool _showConfirmationNotice = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) return;

    final notifier = ref.read(authActionsProvider.notifier);

    if (_isSignup) {
      await notifier.signup(email: email, password: pass);

      // After signup attempt, check if it succeeded (no error in state).
      // If the Supabase project requires email confirmation, the user object
      // returned has no confirmed session — authStateProvider stays null.
      // We detect success by checking that authActionsProvider is AsyncData
      // (no error), then show the confirmation notice and reset the form.
      final state = ref.read(authActionsProvider);
      if (state is AsyncData) {
        // Check if the user is already logged in (confirmation disabled)
        // or if they need to confirm their email first.
        final isLoggedIn = ref.read(authStateProvider).valueOrNull != null;
        if (!isLoggedIn) {
          // Email confirmation is required — show notice, reset form.
          setState(() {
            _showConfirmationNotice = true;
            _isSignup = false;
          });
          _emailCtrl.clear();
          _passCtrl.clear();
        }
        // If isLoggedIn is true, the ref.listen below handles navigation.
      }
    } else {
      await notifier.login(email: email, password: pass);
    }
  }

  void _switchMode() {
    setState(() {
      _isSignup = !_isSignup;
      // Always clear fields when switching modes — prevents stale input
      // being carried from signup form into the sign-in form.
      _emailCtrl.clear();
      _passCtrl.clear();
      _showConfirmationNotice = false;
    });
    // Also clear any error state from a previous attempt.
    ref.read(authActionsProvider.notifier).clearError();
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authActionsProvider);
    final isLoading = authAsync.isLoading;
    final error = switch (authAsync) {
      AsyncError(:final error) => error.toString(),
      _ => null,
    };
    final scheme = Theme.of(context).colorScheme;

    // Redirect to home after successful login — authStateProvider fires GoRouter.
    ref.listen(authStateProvider, (_, next) {
      if (next.valueOrNull != null) {
        context.go('/');
      }
    });

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top breathing room ──────────────────────────────────────
              const SizedBox(height: AppSpacing.editorial),

              // ── Sacred mark ─────────────────────────────────────────────
              Text(
                'ॐ',
                style: AppTypography.sanskritDisplay.copyWith(
                  color: scheme.primary.withValues(alpha: 0.45),
                  fontSize: 28,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── App name ─────────────────────────────────────────────────
              Text(
                'श्रीमद् भगवद्गीता',
                style: AppTypography.sanskritDisplay.copyWith(
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Bhagavad Gita',
                style: AppTypography.headlineMedium.copyWith(
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.editorial),

              // ── Email confirmation notice ────────────────────────────────
              // Shown after successful signup when confirmation is required.
              if (_showConfirmationNotice) ...[
                SectionContainer(
                  tier: SurfaceTier.medium,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  borderRadius: AppRadius.mdBorder,
                  child: Column(
                    children: [
                      Icon(
                        Icons.mark_email_unread_outlined,
                        color: scheme.primary,
                        size: 32,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Check your email',
                        style: AppTypography.titleSmall.copyWith(
                          color: scheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'A confirmation link has been sent. '
                            'Click it, then sign in below.',
                        style: AppTypography.caption.copyWith(
                          color: scheme.secondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // ── Mode label ───────────────────────────────────────────────
              if (!_showConfirmationNotice) ...[
                Text(
                  _isSignup ? 'CREATE ACCOUNT' : 'SIGN IN',
                  style: AppTypography.caption.copyWith(
                    color: scheme.secondary,
                    letterSpacing: 2.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // ── Email field ──────────────────────────────────────────────
              _EditorialField(
                controller: _emailCtrl,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Password field ───────────────────────────────────────────
              _EditorialField(
                controller: _passCtrl,
                label: 'Password',
                obscureText: _obscurePass,
                enabled: !isLoading,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: scheme.secondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
              ),

              // ── Error message ────────────────────────────────────────────
              if (error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  // Make the "Email not confirmed" message friendlier.
                  error.contains('not confirmed')
                      ? 'Please confirm your email first, then sign in.'
                      : error,
                  style: AppTypography.caption.copyWith(
                    color: scheme.error,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              // ── Submit button ────────────────────────────────────────────
              _SubmitButton(
                label: _isSignup ? 'Create Account' : 'Sign In',
                isLoading: isLoading,
                onTap: _submit,
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Toggle mode ──────────────────────────────────────────────
              GestureDetector(
                onTap: isLoading ? null : _switchMode,
                child: Text(
                  _isSignup
                      ? 'Already have an account? Sign in'
                      : 'New here? Create an account',
                  style: AppTypography.caption.copyWith(
                    color: scheme.secondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.editorial),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Editorial text field — no Material chrome
// ─────────────────────────────────────────────────────────────────────────────

class _EditorialField extends StatelessWidget {
  const _EditorialField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SectionContainer(
      tier: SurfaceTier.low,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppRadius.mdBorder,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              enabled: enabled,
              style: AppTypography.bodyLarge.copyWith(
                color: scheme.onSurface,
                height: 1.4,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: AppTypography.caption.copyWith(
                  color: scheme.secondary,
                  letterSpacing: 1.0,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submit button — elevated SectionContainer with scale animation
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: AppAnimations.quick,
      reverseDuration: AppAnimations.quick,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _press, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.isLoading ? null : (_) => _press.forward(),
        onTapUp: widget.isLoading
            ? null
            : (_) {
          _press.reverse();
          widget.onTap();
        },
        onTapCancel: () => _press.reverse(),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: AppRadius.mdBorder,
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: scheme.onPrimary,
            ),
          )
              : Text(
            widget.label,
            style: AppTypography.labelLarge.copyWith(
              color: scheme.onPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}