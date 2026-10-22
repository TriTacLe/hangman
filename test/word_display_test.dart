import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/ui/word_display.dart';

import 'helpers.dart';

void main() {
  testWidgets('draws one slot per letter and hides what is not guessed', (
    tester,
  ) async {
    await tester.pumpWidget(
      appUnderTest(
        const Scaffold(body: WordDisplay(word: 'O__', revealed: false)),
        locale: const Locale('en'),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(WordDisplay),
        matching: find.byType(Container),
      ),
      findsNWidgets(3),
    );
    expect(find.text('O'), findsOneWidget);
    // An unguessed box is empty, not an underscore glyph.
    expect(find.text('_'), findsNothing);
  });

  testWidgets('tells a screen reader what is revealed and what is left', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      appUnderTest(
        const Scaffold(body: WordDisplay(word: 'O__', revealed: false)),
        locale: const Locale('en'),
      ),
    );

    final label = tester.getSemantics(find.byType(WordDisplay)).label;
    expect(label, contains('O, blank, blank'));
    expect(label, contains('2 letters still hidden'));
    handle.dispose();
  });

  testWidgets('says so once every letter is revealed', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      appUnderTest(
        const Scaffold(body: WordDisplay(word: 'OST', revealed: true)),
        locale: const Locale('en'),
      ),
    );

    expect(
      tester.getSemantics(find.byType(WordDisplay)).label,
      contains('Every letter revealed'),
    );
    handle.dispose();
  });

  testWidgets('reads the blanks in Norwegian too', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      appUnderTest(
        const Scaffold(body: WordDisplay(word: 'Å_', revealed: false)),
        locale: const Locale('nb'),
      ),
    );

    final label = tester.getSemantics(find.byType(WordDisplay)).label;
    expect(label, contains('Å, tom'));
    expect(label, contains('Én bokstav er fortsatt skjult'));
    handle.dispose();
  });
}
