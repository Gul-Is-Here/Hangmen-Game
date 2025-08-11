class GameModel {
  String word;
  String hiddenWord;
  int attemptsLeft;
  List<String> guessedLetters;
  bool isGameOver;
  bool isWinner;
  int score;
  int timeLeft;
  String difficulty;
  String category;
  int hintsLeft;
  String currentHint;
  bool timerEnabled;
   int level;
   int maxLevel;
   bool levelCompleted;

  GameModel({
    required this.word,
    required this.hiddenWord,
    this.attemptsLeft = 6,
    this.guessedLetters = const [],
    this.isGameOver = false,
    this.isWinner = false,
    this.score = 0,
    this.timeLeft = 60,
    this.difficulty = 'Medium',
    this.category = 'General',
    this.hintsLeft = 3,
    this.currentHint = '',
    this.timerEnabled = false,
    this.level = 1,
    this.maxLevel = 5,
    this.levelCompleted = false,
  });

  GameModel copyWith({
    int? level,
    int? maxLevel,
    bool? levelCompleted,
    String? word,
    String? hiddenWord,
    int? attemptsLeft,
    List<String>? guessedLetters,
    bool? isGameOver,
    bool? isWinner,
    int? score,
    int? timeLeft,
    String? difficulty,
    String? category,
    int? hintsLeft,
    String? currentHint,
    bool? timerEnabled,
  }) {
    return GameModel(
      word: word ?? this.word,
      hiddenWord: hiddenWord ?? this.hiddenWord,
      attemptsLeft: attemptsLeft ?? this.attemptsLeft,
      guessedLetters: guessedLetters ?? this.guessedLetters,
      isGameOver: isGameOver ?? this.isGameOver,
      isWinner: isWinner ?? this.isWinner,
      score: score ?? this.score,
      timeLeft: timeLeft ?? this.timeLeft,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      hintsLeft: hintsLeft ?? this.hintsLeft,
      currentHint: currentHint ?? this.currentHint,
      timerEnabled: timerEnabled ?? this.timerEnabled,
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      levelCompleted: levelCompleted ?? this.levelCompleted,
    );
  }
}
