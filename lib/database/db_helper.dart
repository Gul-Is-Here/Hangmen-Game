import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'hangman.db');

    return await openDatabase(
      dbPath,
      version: 4, // bump so existing installs upgrade and seed 100 words
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS game_stats(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              level INTEGER DEFAULT 1,
              games_played INTEGER DEFAULT 0,
              games_won INTEGER DEFAULT 0
            )
          ''');
          final stats = await db.query('game_stats', limit: 1);
          if (stats.isEmpty) {
            await db.insert('game_stats', {
              'level': 1,
              'games_played': 0,
              'games_won': 0,
            });
          }
        }
        if (oldVersion < 3) {
          await db.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_words_unique ON words(word, category, difficulty)',
          );
        }
        if (oldVersion < 4) {
          await _insertHundredWords(db); // idempotent (unique index)
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS words(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        difficulty TEXT NOT NULL,   -- Easy | Medium | Hard
        category TEXT NOT NULL,     -- General | Animals | Countries | Food
        level_group INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS scores(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        high_score INTEGER DEFAULT 0,
        current_level INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS game_stats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        level INTEGER DEFAULT 1,
        games_played INTEGER DEFAULT 0,
        games_won INTEGER DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_words_unique ON words(word, category, difficulty)',
    );
  }

  Future<void> _seedInitialData(Database db) async {
    final scores = await db.query('scores', limit: 1);
    if (scores.isEmpty) {
      await db.insert('scores', {'high_score': 0, 'current_level': 1});
    }
    final stats = await db.query('game_stats', limit: 1);
    if (stats.isEmpty) {
      await db.insert('game_stats', {
        'level': 1,
        'games_played': 0,
        'games_won': 0,
      });
    }
    await _insertHundredWords(db);
  }

  Future<void> _insertHundredWords(Database db) async {
    // 25 each = 100 total
    final general = [
      'FLUTTER',
      'DART',
      'PROGRAMMING',
      'COMPUTER',
      'ALGORITHM',
      'VARIABLE',
      'FUNCTION',
      'WIDGET',
      'PACKAGE',
      'DATABASE',
      'NETWORK',
      'DEBUGGER',
      'COMPILER',
      'SYNTAX',
      'INTERFACE',
      'OBJECT',
      'CLASS',
      'MODULE',
      'LIBRARY',
      'FRAMEWORK',
      'ASYNC',
      'FUTURE',
      'STREAM',
      'BUILDER',
      'CONTEXT',
    ];
    final animals = [
      'ELEPHANT',
      'GIRAFFE',
      'KANGAROO',
      'CROCODILE',
      'DOLPHIN',
      'BUTTERFLY',
      'CHAMELEON',
      'WOODPECKER',
      'PORCUPINE',
      'SQUIRREL',
      'HIPPOPOTAMUS',
      'RHINOCEROS',
      'ALLIGATOR',
      'FLAMINGO',
      'PEACOCK',
      'OSTRICH',
      'PENGUIN',
      'OCTOPUS',
      'JELLYFISH',
      'STARFISH',
      'SEAHORSE',
      'LADYBUG',
      'FIREFLY',
      'DRAGONFLY',
      'MANTIS',
    ];
    final countries = [
      'PAKISTAN',
      'AUSTRALIA',
      'BRAZIL',
      'CANADA',
      'GERMANY',
      'FRANCE',
      'ITALY',
      'SPAIN',
      'PORTUGAL',
      'NETHERLANDS',
      'BELGIUM',
      'SWEDEN',
      'NORWAY',
      'DENMARK',
      'FINLAND',
      'SWITZERLAND',
      'AUSTRIA',
      'HUNGARY',
      'POLAND',
      'ROMANIA',
      'GREECE',
      'TURKEY',
      'EGYPT',
      'NIGERIA',
      'KENYA',
    ];
    final food = [
      'PIZZA',
      'SPAGHETTI',
      'AVOCADO',
      'BURRITO',
      'SANDWICH',
      'HAMBURGER',
      'LASAGNA',
      'SUSHI',
      'RAMEN',
      'DUMPLING',
      'PANCAKES',
      'WAFFLES',
      'CROISSANT',
      'BROWNIES',
      'CUPCAKES',
      'MUFFINS',
      'DOUGHNUT',
      'OMELETTE',
      'MEATBALLS',
      'KEBAB',
      'BIRYANI',
      'KARAHI',
      'CHAPLI',
      'PARATHA',
      'SAMOSA',
    ];

    String diff(String w, String cat) {
      const hard = {
        'PROGRAMMING',
        'ALGORITHM',
        'COMPILER',
        'FRAMEWORK',
        'STREAM',
        'KANGAROO',
        'CROCODILE',
        'CHAMELEON',
        'WOODPECKER',
        'PORCUPINE',
        'HIPPOPOTAMUS',
        'RHINOCEROS',
        'ALLIGATOR',
        'NETHERLANDS',
        'SWITZERLAND',
        'PORTUGAL',
        'CROISSANT',
        'LASAGNA',
        'DUMPLING',
        'MEATBALLS',
        'BIRYANI',
        'KARAHI',
      };
      const easy = {
        'DART',
        'OBJECT',
        'CLASS',
        'SYNTAX',
        'WIDGET',
        'PIZZA',
        'SAMOSA',
        'PARATHA',
        'HAMBURGER',
        'PANCAKES',
        'WAFFLES',
        'PENGUIN',
        'LADYBUG',
        'FIREFLY',
        'PAKISTAN',
        'BRAZIL',
        'CANADA',
        'FRANCE',
        'ITALY',
        'SPAIN',
        'EGYPT',
        'KENYA',
        'KEBAB',
      };
      if (hard.contains(w)) return 'Hard';
      if (easy.contains(w)) return 'Easy';
      return 'Medium';
    }

    Future<void> insertBatch(List<String> list, String category) async {
      final batch = db.batch();
      for (final w in list) {
        final d = diff(w, category);
        final group = (d == 'Easy')
            ? 1
            : (d == 'Medium')
            ? 2
            : 3;
        batch.insert(
          'words',
          {
            'word': w,
            'difficulty': d,
            'category': category,
            'level_group': group,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore, // prevent duplicates
        );
      }
      await batch.commit(noResult: true);
    }

    await insertBatch(general, 'General');
    await insertBatch(animals, 'Animals');
    await insertBatch(countries, 'Countries');
    await insertBatch(food, 'Food');
  }

  // ----- Queries -----

  int _groupForLevel(int level) {
    final g = (level / 5).ceil();
    return g < 1 ? 1 : (g > 3 ? 3 : g);
  }

  Future<List<Map<String, dynamic>>> getWordsForLevel(
    int level,
    String category,
  ) async {
    final db = await database;
    return db.query(
      'words',
      where: 'level_group = ? AND category = ?',
      whereArgs: [_groupForLevel(level), category],
      orderBy: 'RANDOM()',
    );
  }

  Future<Map<String, dynamic>?> getRandomWord({
    String? category,
    String? difficulty,
    int? level,
    int? excludeId,
  }) async {
    final db = await database;
    final parts = <String>[];
    final args = <dynamic>[];

    if (category != null) {
      parts.add('category = ?');
      args.add(category);
    }
    if (difficulty != null) {
      parts.add('difficulty = ?');
      args.add(difficulty);
    }
    if (level != null) {
      parts.add('level_group = ?');
      args.add(_groupForLevel(level));
    }
    if (excludeId != null) {
      parts.add('id != ?');
      args.add(excludeId);
    }

    final whereClause = parts.isNotEmpty ? parts.join(' AND ') : null;

    final rows = await db.query(
      'words',
      where: whereClause,
      whereArgs: args,
      orderBy: 'RANDOM()',
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  Future<List<Map<String, dynamic>>> getWords({
    String? category,
    String? difficulty,
  }) async {
    final db = await database;
    final parts = <String>[];
    final args = <dynamic>[];

    if (category != null) {
      parts.add('category = ?');
      args.add(category);
    }
    if (difficulty != null) {
      parts.add('difficulty = ?');
      args.add(difficulty);
    }

    final whereClause = parts.isNotEmpty ? parts.join(' AND ') : null;
    return db.query('words', where: whereClause, whereArgs: args);
  }

  Future<int> countWords() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) AS c FROM words');
    return (res.first['c'] as int?) ?? 0;
  }

  // ----- Scores & Stats -----

  Future<int> getHighScore() async {
    final db = await database;
    final result = await db.query('scores', limit: 1);
    if (result.isEmpty) {
      await db.insert('scores', {'id': 1, 'high_score': 0, 'current_level': 1});
      return 0;
    }
    final v = result.first['high_score'];
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  Future<int> getCurrentLevel() async {
    final db = await database;
    final result = await db.query('scores', limit: 1);
    if (result.isEmpty) return 1;
    final v = result.first['current_level'];
    if (v == null) return 1;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 1;
  }

  Future<void> saveHighScore(int score) async {
    final db = await database;
    final updated = await db.update(
      'scores',
      {'high_score': score},
      where: 'id = ?',
      whereArgs: const [1],
    );
    if (updated == 0) {
      await db.insert('scores', {
        'id': 1,
        'high_score': score,
        'current_level': 1,
      });
    }
  }

  Future<void> saveCurrentLevel(int level) async {
    final db = await database;
    final updated = await db.update(
      'scores',
      {'current_level': level},
      where: 'id = ?',
      whereArgs: const [1],
    );
    if (updated == 0) {
      await db.insert('scores', {
        'id': 1,
        'high_score': 0,
        'current_level': level,
      });
    }
  }

  Future<Map<String, dynamic>> getGameStats() async {
    final db = await database;
    final result = await db.query('game_stats', limit: 1);
    if (result.isEmpty) {
      await db.insert('game_stats', {
        'id': 1,
        'level': 1,
        'games_played': 0,
        'games_won': 0,
      });
      return {'id': 1, 'level': 1, 'games_played': 0, 'games_won': 0};
    }
    return result.first;
  }

  Future<void> updateGameStats(bool won) async {
    final db = await database;
    await db.execute(
      'UPDATE game_stats SET games_played = games_played + 1, games_won = games_won + ? WHERE id = 1',
      [won ? 1 : 0],
    );
  }

  Future<void> resetProgress() async {
    final db = await database;
    await db.update('scores', {
      'high_score': 0,
      'current_level': 1,
    }, where: 'id = 1');
    await db.update('game_stats', {
      'games_played': 0,
      'games_won': 0,
      'level': 1,
    }, where: 'id = 1');
  }
}
