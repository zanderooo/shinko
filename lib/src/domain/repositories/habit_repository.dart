import 'package:shinko/src/domain/entities/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<Habit?> getHabitById(String id);
  Future<void> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<bool> completeHabit(String id, DateTime date);
  Future<bool> uncompleteHabit(String id, DateTime date);
  Future<List<Habit>> getHabitsForDate(DateTime date);
  Future<List<Habit>> getActiveHabits();
  Future<Map<String, int>> getStreakStats();
}