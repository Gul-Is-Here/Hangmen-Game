import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';

class Keyboard extends StatelessWidget {
  final GameController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final game = _controller.game.value;
      final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: letters.map((letter) {
          final isGuessed = game.guessedLetters.contains(letter);
          final isInWord = game.word.contains(letter);
          final isGameOver = game.isGameOver;

          return _KeyButton(
                letter: letter,
                isGuessed: isGuessed,
                isInWord: isInWord,
                isGameOver: isGameOver,
                onTap: () => _controller.guessLetter(letter),
              )
              .animate(delay: (letters.indexOf(letter) * 20).ms)
              .slideY(
                begin: 0.5,
                end: 0,
                duration: 300.ms,
                curve: Curves.easeOutBack,
              );
        }).toList(),
      );
    });
  }
}

class _KeyButton extends StatelessWidget {
  final String letter;
  final bool isGuessed;
  final bool isInWord;
  final bool isGameOver;
  final VoidCallback onTap;

  const _KeyButton({
    required this.letter,
    required this.isGuessed,
    required this.isInWord,
    required this.isGameOver,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isGuessed
        ? (isInWord ? colorScheme.tertiary : colorScheme.error)
        : colorScheme.primaryContainer;

    final foregroundColor = isGuessed
        ? colorScheme.onTertiary
        : colorScheme.onPrimaryContainer;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: isGuessed || isGameOver ? null : onTap,
        splashColor: colorScheme.primary.withOpacity(0.2),
        highlightColor: colorScheme.primary.withOpacity(0.1),
        child: AnimatedContainer(
          duration: 300.ms,
          curve: Curves.easeOut,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              if (!isGuessed && !isGameOver)
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
            ],
            border: Border.all(
              color: isGuessed
                  ? Colors.transparent
                  : colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
