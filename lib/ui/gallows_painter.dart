import 'dart:math';

import 'package:flutter/material.dart';

/// The frame is always drawn. [wrongGuesses] decides how much of the figure is.
///
/// Lines lean a fraction off true and overshoot their joins, so it reads as
/// drawn by hand. The wobble comes from a fixed seed, so it is the same drawing
/// every frame and the golden tests stay stable.
class GallowsPainter extends CustomPainter {
  GallowsPainter({
    required this.wrongGuesses,
    required this.frameColor,
    required this.figureColor,
  });

  final int wrongGuesses;
  final Color frameColor;
  final Color figureColor;

  static const int _seed = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final wobble = Random(_seed);
    final frame = _stroke(frameColor, size);
    final figure = _stroke(figureColor, size);

    double jitter() => (wobble.nextDouble() - 0.5) * size.shortestSide * 0.018;

    void line(Offset from, Offset to, Paint paint) {
      canvas.drawLine(
        from.translate(jitter(), jitter()),
        to.translate(jitter(), jitter()),
        paint,
      );
    }

    final groundY = size.height * 0.95;
    final postX = size.width * 0.3;
    final beamEndX = size.width * 0.72;
    final beamY = size.height * 0.08;
    final ropeEndY = size.height * 0.22;

    line(
      Offset(size.width * 0.1, groundY),
      Offset(size.width * 0.6, groundY),
      frame,
    );
    line(Offset(postX, groundY), Offset(postX, beamY), frame);
    line(Offset(postX, beamY), Offset(beamEndX, beamY), frame);
    line(Offset(beamEndX, beamY), Offset(beamEndX, ropeEndY), frame);

    final headRadius = size.height * 0.09;
    final headCentre = Offset(beamEndX, ropeEndY + headRadius);
    final bodyTop = headCentre.dy + headRadius;
    final bodyBottom = bodyTop + size.height * 0.26;
    final hip = Offset(beamEndX, bodyBottom);
    final shoulder = bodyTop + size.height * 0.05;

    if (wrongGuesses >= 1) {
      canvas.drawCircle(
        headCentre.translate(jitter(), jitter()),
        headRadius,
        figure,
      );
    }
    if (wrongGuesses >= 2) {
      line(Offset(beamEndX, bodyTop), hip, figure);
    }
    if (wrongGuesses >= 3) {
      line(
        Offset(beamEndX, shoulder),
        Offset(beamEndX - size.width * 0.14, shoulder + size.height * 0.11),
        figure,
      );
    }
    if (wrongGuesses >= 4) {
      line(
        Offset(beamEndX, shoulder),
        Offset(beamEndX + size.width * 0.14, shoulder + size.height * 0.11),
        figure,
      );
    }
    if (wrongGuesses >= 5) {
      line(
        hip,
        Offset(beamEndX - size.width * 0.13, bodyBottom + size.height * 0.18),
        figure,
      );
    }
    if (wrongGuesses >= 6) {
      line(
        hip,
        Offset(beamEndX + size.width * 0.13, bodyBottom + size.height * 0.18),
        figure,
      );
    }
  }

  Paint _stroke(Color color, Size size) => Paint()
    ..color = color
    ..strokeWidth = size.shortestSide * 0.035
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  @override
  bool shouldRepaint(GallowsPainter oldDelegate) =>
      oldDelegate.wrongGuesses != wrongGuesses ||
      oldDelegate.frameColor != frameColor ||
      oldDelegate.figureColor != figureColor;
}
