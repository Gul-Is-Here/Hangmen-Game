import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hangman_game/controllers/game_controller.dart';
import 'package:hangman_game/views/hangman_screen.dart';
import 'package:hangman_game/widgets/confetti.dart';
import 'package:hangman_game/widgets/keyboard.dart';

class GameScreen extends StatelessWidget {
  GameScreen({super.key});

  final GameController _controller = Get.find();

  int _mistakesForPainter({
    required String difficulty,
    required int attemptsLeft,
  }) {
    final maxAttempts = switch (difficulty) {
      'Easy' => 8,
      'Hard' => 4,
      _ => 6, // Medium/default
    };
    return maxAttempts - attemptsLeft;
  }

  void _showLevelDialog(BuildContext context, bool levelComplete) {
    final game = _controller.game.value;
    final nextLevel = game.level + 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade800.withOpacity(0.8),
                Colors.purple.shade800.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  levelComplete
                      ? 'Level ${game.level} Complete!'
                      : 'Level ${game.level} Failed',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  levelComplete
                      ? nextLevel <= game.maxLevel
                            ? 'Ready for Level $nextLevel?'
                            : 'You completed all levels!'
                      : 'Try again?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (levelComplete && nextLevel <= game.maxLevel)
                      _DialogButton(
                        text: 'Next Level',
                        onPressed: () {
                          Navigator.pop(context);
                          _controller.startNextLevel();
                        },
                        color: Colors.green,
                      ),
                    if (!levelComplete)
                      _DialogButton(
                        text: 'Retry',
                        onPressed: () {
                          Navigator.pop(context);
                          _controller.retryLevel();
                        },
                        color: Colors.blue,
                      ),
                    _DialogButton(
                      text: levelComplete ? 'Menu' : 'Quit',
                      onPressed: () {
                        Navigator.pop(context);
                        _controller.resetToFirstLevel();
                      },
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'HANGMAN',
          style: GoogleFonts.pacifico(
            fontSize: 24,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 5, color: Colors.black.withOpacity(0.3)),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _controller.resetGame,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background elements
              Positioned(
                top: -50,
                left: -50,
                child:
                    Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(duration: NumDurationExtensions(15).seconds)
                        .fade(duration: NumDurationExtensions(15).seconds),
              ),

              SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Obx(() {
                  final game = _controller.game.value;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (game.isGameOver) {
                      _showLevelDialog(context, game.isWinner);
                    }
                  });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomPaint(
                          painter: HangmanPainter(
                            mistakes: 6 - game.attemptsLeft,
                          ),
                        ),
                      ),
                      // Level and Progress
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Level ${game.level}/${game.maxLevel}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Score: ${game.score}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ).animate().slideY(begin: -0.5, end: 0, duration: 500.ms),

                      SizedBox(height: 24),

                      // Difficulty & Category Selectors
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _GlassDropdown(
                            value: game.difficulty,
                            items: ['Easy', 'Medium', 'Hard'],
                            onChanged: (v) => _controller.changeDifficulty(v!),
                          ),
                          _GlassDropdown(
                            value: game.category,
                            items: ['General', 'Animals', 'Countries', 'Food'],
                            onChanged: (v) => _controller.changeCategory(v!),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Hangman Drawing Area
                      // HangmanPainter(mistakes: _mistakesForPainter(difficulty: game.difficulty, attemptsLeft: game.attemptsLeft)),
                      SizedBox(height: 24),

                      // Hidden Word
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          game.hiddenWord,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            letterSpacing: 5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms),

                      SizedBox(height: 24),

                      // Hint Button
                      if (!game.isGameOver)
                        _GlassButton(
                          onPressed: game.hintsLeft > 0
                              ? _controller.useHint
                              : null,
                          text: 'Hint (${game.hintsLeft})',
                          icon: Icons.lightbulb_outline,
                        ).animate().fadeIn(delay: 200.ms),

                      SizedBox(height: 24),

                      // Keyboard
                      Keyboard().animate().fadeIn(delay: 300.ms),
                    ],
                  );
                }),
              ),

              // Confetti overlay
              const GameConfettiOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;

  const _GlassDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: Color(0xFF2575FC).withOpacity(0.9),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        underline: SizedBox(),
        style: GoogleFonts.poppins(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData icon;

  const _GlassButton({
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(onPressed != null ? 0.2 : 0.1),
                  Colors.white.withOpacity(onPressed != null ? 0.1 : 0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: Colors.white.withOpacity(
                          onPressed != null ? 1 : 0.5,
                        ),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        text,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(
                            onPressed != null ? 1 : 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const _DialogButton({
    required this.text,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
