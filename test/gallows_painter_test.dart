import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hangman/ui/gallows_painter.dart';

void main() {
  const size = Size(200, 220);

  /// Paints one stage and returns its pixels, so "the figure gains a part"
  /// can be asserted instead of eyeballed.
  Future<ByteData> render(int wrongGuesses) async {
    final recorder = PictureRecorder();
    GallowsPainter(
      wrongGuesses: wrongGuesses,
      frameColor: const Color(0xFF000000),
      figureColor: const Color(0xFFB4452E),
    ).paint(Canvas(recorder), size);

    final image = await recorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    addTearDown(image.dispose);

    return (await image.toByteData())!;
  }

  test('every wrong guess adds something to the drawing', () async {
    var previous = await render(0);

    for (var wrong = 1; wrong <= 6; wrong++) {
      final current = await render(wrong);

      expect(
        current.buffer.asUint8List(),
        isNot(previous.buffer.asUint8List()),
        reason: 'stage $wrong looks the same as stage ${wrong - 1}',
      );
      previous = current;
    }
  });

  test('the drawing is finished after six, not seven', () async {
    final six = await render(6);
    final seven = await render(7);

    expect(seven.buffer.asUint8List(), six.buffer.asUint8List());
  });

  test('the frame is there before any guess is wrong', () async {
    final blank = await render(0);
    final pixels = blank.buffer.asUint8List();

    // Something is drawn, so the gallows is not an empty canvas on arrival.
    expect(pixels.any((byte) => byte != 0), isTrue);
  });

  test('repaints only when something it draws changed', () {
    GallowsPainter painter(int wrong, Color figure) => GallowsPainter(
      wrongGuesses: wrong,
      frameColor: const Color(0xFF000000),
      figureColor: figure,
    );
    const red = Color(0xFFB4452E);

    expect(painter(2, red).shouldRepaint(painter(2, red)), isFalse);
    expect(painter(3, red).shouldRepaint(painter(2, red)), isTrue);
    expect(
      painter(2, const Color(0xFF7FBF9B)).shouldRepaint(painter(2, red)),
      isTrue,
    );
  });
}
