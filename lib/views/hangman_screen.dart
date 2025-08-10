import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/hangman_controller.dart';

class HangmanScreen extends StatelessWidget {
  final HangmanController _controller = Get.put(HangmanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hangman',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final hangman = _controller.hangman.value;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Hangman Drawing (Visual)
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomPaint(
                    painter: HangmanPainter(mistakes: 6 - hangman.attemptsLeft),
                  ),
                ),
                SizedBox(height: 20),
                // Hidden Word
                Text(
                  hangman.hiddenWord,
                  style: GoogleFonts.poppins(fontSize: 32, letterSpacing: 5),
                ),
                SizedBox(height: 20),
                // Keyboard (A-Z)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((
                    letter,
                  ) {
                    final isGuessed = hangman.guessedLetters.contains(letter);
                    return ElevatedButton(
                      onPressed: isGuessed || hangman.isGameOver
                          ? null
                          : () => _controller.guessLetter(letter),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(12),
                        backgroundColor: isGuessed
                            ? (hangman.word.contains(letter)
                                  ? Colors.green
                                  : Colors.red)
                            : Colors.blue,
                      ),
                      child: Text(letter),
                    );
                  }).toList(),
                ),
                // Game Over Message
                if (hangman.isGameOver)
                  Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        hangman.isWinner
                            ? 'You Won! 🎉'
                            : 'Game Over! The word was: ${hangman.word}',
                        style: GoogleFonts.poppins(fontSize: 24),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _controller.resetGame,
                        child: Text('Play Again'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Custom Painter for Hangman Drawing
class HangmanPainter extends CustomPainter {
  final int mistakes;

  HangmanPainter({required this.mistakes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Gallows Base
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.8),
      paint,
    );

    // Gallows Pole
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.2),
      paint,
    );

    // Gallows Top
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.2),
      paint,
    );

    // Gallows Rope
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.3),
      paint,
    );

    // Draw Hangman Parts Based on Mistakes
    if (mistakes >= 1) {
      // Head
      canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.35),
        15,
        paint,
      );
    }

    if (mistakes >= 2) {
      // Body
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * 0.5),
        Offset(size.width * 0.7, size.height * 0.7),
        paint,
      );
    }

    if (mistakes >= 3) {
      // Left Arm
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * 0.55),
        Offset(size.width * 0.6, size.height * 0.5),
        paint,
      );
    }

    if (mistakes >= 4) {
      // Right Arm
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * 0.55),
        Offset(size.width * 0.8, size.height * 0.5),
        paint,
      );
    }

    if (mistakes >= 5) {
      // Left Leg
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * 0.7),
        Offset(size.width * 0.6, size.height * 0.8),
        paint,
      );
    }

    if (mistakes >= 6) {
      // Right Leg
      canvas.drawLine(
        Offset(size.width * 0.7, size.height * 0.7),
        Offset(size.width * 0.8, size.height * 0.8),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
