import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/ui/game_screen.dart';
import 'package:hangman/ui/home_screen.dart';
import 'package:hangman/ui/theme.dart';

import '../helpers.dart';

/// Goldens are rendered at a fixed size so a layout change shows up as a pixel
/// diff rather than as something nobody notices until the demo.
///
/// Regenerate with: flutter test --update-goldens

/// Goldens are rendered at a fixed size so a layout change shows up as a pixel
/// diff rather than as something nobody notices until the demo.
///
/// Regenerate with: flutter test --update-goldens
void main() {
  testWidgets('start screen, light, English', (tester) async {
    tester.view.physicalSize = const Size(1080, 2000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      appUnderTest(
        HomeScreen(
          selectedLocale: const Locale('en'),
          onLocaleSelected: (_) {},
        ),
        theme: hangmanLightTheme(),
        locale: const Locale('en'),
      ),
    );

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/start_light_en.png'),
    );
  });

  testWidgets('start screen, dark, Norwegian', (tester) async {
    tester.view.physicalSize = const Size(1080, 2000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      appUnderTest(
        HomeScreen(
          selectedLocale: const Locale('nb'),
          onLocaleSelected: (_) {},
        ),
        theme: hangmanDarkTheme(),
        locale: const Locale('nb'),
      ),
    );

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/start_dark_nb.png'),
    );
  });

  testWidgets('game screen, light, Norwegian keyboard', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      appUnderTest(
        GameScreen(wordRepository: fixedWord('blåbær')),
        theme: hangmanLightTheme(),
        locale: const Locale('nb'),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(GameScreen),
      matchesGoldenFile('goldens/game_light_nb.png'),
    );
  });
  testWidgets('game screen, landscape, dark, English', (tester) async {
    // Landscape lays the drawing beside the keyboard, which nothing else
    // checks.
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      appUnderTest(
        GameScreen(wordRepository: fixedWord('thunder')),
        theme: hangmanDarkTheme(),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(GameScreen),
      matchesGoldenFile('goldens/game_landscape_dark_en.png'),
    );
  });

  testWidgets('game screen, lost, light, English', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      appUnderTest(
        GameScreen(wordRepository: fixedWord('ost')),
        theme: hangmanLightTheme(),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    for (final letter in ['B', 'C', 'D', 'F', 'G', 'H']) {
      await tester.tap(key(letter));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(GameScreen),
      matchesGoldenFile('goldens/game_lost_light_en.png'),
    );
  });
}
