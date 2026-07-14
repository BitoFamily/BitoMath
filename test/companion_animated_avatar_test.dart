import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bito_math/features/companions/widgets/companion_animated_avatar.dart';

void main() {
  group('CompanionAnimatedAvatar fallback (no .riv assets exist yet)', () {
    for (var i = 0; i < 3; i++) {
      testWidgets('character $i falls back to its static PNG without error',
          (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: CompanionAnimatedAvatar(characterIndex: i),
        ));
        // Asset-existence check is async; let it resolve.
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(Image), findsOneWidget);
      });
    }

    testWidgets('changing triggerState while on the fallback path is a no-op, not a crash',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CompanionAnimatedAvatar(
          characterIndex: 0,
          triggerState: CompanionAnimState.idle,
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const MaterialApp(
        home: CompanionAnimatedAvatar(
          characterIndex: 0,
          triggerState: CompanionAnimState.correct,
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('changing characterIndex re-resolves the fallback image',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CompanionAnimatedAvatar(characterIndex: 0),
      ));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const MaterialApp(
        home: CompanionAnimatedAvatar(characterIndex: 1),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('respects width/height/fit passed through to the fallback Image',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CompanionAnimatedAvatar(
          characterIndex: 2,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      ));
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, 40);
      expect(image.height, 40);
      expect(image.fit, BoxFit.cover);
    });
  });

  group('CompanionAnimState', () {
    test('has exactly the 7 states from the issue #19 design brief', () {
      expect(CompanionAnimState.values.map((s) => s.name).toSet(), {
        'idle',
        'correct',
        'wrong',
        'streak',
        'complete',
        'unlock',
        'encourage',
      });
    });
  });
}
