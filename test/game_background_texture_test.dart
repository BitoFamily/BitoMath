import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bito_math/core/persistence/player_provider.dart';
import 'package:bito_math/features/game/widgets/game_background_texture.dart';

void main() {
  testWidgets(
      'GameBackgroundTexture renders faint glyphs and never blocks taps',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    var tapped = false;

    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const Positioned.fill(child: GameBackgroundTexture()),
              Center(
                child: GestureDetector(
                  onTap: () => tapped = true,
                  child: const SizedBox(
                      width: 100, height: 100, child: Text('answer')),
                ),
              ),
            ],
          ),
        ),
      ),
    ));

    // Renders at least one decorative glyph.
    expect(find.text('★'), findsWidgets);

    // A widget underneath the texture layer still receives taps.
    expect(
      find.ancestor(
          of: find.byType(GameBackgroundTexture),
          matching: find.byType(IgnorePointer)),
      findsWidgets,
    );
    await tester.tap(find.text('answer'));
    expect(tapped, isTrue);
  });
}
