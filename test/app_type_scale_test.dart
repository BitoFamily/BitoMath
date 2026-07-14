import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:bito_math/core/theme/app_type_scale.dart';

void main() {
  test('clamps to 1.0 at or below the phone baseline', () {
    expect(AppTypeScale.factorFor(const Size(360, 640)), 1.0);
    expect(AppTypeScale.factorFor(const Size(320, 480)), 1.0);
  });

  test('clamps to the max scale at or above the tablet baseline', () {
    expect(AppTypeScale.factorFor(const Size(1024, 1366)), closeTo(1.35, 1e-9));
    expect(AppTypeScale.factorFor(const Size(1200, 1600)), closeTo(1.35, 1e-9));
  });

  test('interpolates continuously between the two baselines', () {
    // Midpoint of the shortest side should land at the midpoint of the scale
    // range — proves this is a continuous formula, not a breakpoint jump.
    const midSide = (360.0 + 1024.0) / 2;
    final factor = AppTypeScale.factorFor(const Size(midSide, 900));
    expect(factor, closeTo((1.0 + 1.35) / 2, 1e-9));
  });
}
