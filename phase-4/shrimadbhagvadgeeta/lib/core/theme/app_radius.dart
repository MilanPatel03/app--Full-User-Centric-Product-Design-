import 'package:flutter/material.dart';

/// Sacred Editorial — Roundedness Scale
///
/// | Token | Value  | Application                        |
/// |-------|--------|------------------------------------|
/// | sm    | 4px    | Tooltips, small tags               |
/// | md    | 12px   | Buttons, verse cards               |
/// | lg    | 16px   | Major containers, bottom sheets    |
/// | full  | 999px  | Pills, selection chips             |
abstract final class AppRadius {
  static const double sm = 4.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double full = 999.0; // Pill shape

  // Pre-built BorderRadius for ergonomic usage
  static const BorderRadius smBorder =
      BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder =
      BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgBorder =
      BorderRadius.all(Radius.circular(lg));
  static const BorderRadius fullBorder =
      BorderRadius.all(Radius.circular(full));

  // Asymmetric — for cards that bleed to a screen edge
  static const BorderRadius topOnly = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
  static const BorderRadius bottomOnly = BorderRadius.only(
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(lg),
  );
}
