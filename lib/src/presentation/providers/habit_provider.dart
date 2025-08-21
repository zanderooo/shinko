import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinko/src/domain/entities/habit.dart';
import 'package:shinko/src/domain/repositories/habit_repository.dart';
import 'package:shinko/src/presentation/providers/user_progress_provider.dart';
import 'package:shinko/src/presentation/providers/quest_provider.dart';
import 'package:shinko/src/core/navigator_key.dart';
import 'package:shinko/src/core/services/feedback_service.dart';
import 'package:shinko/src/core/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

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
      // Schedule evening nudges
      await _scheduleEveningNudges();
      final buildContext = navigatorKey.currentContext;
      final questProvider = buildContext != null && buildContext.mounted
          ? Provider.of<QuestProvider>(buildContext, listen: false)
          : null;
      questProvider?.onHabitsChanged();
    } catch (e) {
      _error = 'Failed to load habits: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> _scheduleEveningNudges() async {
    // 8 PM: One habit left nudge (generic message)
    final now = DateTime.now();
    final eight = DateTime(now.year, now.month, now.day, 20, 0);
    final ten = DateTime(now.year, now.month, now.day, 22, 0);
    final eightTz = tz.TZDateTime.from(eight, tz.local);
    final tenTz = tz.TZDateTime.from(ten, tz.local);
    try {
      await NotificationService().scheduleOneTime(880001, eightTz, 'Almost there', 'If one habit remains, finish it now!');
      await NotificationService().scheduleOneTime(880002, tenTz, 'Protect your streak', 'Don\'t let today slip. Use a streak freeze if needed.');
    } catch (_) {}
  }



  Future<void> addHabit(Habit habit) async {
    try {
      await _habitRepository.createHabit(habit);
      await loadHabits();

      if (habit.reminderTime != null && habit.reminderTime!.contains(':')) {
        final parts = habit.reminderTime!.split(':');
        final hour = int.tryParse(parts[0]) ?? 8;
        final minute = int.tryParse(parts[1]) ?? 0;
        await NotificationService().scheduleDaily(habit.id, hour, minute, 'Reminder: ${habit.title}', 'Time to keep your streak.');
      }

      final buildContext = navigatorKey.currentContext;
      if (buildContext != null && buildContext.mounted) {
        final userProgressProvider = Provider.of<UserProgressProvider>(buildContext, listen: false);
        await userProgressProvider.incrementHabitCompletion(habit.category);
      }
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
      await NotificationService().cancelForHabit(id);
    } catch (e) {
      _error = 'Failed to delete habit: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> completeHabit(String id) async {
    try {
      final habit = getHabitById(id);
      if (habit == null) return;

      // Capture provider before async gaps to avoid using BuildContext after awaits
      final buildContext = navigatorKey.currentContext;
      UserProgressProvider? userProgressProvider;
      if (buildContext != null && buildContext.mounted) {
        userProgressProvider = Provider.of<UserProgressProvider>(buildContext, listen: false);
      }

      final added = await _habitRepository.completeHabit(id, DateTime.now());
      await loadHabits();
      
      // Award XP with animation
      if (added && userProgressProvider != null) {
        await userProgressProvider.addXPWithAnimation(habit.xpValue, 'habit_completion', habit.category);
        await userProgressProvider.incrementHabitCompletion(habit.category);

        if (pendingTodayHabits.isEmpty) {
          await userProgressProvider.incrementPerfectDays();
        }

        final ctx = navigatorKey.currentContext;
        if (ctx != null) {
          await FeedbackService.celebrate(ctx, message: '+${habit.xpValue} XP');
        }
      }
      
    } catch (e) {
      _error = 'Failed to complete habit: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> uncompleteHabit(String id) async {
    try {
      final removed = await _habitRepository.uncompleteHabit(id, DateTime.now());
      await loadHabits();
      final buildContext = navigatorKey.currentContext;
      if (removed && buildContext != null && buildContext.mounted) {
        final habit = getHabitById(id);
        if (habit != null) {
          final userProgressProvider = Provider.of<UserProgressProvider>(buildContext, listen: false);
          await userProgressProvider.addXP(-habit.xpValue, 'habit_uncomplete');
          await userProgressProvider.decrementHabitCompletion(habit.category);
        }
      }
    } catch (e) {
      _error = 'Failed to uncomplete habit: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> useStreakFreeze(String id) async {
    try {
      final habit = getHabitById(id);
      if (habit == null) return false;

      // Check if streak freeze is available
      if (habit.streakFreezes <= 0) return false;

      // Check if already used today
      final today = DateTime.now();
      if (habit.lastStreakFreezeUsed != null && 
          habit.lastStreakFreezeUsed!.year == today.year &&
          habit.lastStreakFreezeUsed!.month == today.month &&
          habit.lastStreakFreezeUsed!.day == today.day) {
        return false;
      }

      // Use streak freeze
      final updatedHabit = habit.copyWith(
        streakFreezes: habit.streakFreezes - 1,
        lastStreakFreezeUsed: today,
      );

      await _habitRepository.updateHabit(updatedHabit);
      await loadHabits();

      final buildContext = navigatorKey.currentContext;
      if (buildContext != null && buildContext.mounted) {
        final userProgressProvider = Provider.of<UserProgressProvider>(buildContext, listen: false);
        await userProgressProvider.useStreakFreeze();
      }
      
      return true;
    } catch (e) {
      _error = 'Failed to use streak freeze: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> awardStreakFreezes(String id, int count) async {
    try {
      final habit = getHabitById(id);
      if (habit == null) return;

      final updatedHabit = habit.copyWith(
        streakFreezes: habit.streakFreezes + count,
      );

      await _habitRepository.updateHabit(updatedHabit);
      await loadHabits();
    } catch (e) {
      _error = 'Failed to award streak freezes: ${e.toString()}';
      notifyListeners();
    }
  }

  bool canUseStreakFreeze(String habitId) {
    final habit = getHabitById(habitId);
    if (habit == null) return false;

    // Check if streak freeze is available
    if (habit.streakFreezes <= 0) return false;

    // Check if already used today
    final today = DateTime.now();
    if (habit.lastStreakFreezeUsed != null && 
        habit.lastStreakFreezeUsed!.year == today.year &&
        habit.lastStreakFreezeUsed!.month == today.month &&
        habit.lastStreakFreezeUsed!.day == today.day) {
      return false;
    }

    return true;
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

  int getTotalXPForDay(DateTime date) {
    if (_habits.isEmpty) return 0;
    final dayEpoch = date.difference(DateTime(1970, 1, 1)).inDays;
    int total = 0;
    for (final habit in _habits) {
      if (habit.completionHistory.contains(dayEpoch)) {
        total += habit.xpValue;
      }
    }
    return total;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }


}