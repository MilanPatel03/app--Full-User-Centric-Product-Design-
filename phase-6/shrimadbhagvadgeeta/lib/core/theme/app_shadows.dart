/// Sacred Editorial — Shadow & Depth System
///
/// Layer Principle: reach for surface tier changes BEFORE shadows.
/// Shadows are reserved for truly floating elements (modals, overlays).
///
/// Shadow Tint Rule: use warm onSurface tone (#E5E2E1), NOT pure black.
/// This mimics natural light through translucent paper — warm, not harsh.
abstract final class AppShadows {
  // ── Floating Elements (e.g., Current Verse overlay) ──────────────────────
  static const double floatingBlur = 50.0;
  static const double floatingOpacity = 0.08;  // 6–10% per spec
  static const double floatingSpread = 0.0;

  // ── Modal / Bottom Sheet ──────────────────────────────────────────────────
  static const double modalBlur = 60.0;
  static const double modalOpacity = 0.10;
  static const double modalSpread = -4.0; // Tighter, contained shadow

  // ── Hover / Lifted Card ───────────────────────────────────────────────────
  static const double hoverBlur = 30.0;
  static const double hoverOpacity = 0.06;
  static const double hoverSpread = 0.0;
}
