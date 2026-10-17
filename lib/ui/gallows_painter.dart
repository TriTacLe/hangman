import 'package:flutter/material.dart';

/// The frame is always drawn. [wrongGuesses] decides how much of the figure is.
class GallowsPainter extends CustomPainter {
  GallowsPainter({
    required this.wrongGuesses,
    required this.frameColor,
    required this.figureColor,
  });

  final int wrongGuesses;
  final Color frameColor;
  final Color figureColor;

  @override
  void paint(Canvas canvas, Size size) {
    final frame = _stroke(frameColor, size);
    final figure = _stroke(figureColor, size);

    void line(Offset from, Offset to, Paint paint) =>
        canvas.drawLine(from, to, paint);

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
      canvas.drawCircle(headCentre, headRadius, figure);
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
    ..strokeWidth = size.shortestSide * 0.03
    ..strokeCap = StrokeCap.square
    ..strokeJoin = StrokeJoin.miter
    ..style = PaintingStyle.stroke;

  @override
  bool shouldRepaint(GallowsPainter oldDelegate) =>
      oldDelegate.wrongGuesses != wrongGuesses ||
      oldDelegate.frameColor != frameColor ||
      oldDelegate.figureColor != figureColor;
}
