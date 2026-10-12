import 'package:flutter/material.dart';

/// Draws the gallows and one body part per wrong guess. The frame is always
/// there; [wrongGuesses] decides how much of the figure is drawn.
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

    final groundY = size.height * 0.95;
    final postX = size.width * 0.3;
    final beamEndX = size.width * 0.72;
    final beamY = size.height * 0.08;
    final ropeEndY = size.height * 0.22;

    canvas.drawLine(Offset(size.width * 0.1, groundY), Offset(size.width * 0.6, groundY), frame);
    canvas.drawLine(Offset(postX, groundY), Offset(postX, beamY), frame);
    canvas.drawLine(Offset(postX, beamY), Offset(beamEndX, beamY), frame);
    canvas.drawLine(Offset(beamEndX, beamY), Offset(beamEndX, ropeEndY), frame);

    final headRadius = size.height * 0.09;
    final headCenter = Offset(beamEndX, ropeEndY + headRadius);
    final bodyTop = headCenter.dy + headRadius;
    final bodyBottom = bodyTop + size.height * 0.26;
    final hipCenter = Offset(beamEndX, bodyBottom);

    if (wrongGuesses >= 1) {
      canvas.drawCircle(headCenter, headRadius, figure);
    }
    if (wrongGuesses >= 2) {
      canvas.drawLine(Offset(beamEndX, bodyTop), hipCenter, figure);
    }
    if (wrongGuesses >= 3) {
      canvas.drawLine(
        Offset(beamEndX, bodyTop + size.height * 0.05),
        Offset(beamEndX - size.width * 0.14, bodyTop + size.height * 0.16),
        figure,
      );
    }
    if (wrongGuesses >= 4) {
      canvas.drawLine(
        Offset(beamEndX, bodyTop + size.height * 0.05),
        Offset(beamEndX + size.width * 0.14, bodyTop + size.height * 0.16),
        figure,
      );
    }
    if (wrongGuesses >= 5) {
      canvas.drawLine(
        hipCenter,
        Offset(beamEndX - size.width * 0.13, bodyBottom + size.height * 0.18),
        figure,
      );
    }
    if (wrongGuesses >= 6) {
      canvas.drawLine(
        hipCenter,
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
