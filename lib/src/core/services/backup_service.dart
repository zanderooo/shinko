import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shinko/src/data/datasources/database_helper.dart';

class BackupService {
  final DatabaseHelper _databaseHelper;

  BackupService(this._databaseHelper);

  Future<String> exportToJsonString() async {
    final db = await _databaseHelper.database;

    final habits = await db.query(DatabaseHelper.tableHabits);
    final userProgress = await db.query(DatabaseHelper.tableUserProgress);
    final achievements = await db.query(DatabaseHelper.tableAchievements);

    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habits,
      'user_progress': userProgress,
      'achievements': achievements,
    };

    return jsonEncode(payload);
  }

  Future<void> importFromJsonString(String jsonString) async {
    final db = await _databaseHelper.database;
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    final batch = db.batch();

    // Clear existing data
    batch.delete(DatabaseHelper.tableHabits);
    batch.delete(DatabaseHelper.tableUserProgress);
    batch.delete(DatabaseHelper.tableAchievements);

    // Insert habits
    final habits = (data['habits'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    for (final habit in habits) {
      batch.insert(DatabaseHelper.tableHabits, habit, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Insert user progress (ensure at least one row exists)
    final userProgress = (data['user_progress'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    if (userProgress.isNotEmpty) {
      for (final row in userProgress) {
        batch.insert(DatabaseHelper.tableUserProgress, row, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } else {
      batch.insert(DatabaseHelper.tableUserProgress, {
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
    }

    // Insert achievements
    final achievements = (data['achievements'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    for (final achievement in achievements) {
      batch.insert(DatabaseHelper.tableAchievements, achievement, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }
}


