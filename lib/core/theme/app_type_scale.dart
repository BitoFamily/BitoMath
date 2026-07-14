import 'dart:ui';

/// Continuous, formula-based text scaling by device size — no fixed sizes,
/// no discrete breakpoint tiers. Interpolates the shortest screen side
/// between a phone and a large-tablet baseline and clamps at both ends.
class AppTypeScale {
  static const double _minSide = 360.0; // small phone baseline
  static const double _maxSide = 1024.0; // large tablet baseline
  static const double _minScale = 1.0;
  static const double _maxScale = 1.35;

  static double factorFor(Size size) {
    final t = ((size.shortestSide - _minSide) / (_maxSide - _minSide))
        .clamp(0.0, 1.0);
    return _minScale + (_maxScale - _minScale) * t;
  }
}
