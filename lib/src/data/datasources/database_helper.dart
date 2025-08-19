import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'shinko.db';
  static const _databaseVersion = 1;

  // Table names
  static const tableHabits = 'habits';
  static const tableUserProgress = 'user_progress';
  static const tableAchievements = 'achievements';

  // Column names for habits table
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDescription = 'description';
  static const columnType = 'type';
  static const columnCategory = 'category';
  static const columnDifficulty = 'difficulty';
  static const columnTargetCount = 'target_count';
  static const columnCurrentStreak = 'current_streak';
  static const columnBestStreak = 'best_streak';
  static const columnTotalCompletions = 'total_completions';
  static const columnCreatedAt = 'created_at';
  static const columnLastCompletedAt = 'last_completed_at';
  static const columnCompletionHistory = 'completion_history';
  static const columnIsActive = 'is_active';
  static const columnReminderTime = 'reminder_time';
  static const columnXpValue = 'xp_value';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableHabits (
        $columnId TEXT PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnDescription TEXT,
        $columnType INTEGER NOT NULL,
        $columnCategory INTEGER NOT NULL,
        $columnDifficulty INTEGER NOT NULL,
        $columnTargetCount INTEGER DEFAULT 1,
        $columnCurrentStreak INTEGER DEFAULT 0,
        $columnBestStreak INTEGER DEFAULT 0,
        $columnTotalCompletions INTEGER DEFAULT 0,
        $columnCreatedAt TEXT NOT NULL,
        $columnLastCompletedAt TEXT,
        $columnCompletionHistory TEXT,
        $columnIsActive INTEGER DEFAULT 1,
        $columnReminderTime TEXT,
        $columnXpValue INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableUserProgress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_xp INTEGER DEFAULT 0,
        current_level INTEGER DEFAULT 1,
        xp_to_next_level INTEGER DEFAULT 100,
        daily_streak INTEGER DEFAULT 0,
        best_daily_streak INTEGER DEFAULT 0,
        weekly_streak INTEGER DEFAULT 0,
        best_weekly_streak INTEGER DEFAULT 0,
        total_habits_completed INTEGER DEFAULT 0,
        total_perfect_days INTEGER DEFAULT 0,
        last_active_date TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAchievements (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type INTEGER NOT NULL,
        rarity INTEGER NOT NULL,
        xp_reward INTEGER NOT NULL,
        icon_data TEXT NOT NULL,
        is_unlocked INTEGER DEFAULT 0,
        unlocked_at TEXT,
        progress INTEGER DEFAULT 0,
        target INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Insert initial user progress
    await db.insert(tableUserProgress, {
      'total_xp': 0,
      'current_level': 1,
      'xp_to_next_level': 100,
      'daily_streak': 0,
      'best_daily_streak': 0,
      'weekly_streak': 0,
      'best_weekly_streak': 0,
      'total_habits_completed': 0,
      'total_perfect_days': 0,
      'last_active_date': null,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert initial achievements
    await _insertInitialAchievements(db);
  }

  Future<void> _insertInitialAchievements(Database db) async {
    final achievements = [
      {
        'id': 'first_habit',
        'title': 'First Steps',
        'description': 'Create your first habit',
        'type': 0, // category
        'rarity': 0, // common
        'xp_reward': 10,
        'icon_data': '🌱',
        'created_at': DateTime.now().toIso8601String(),
        'target': 1,
      },
      {
        'id': 'streak_3',
        'title': 'Consistent Beginner',
        'description': 'Maintain a 3-day streak',
        'type': 0, // streak
        'rarity': 0, // common
        'xp_reward': 25,
        'icon_data': '🔥',
        'created_at': DateTime.now().toIso8601String(),
        'target': 3,
      },
      {
        'id': 'streak_7',
        'title': 'Week Warrior',
        'description': 'Complete a 7-day streak',
        'type': 0, // streak
        'rarity': 1, // rare
        'xp_reward': 50,
        'icon_data': '⚡',
        'created_at': DateTime.now().toIso8601String(),
        'target': 7,
      },
      {
        'id': 'streak_30',
        'title': 'Monthly Master',
        'description': 'Achieve a 30-day streak',
        'type': 0, // streak
        'rarity': 2, // epic
        'xp_reward': 100,
        'icon_data': '👑',
        'created_at': DateTime.now().toIso8601String(),
        'target': 30,
      },
      {
        'id': 'perfect_day',
        'title': 'Perfect Day',
        'description': 'Complete all habits for one day',
        'type': 4, // perfection
        'rarity': 1, // rare
        'xp_reward': 30,
        'icon_data': '✨',
        'created_at': DateTime.now().toIso8601String(),
        'target': 1,
      },
      {
        'id': 'level_5',
        'title': 'Rising Star',
        'description': 'Reach level 5',
        'type': 2, // level
        'rarity': 1, // rare
        'xp_reward': 75,
        'icon_data': '🌟',
        'created_at': DateTime.now().toIso8601String(),
        'target': 5,
      },
    ];

    for (final achievement in achievements) {
      await db.insert(tableAchievements, achievement);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}