import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bito_math/core/persistence/player_provider.dart';
import 'package:bito_math/features/game/widgets/answer_button.dart';

void main() {
  testWidgets('AnswerButton wiggles when revealed as the wrong pick',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    Widget build(bool? result) => ProviderScope(
          overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            home: Scaffold(
              body: AnswerButton(
                value: 7,
                result: result,
                enabled: true,
              ),
            ),
          ),
        );

    // Unanswered — no Transform offset applied by the wiggle yet.
    await tester.pumpWidget(build(null));
    await tester.pumpAndSettle();

    // Reveal as wrong — should kick off the shake, i.e. the button visibly
    // moves off its resting x-position partway through the animation.
    await tester.pumpWidget(build(false));
    await tester.pump(const Duration(milliseconds: 100));

    final transform = tester.widget<Transform>(find
        .ancestor(
          of: find.text('7'),
          matching: find.byType(Transform),
        )
        .first);
    expect(transform.transform.getTranslation().x, isNot(0));

    // Let the shake finish so no timers leak past the test.
    await tester.pumpAndSettle();
  });
}
