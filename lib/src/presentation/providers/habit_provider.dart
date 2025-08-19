import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinko/src/domain/entities/habit.dart';
import 'package:shinko/src/domain/repositories/habit_repository.dart';
import 'package:shinko/src/presentation/providers/user_progress_provider.dart';
import 'package:shinko/src/core/navigator_key.dart';

class HabitProvider with ChangeNotifier {
  final HabitRepository _habitRepository;
  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _error;

  HabitProvider(this._habitRepository) {
    loadHabits();
  }

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Habit> get activeHabits => _habits.where((h) => h.isActive).toList();
  List<Habit> get pendingTodayHabits => _habits.where((habit) {
    final today = DateTime.now();
    final todayEpoch = today.difference(DateTime(1970, 1, 1)).inDays;
    return habit.isActive && !habit.completionHistory.contains(todayEpoch);
  }).toList();

  List<Habit> get completedTodayHabits => _habits.where((habit) {
    final today = DateTime.now();
    final todayEpoch = today.difference(DateTime(1970, 1, 1)).inDays;
    return habit.isActive && habit.completionHistory.contains(todayEpoch);
  }).toList();

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      final habits = await _habitRepository.getAllHabits();
      _habits = habits;
    } catch (e) {
      _error = 'Failed to load habits: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> addHabit(Habit habit) async {
    try {
      await _habitRepository.createHabit(habit);
      await loadHabits();
    } catch (e) {
      _error = 'Failed to add habit: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _habitRepository.updateHabit(habit);
      await loadHabits();
    } catch (e) {
      _error = 'Failed to update habit: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _habitRepository.deleteHabit(id);
      await loadHabits();
    } catch (e) {
      _error = 'Failed to delete habit: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> completeHabit(String id) async {
    try {
      final habit = getHabitById(id);
      if (habit == null) return;

      await _habitRepository.completeHabit(id, DateTime.now());
      await loadHabits();
      
      // Award XP with animation
      final context = navigatorKey.currentContext;
      if (context != null) {
        final userProgressProvider = 
            Provider.of<UserProgressProvider>(context, listen: false);
        await userProgressProvider.addXPWithAnimation(habit.xpValue, 'habit_completion');
        
        // Update habit completion count
        await userProgressProvider.incrementHabitCompletion();
      }
      
    } catch (e) {
      _error = 'Failed to complete habit: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> uncompleteHabit(String id) async {
    try {
      await _habitRepository.uncompleteHabit(id, DateTime.now());
      await loadHabits();
    } catch (e) {
      _error = 'Failed to uncomplete habit: ${e.toString()}';
      notifyListeners();
    }
  }

  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<String, int> getStreakStats() {
    int totalCurrentStreak = 0;
    int maxStreak = 0;
    
    for (final habit in activeHabits) {
      totalCurrentStreak += habit.currentStreak;
      maxStreak = maxStreak > habit.bestStreak ? maxStreak : habit.bestStreak;
    }

    return {
      'totalCurrentStreak': totalCurrentStreak,
      'maxStreak': maxStreak,
      'habitCount': activeHabits.length,
      'completedToday': completedTodayHabits.length,
      'pendingToday': pendingTodayHabits.length,
    };
  }

  List<Habit> getHabitsByCategory(HabitCategory category) {
    return _habits.where((h) => h.category == category).toList();
  }

  List<Habit> searchHabits(String query) {
    if (query.isEmpty) return _habits;
    return _habits.where((h) =>
        h.title.toLowerCase().contains(query.toLowerCase()) ||
        (h.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  double getCompletionRateForDay(DateTime date) {
    if (_habits.isEmpty) return 0.0;
    
    final dayEpoch = date.difference(DateTime(1970, 1, 1)).inDays;
    final activeHabitsForDay = _habits.where((h) {
      final habitCreatedEpoch = h.createdAt.difference(DateTime(1970, 1, 1)).inDays;
      return h.isActive && habitCreatedEpoch <= dayEpoch;
    }).toList();
    
    if (activeHabitsForDay.isEmpty) return 0.0;
    
    final completedHabits = activeHabitsForDay.where((h) => 
      h.completionHistory.contains(dayEpoch)
    ).length;
    
    return completedHabits / activeHabitsForDay.length;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }


}