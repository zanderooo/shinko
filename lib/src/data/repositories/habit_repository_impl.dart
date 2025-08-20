import 'package:sqflite/sqflite.dart';
import 'package:shinko/src/data/datasources/database_helper.dart';
import 'package:shinko/src/data/models/habit_model.dart';
import 'package:shinko/src/domain/entities/habit.dart';
import 'package:shinko/src/domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final DatabaseHelper _databaseHelper;

  HabitRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Habit>> getAllHabits() async {
    final db = await _databaseHelper.database;
    // debug: loading all habits
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableHabits,
      orderBy: '${DatabaseHelper.columnCreatedAt} DESC',
    );
    // debug: found habits count
    if (maps.isNotEmpty) {
      // debug: first habit map for diagnostics
    }
    return maps.map((map) => HabitModel.fromJson(map).toEntity()).toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableHabits,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return HabitModel.fromJson(maps.first).toEntity();
  }

  @override
  Future<void> createHabit(Habit habit) async {
    final db = await _databaseHelper.database;
    // debug: creating habit
    await db.insert(
      DatabaseHelper.tableHabits,
      HabitModel.fromEntity(habit).toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // debug: habit inserted
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.tableHabits,
      HabitModel.fromEntity(habit).toJson(),
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [habit.id],
    );
  }

  @override
  Future<void> deleteHabit(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableHabits,
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<bool> completeHabit(String id, DateTime date) async {
    final habit = await getHabitById(id);
    if (habit == null) return false;

    
    final int daySinceEpoch = date.difference(DateTime(1970, 1, 1)).inDays;
    final updatedHistory = List<int>.from(habit.completionHistory);
    
    final alreadyCompletedToday = updatedHistory.contains(daySinceEpoch);
    if (!alreadyCompletedToday) {
      updatedHistory.add(daySinceEpoch);
      updatedHistory.sort();
    } else {
      // No-op if already completed today
      return false;
    }

    final updatedHabit = habit.copyWith(
      totalCompletions: habit.totalCompletions + 1,
      lastCompletedAt: date,
      completionHistory: updatedHistory,
      currentStreak: _calculateCurrentStreak(updatedHistory),
      bestStreak: _calculateBestStreak(updatedHistory, habit.bestStreak),
    );

    await updateHabit(updatedHabit);
    return true;
  }

  @override
  Future<bool> uncompleteHabit(String id, DateTime date) async {
    final habit = await getHabitById(id);
    if (habit == null) return false;

    final int daySinceEpoch = date.difference(DateTime(1970, 1, 1)).inDays;
    final updatedHistory = List<int>.from(habit.completionHistory)
      ..remove(daySinceEpoch);

    final updatedHabit = habit.copyWith(
      totalCompletions: habit.totalCompletions > 0 ? habit.totalCompletions - 1 : 0,
      completionHistory: updatedHistory,
      currentStreak: _calculateCurrentStreak(updatedHistory),
      bestStreak: _calculateBestStreak(updatedHistory, habit.bestStreak),
    );

    await updateHabit(updatedHabit);
    return true;
  }

  @override
  Future<List<Habit>> getHabitsForDate(DateTime date) async {
    final habits = await getAllHabits();
    return habits.where((habit) => habit.isActive).toList();
  }

  @override
  Future<List<Habit>> getActiveHabits() async {
    final habits = await getAllHabits();
    return habits.where((habit) => habit.isActive).toList();
  }

  @override
  Future<Map<String, int>> getStreakStats() async {
    final habits = await getAllHabits();
    int totalStreak = 0;
    int maxStreak = 0;
    
    for (final habit in habits) {
      totalStreak += habit.currentStreak;
      maxStreak = maxStreak > habit.bestStreak ? maxStreak : habit.bestStreak;
    }

    return {
      'totalCurrentStreak': totalStreak,
      'maxStreak': maxStreak,
      'habitCount': habits.length,
    };
  }

  int _calculateCurrentStreak(List<int> completionHistory) {
    if (completionHistory.isEmpty) return 0;

    final today = DateTime.now();
    final todayEpoch = today.difference(DateTime(1970, 1, 1)).inDays;
    
    int streak = 0;
    int currentDay = todayEpoch;
    
    // Check backwards from today
    while (completionHistory.contains(currentDay)) {
      streak++;
      currentDay--;
    }
    
    return streak;
  }

  int _calculateBestStreak(List<int> completionHistory, int currentBest) {
    if (completionHistory.isEmpty) return currentBest;

    int bestStreak = 0;
    int currentStreak = 1;

    for (int i = 1; i < completionHistory.length; i++) {
      if (completionHistory[i] - completionHistory[i - 1] == 1) {
        currentStreak++;
      } else {
        bestStreak = bestStreak > currentStreak ? bestStreak : currentStreak;
        currentStreak = 1;
      }
    }
    
    bestStreak = bestStreak > currentStreak ? bestStreak : currentStreak;
    return bestStreak > currentBest ? bestStreak : currentBest;
  }
}