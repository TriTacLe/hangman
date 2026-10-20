import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/ui/game_screen.dart';
import 'package:hangman/ui/home_screen.dart';
import 'package:hangman/ui/info_dialog.dart';
import 'package:hangman/ui/theme.dart';

import 'helpers.dart';

/// WCAG relative luminance, so the contrast claims in lib/ui/theme.dart are
/// checked rather than asserted in a comment.
double _luminance(Color color) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : pow((value + 0.055) / 1.055, 2.4).toDouble();

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _contrast(Color a, Color b) {
  final first = _luminance(a);
  final second = _luminance(b);
  final lighter = max(first, second);
  final darker = min(first, second);

  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  final themes = {'light': hangmanLightTheme(), 'dark': hangmanDarkTheme()};

  for (final entry in themes.entries) {
    group('${entry.key} theme', () {
      testWidgets('the start screen meets the guidelines', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          appUnderTest(
            HomeScreen(
              selectedLocale: const Locale('en'),
              onLocaleSelected: (_) {},
            ),
            theme: entry.value,
          ),
        );

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets('a running game meets the guidelines', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          appUnderTest(
            GameScreen(wordRepository: fixedWord('thunder')),
            theme: entry.value,
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets('the rules dialog meets the guidelines', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          appUnderTest(const InfoDialog(), theme: entry.value),
        );

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('the Norwegian keyboard meets the guidelines', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          appUnderTest(
            GameScreen(wordRepository: fixedWord('blåbær')),
            theme: entry.value,
            locale: const Locale('nb'),
          ),
        );
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
      testWidgets('a board with guesses on it meets the guidelines', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          appUnderTest(
            GameScreen(wordRepository: fixedWord('ost')),
            theme: entry.value,
          ),
        );
        await tester.pumpAndSettle();

        // A used key is the one state the fresh-board tests never reach.
        await tester.tap(key('O'));
        await tester.pump();
        await tester.tap(key('B'));
        await tester.pump();

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });

      testWidgets('the result view meets the guidelines', (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          appUnderTest(
            GameScreen(wordRepository: fixedWord('ost')),
            theme: entry.value,
          ),
        );
        await tester.pumpAndSettle();

        for (final letter in ['O', 'S', 'T']) {
          await tester.tap(key(letter));
          await tester.pump();
        }

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets('nothing overflows at double the font size', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          appUnderTest(
            HomeScreen(
              selectedLocale: const Locale('nb'),
              onLocaleSelected: (_) {},
            ),
            theme: entry.value,
            locale: const Locale('nb'),
            textScale: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          appUnderTest(
            GameScreen(wordRepository: fixedWord('blåbær')),
            theme: entry.value,
            locale: const Locale('nb'),
            textScale: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // The rules are the longest text in the app, so they are the most
        // likely thing to run off a screen at a large font size.
        await tester.pumpWidget(
          appUnderTest(
            const InfoDialog(),
            theme: entry.value,
            locale: const Locale('nb'),
            textScale: 2,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    });
  }

  group('control outlines', () {
    test('clear the 3:1 of WCAG 1.4.11 in both themes', () {
      for (final theme in [hangmanLightTheme(), hangmanDarkTheme()]) {
        final colors = theme.colorScheme;

        expect(
          _contrast(colors.outline, colors.surface),
          greaterThanOrEqualTo(3),
          reason: '${theme.brightness} outline on the scaffold',
        );
        expect(
          _contrast(colors.outline, colors.surfaceContainerHighest),
          greaterThanOrEqualTo(3),
          reason: '${theme.brightness} outline on a raised surface',
        );
      }
    });
  });
}
