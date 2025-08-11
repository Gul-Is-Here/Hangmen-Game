import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/game_model.dart';
import '../database/db_helper.dart';
import '../services/audio_service.dart';
import '../services/vibration_service.dart';

class GameController extends GetxController {
  final DBHelper _dbHelper = DBHelper();
  final AudioService _audioService = AudioService();
  final VibrationService _vibrationService = VibrationService();

  final Rx<GameModel> game = GameModel(
    word: '',
    hiddenWord: '',
    difficulty: 'Medium',
    category: 'General',
    level: 1,
    maxLevel: 5,
  ).obs;

  Timer? _timer;
  final RxBool showConfetti = false.obs;
  final RxInt highScore = 0.obs;
  final Set<String> _usedWords = Set<String>();

  // Add game statistics
  final RxMap<String, int> gameStats = <String, int>{
    'games_played': 0,
    'games_won': 0,
    'current_streak': 0,
    'max_streak': 0,
  }.obs;

  @override
  void onInit() async {
    await loadHighScore();
    await loadGameStats();
    fetchRandomWord();
    super.onInit();
  }

  Future<void> loadHighScore() async {
    highScore.value = await _dbHelper.getHighScore();
  }

  Future<void> loadGameStats() async {
    final stats = await _dbHelper.getGameStats();
    gameStats.assignAll({
      'games_played': stats['games_played'] ?? 0,
      'games_won': stats['games_won'] ?? 0,
      'current_streak': stats['current_streak'] ?? 0,
      'max_streak': stats['max_streak'] ?? 0,
    });
  }

  Future<void> fetchRandomWord({String? category, int? level}) async {
    final words = await _dbHelper.getWordsForLevel(
      level ?? game.value.level,
      category ?? game.value.category,
    );

    if (words.isNotEmpty) {
      final unusedWords = words
          .where((w) => !_usedWords.contains(w['word'] as String))
          .toList();

      final availableWords = unusedWords.isNotEmpty ? unusedWords : words;
      final randomWord =
          availableWords[Random().nextInt(availableWords.length)]['word']
              as String;

      _usedWords.add(randomWord);
      resetGame(newWord: randomWord.toUpperCase());
    }
  }

  void guessLetter(String letter) async {
    if (game.value.guessedLetters.contains(letter) || game.value.isGameOver)
      return;

    await _audioService.playGuessSound(game.value.word.contains(letter));
    if (!game.value.word.contains(letter)) {
      await _vibrationService.vibrate();
    }

    game.update((val) {
      val?.guessedLetters.add(letter);

      if (!val!.word.contains(letter)) {
        val.attemptsLeft--;
      }

      val.hiddenWord = val.word
          .split('')
          .map((char) {
            return val.guessedLetters.contains(char) ? char : '_';
          })
          .join(' ');

      if (!val.hiddenWord.contains('_')) {
        val.isGameOver = true;
        val.isWinner = true;
        val.score += calculateScore();
        if (val.score > highScore.value) {
          highScore.value = val.score;
          _dbHelper.saveHighScore(val.score);
        }
        showConfetti.value = true;
        _audioService.playWinSound();
        updateGameStats(true);
        Future.delayed(Duration(seconds: 3), () {
          showConfetti.value = false;
          checkLevelCompletion();
        });
      } else if (val.attemptsLeft <= 0) {
        val.isGameOver = true;
        _audioService.playLoseSound();
        updateGameStats(false);
        checkLevelCompletion();
      }
    });
  }

  void updateGameStats(bool won) {
    gameStats['games_played'] = (gameStats['games_played'] ?? 0) + 1;

    if (won) {
      gameStats['games_won'] = (gameStats['games_won'] ?? 0) + 1;
      gameStats['current_streak'] = (gameStats['current_streak'] ?? 0) + 1;

      if ((gameStats['current_streak'] ?? 0) > (gameStats['max_streak'] ?? 0)) {
        gameStats['max_streak'] = gameStats['current_streak']!;
      }
    } else {
      gameStats['current_streak'] = 0;
    }

    _dbHelper.updateGameStats(won);
  }

  Future<void> resetStats() async {
    highScore.value = 0;
    gameStats.assignAll({
      'games_played': 0,
      'games_won': 0,
      'current_streak': 0,
      'max_streak': 0,
    });

    await _dbHelper.saveHighScore(0);
    await _dbHelper.resetProgress();
    resetToFirstLevel();
  }

