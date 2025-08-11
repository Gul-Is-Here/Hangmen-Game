import 'dart:math';

import 'package:flutter/material.dart';

class HangmanPainter extends CustomPainter {
  final int mistakes;
  final Animation<double> animation;

  HangmanPainter({required this.mistakes, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final gallowsPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final bodyPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final facePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Animated gallows construction
    final gallowsProgress = animation.value.clamp(0.0, 1.0);

    // Base (animates from left to right)
    if (gallowsProgress > 0) {
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.8),
        Offset(
          size.width * 0.2 + (size.width * 0.6) * gallowsProgress,
          size.height * 0.8,
        ),
        gallowsPaint,
      );
    }

    // Vertical pole (animates from bottom to top)
    if (gallowsProgress > 0.25) {
      final poleProgress = ((gallowsProgress - 0.25) * 4 / 3).clamp(0.0, 1.0);
      canvas.drawLine(
        Offset(size.width * 0.5, size.height * 0.8),
        Offset(
          size.width * 0.5,
          size.height * 0.8 - (size.height * 0.6) * poleProgress,
        ),
        gallowsPaint,
      );
    }

    // Top beam (animates from left to right)
    if (gallowsProgress > 0.5) {
      final beamProgress = ((gallowsProgress - 0.5) * 2).clamp(0.0, 1.0);
      canvas.drawLine(
        Offset(size.width * 0.5, size.height * 0.2),
        Offset(
          size.width * 0.5 + (size.width * 0.2) * beamProgress,
          size.height * 0.2,
        ),
        gallowsPaint,
      );
    }

    // Rope (animates from top to bottom)
    if (gallowsProgress > 0.75) {
      final ropeProgress = ((gallowsProgress - 0.75) * 4).clamp(0.0, 1.0);
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * 0.2),
        Offset(
          size.width * 0.7,
          size.height * 0.2 + (size.height * 0.1) * ropeProgress,
        ),
        gallowsPaint,
      );
    }

    // Only draw hangman if gallows is complete
    if (gallowsProgress >= 1.0) {
      // Animate each body part based on mistakes
      final bodyPartProgress = animation.value.clamp(0.0, 1.0);

      if (mistakes >= 1) {
        // Head (grows from small to full size)
        final headProgress = min(1.0, bodyPartProgress * mistakes);
        canvas.drawCircle(
          Offset(size.width * 0.7, size.height * 0.35),
          15 * headProgress,
          bodyPaint,
        );

        // Face features (only appear when head is complete)
        if (headProgress >= 1.0) {
          // Sad face when losing
          if (mistakes >= 6) {
            canvas.drawArc(
              Rect.fromCircle(
                center: Offset(size.width * 0.7, size.height * 0.38),
                radius: 8,
              ),
              -0.2,
              -2.7,
              false,
              facePaint,
            );
          }
          // Neutral face otherwise
          else {
            canvas.drawLine(
              Offset(size.width * 0.67, size.height * 0.38),
              Offset(size.width * 0.73, size.height * 0.38),
              facePaint,
            );
          }

          // Eyes
          if (mistakes >= 7) {
            canvas.drawCircle(
              Offset(size.width * 0.68, size.height * 0.33),
              2,
              eyePaint,
            );
          }
          if (mistakes >= 8) {
            canvas.drawCircle(
              Offset(size.width * 0.72, size.height * 0.33),
              2,
              eyePaint,
            );
          }
        }
      }

      if (mistakes >= 2) {
        // Body (draws from top to bottom)
        final bodyProgress = min(1.0, bodyPartProgress * (mistakes - 1));
        canvas.drawLine(
          Offset(size.width * 0.7, size.height * 0.35 + 15),
          Offset(
            size.width * 0.7,
            size.height * 0.35 + 15 + (size.height * 0.2) * bodyProgress,
          ),
          bodyPaint,
        );
      }

      if (mistakes >= 3) {
        // Left Arm (draws from shoulder outward)
        final armProgress = min(1.0, bodyPartProgress * (mistakes - 2));
        canvas.drawLine(
          Offset(size.width * 0.7, size.height * 0.5),
          Offset(
            size.width * 0.7 - (size.width * 0.1) * armProgress,
            size.height * 0.5 - (size.height * 0.05) * armProgress,
          ),
          bodyPaint,
        );
      }

      if (mistakes >= 4) {
        // Right Arm (draws from shoulder outward)
        final armProgress = min(1.0, bodyPartProgress * (mistakes - 3));
        canvas.drawLine(
          Offset(size.width * 0.7, size.height * 0.5),
          Offset(
            size.width * 0.7 + (size.width * 0.1) * armProgress,
            size.height * 0.5 - (size.height * 0.05) * armProgress,
          ),
          bodyPaint,
        );
      }

      if (mistakes >= 5) {
        // Left Leg (draws from hip downward)
        final legProgress = min(1.0, bodyPartProgress * (mistakes - 4));
        canvas.drawLine(
          Offset(size.width * 0.7, size.height * 0.7),
          Offset(
            size.width * 0.7 - (size.width * 0.1) * legProgress,
            size.height * 0.7 + (size.height * 0.1) * legProgress,
          ),
          bodyPaint,
        );
      }

      if (mistakes >= 6) {
        // Right Leg (draws from hip downward)
        final legProgress = min(1.0, bodyPartProgress * (mistakes - 5));
        canvas.drawLine(
          Offset(size.width * 0.7, size.height * 0.7),
          Offset(
            size.width * 0.7 + (size.width * 0.1) * legProgress,
            size.height * 0.7 + (size.height * 0.1) * legProgress,
          ),
          bodyPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant HangmanPainter oldDelegate) =>
      oldDelegate.mistakes != mistakes || oldDelegate.animation != animation;
}
