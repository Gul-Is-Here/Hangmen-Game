import 'dart:math';

import 'package:get/get.dart';
import 'package:hangman_game/database/db_helper.dart';
import 'package:hangman_game/models/hangman_model.dart';

class HangmanController extends GetxController {
  final DBHelper _dbHelper = DBHelper();

  // Initialize with a modifiable list
  final Rx<HangmanModel> hangman = HangmanModel(
    word: '',
    hiddenWord: '',
    attemptsLeft: 6,
    guessedLetters: [], // Now modifiable
  ).obs;

  @override
  void onInit() {
    fetchRandomWord();
    super.onInit();
  }

  Future<void> fetchRandomWord() async {
    final words = await _dbHelper.getWords();
    if (words.isNotEmpty) {
      final randomWord =
          words[Random().nextInt(words.length)]['word'] as String;
      hangman.value = HangmanModel(
        word: randomWord.toUpperCase(),
        hiddenWord: '_ ' * randomWord.length,
        attemptsLeft: 6,
        guessedLetters: [],
        isGameOver: false,
        isWinner: false,
      );
    }
  }

  void guessLetter(String letter) {
    if (hangman.value.guessedLetters.contains(letter) ||
        hangman.value.isGameOver)
      return;

    // Create a new list from the existing one
    final newGuessedLetters = List<String>.from(hangman.value.guessedLetters);
    newGuessedLetters.add(letter);

    int newAttemptsLeft = hangman.value.attemptsLeft;
    if (!hangman.value.word.contains(letter)) {
      newAttemptsLeft--;
    }

    // Update hidden word
    final newHiddenWord = hangman.value.word
        .split('')
        .map((char) {
          return newGuessedLetters.contains(char) ? char : '_';
        })
        .join(' ');

    // Check win/lose conditions
    final isGameOver = newAttemptsLeft <= 0 || !newHiddenWord.contains('_');
    final isWinner = isGameOver && newAttemptsLeft > 0;

    // Update the entire model at once
    hangman.value = HangmanModel(
      word: hangman.value.word,
      hiddenWord: newHiddenWord,
      attemptsLeft: newAttemptsLeft,
      guessedLetters: newGuessedLetters,
      isGameOver: isGameOver,
      isWinner: isWinner,
    );
  }

  void resetGame() {
    hangman.value = HangmanModel(
      word: hangman.value.word,
      hiddenWord: '_ ' * hangman.value.word.length,
      attemptsLeft: 6,
      guessedLetters: [],
      isGameOver: false,
      isWinner: false,
    );
  }
}