  void checkLevelCompletion() {
    if (game.value.isWinner) {
      if (game.value.level < game.value.maxLevel) {
        game.update((val) {
          val?.level++;
          val?.levelCompleted = true;
          val?.isGameOver = false;
        });
        _showLevelUpDialog();
      } else {
        _showGameCompleteDialog();
      }
    } else if (game.value.isGameOver && !game.value.isWinner) {
      _showRetryDialog();
    }
  }

  void _showLevelUpDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Level ${game.value.level - 1} Completed!'),
        content: Text('Moving to level ${game.value.level}'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              startNextLevel();
            },
            child: Text('Continue'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showGameCompleteDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Game Completed!'),
        content: Text(
          'You finished all levels with score: ${game.value.score}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              resetToFirstLevel();
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Level Failed'),
        content: Text('Try again?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              retryLevel();
            },
            child: Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              resetToFirstLevel();
            },
            child: Text('Main Menu'),
          ),
        ],
      ),
    );
  }

  void startNextLevel() {
    String newDifficulty = game.value.difficulty;
    if (game.value.level % 2 == 0) {
      if (game.value.difficulty == 'Easy') newDifficulty = 'Medium';
      if (game.value.difficulty == 'Medium') newDifficulty = 'Hard';
    }

    game.update((val) {
      val?.difficulty = newDifficulty;
      val?.levelCompleted = false;
    });

    fetchRandomWord(level: game.value.level);
  }

  void retryLevel() {
    resetGame(newWord: game.value.word);
  }

  void resetToFirstLevel() {
    game.update((val) {
      val?.level = 1;
      val?.score = 0;
    });
    fetchRandomWord();
  }

  int calculateScore() {
    int baseScore = game.value.word.length * 10;
    switch (game.value.difficulty) {
      case 'Easy':
        return baseScore;
      case 'Medium':
        return baseScore * 2;
      case 'Hard':
        return baseScore * 3;
      default:
        return baseScore;
    }
  }

  void useHint() {
    if (game.value.hintsLeft > 0 && !game.value.isGameOver) {
      final unrevealed = game.value.word
          .split('')
          .firstWhere(
            (letter) => !game.value.guessedLetters.contains(letter),
            orElse: () => '',
          );

      if (unrevealed.isNotEmpty) {
        game.update((val) {
          val?.hintsLeft--;
          val?.guessedLetters.add(unrevealed);
          val?.hiddenWord = val.word
              .split('')
              .map((char) {
                return val.guessedLetters.contains(char) ? char : '_';
              })
              .join(' ');
        });
        _audioService.playHintSound();
      }
    }
  }

  void startTimer() {
    _timer?.cancel();
    game.update((val) => val?.timeLeft = 60);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (game.value.timeLeft > 0) {
        game.update((val) => val?.timeLeft--);
      } else {
        timer.cancel();
        game.update((val) => val?.isGameOver = true);
        _audioService.playLoseSound();
        checkLevelCompletion();
      }
    });
  }

  void changeDifficulty(String difficulty) {
    game.update((val) => val?.difficulty = difficulty);
    switch (difficulty) {
      case 'Easy':
        game.update((val) => val?.attemptsLeft = 8);
        break;
      case 'Medium':
        game.update((val) => val?.attemptsLeft = 6);
        break;
      case 'Hard':
        game.update((val) => val?.attemptsLeft = 4);
        break;
    }
    fetchRandomWord();
  }

  void changeCategory(String category) {
    game.update((val) => val?.category = category);
    fetchRandomWord(category: category);
  }

  void resetGame({String? newWord}) {
    _timer?.cancel();
    _usedWords.clear();
    game.update((val) {
      val?.word = newWord ?? val.word;
      val?.hiddenWord = '_ ' * val!.word.length;
      val?.attemptsLeft = val.difficulty == 'Easy'
          ? 8
          : val.difficulty == 'Hard'
          ? 4
          : 6;
      val?.guessedLetters = [];
      val?.isGameOver = false;
      val?.isWinner = false;
      val?.hintsLeft = 3;
      val?.currentHint = '';
    });
    if (game.value.timerEnabled) startTimer();
  }
}
