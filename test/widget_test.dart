import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bito_math/app.dart';
import 'package:bito_math/core/persistence/player_provider.dart';

void main() {
  testWidgets('BitoMathApp builds and shows the splash screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const BitoMathApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('⚡'), findsOneWidget);

    // Let the splash screen's navigation timer fire so it doesn't leak
    // past the end of the test.
    await tester.pump(const Duration(milliseconds: 2500));
  });
}
