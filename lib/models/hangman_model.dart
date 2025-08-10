class HangmanModel {
  String word;
  String hiddenWord;
  int attemptsLeft;
  List<String> guessedLetters;
  bool isGameOver;
  bool isWinner;

  HangmanModel({
    required this.word,
    required this.hiddenWord,
    this.attemptsLeft = 6,
    this.guessedLetters = const [],
    this.isGameOver = false,
    this.isWinner = false,
  });
}