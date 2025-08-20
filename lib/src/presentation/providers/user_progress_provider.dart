import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinko/src/domain/entities/user_progress.dart';
import 'package:shinko/src/domain/entities/habit.dart';
import 'package:shinko/src/domain/entities/achievement.dart';
import 'package:shinko/src/core/navigator_key.dart';
import 'package:shinko/src/presentation/providers/habit_provider.dart';

class UserProgressProvider with ChangeNotifier {
  UserProgress _userProgress = UserProgress(
    totalXP: 0,
    currentLevel: 1,
    xpToNextLevel: 100,
    dailyStreak: 0,
    bestDailyStreak: 0,
    weeklyStreak: 0,
    bestWeeklyStreak: 0,
    totalHabitsCompleted: 0,
    totalPerfectDays: 0,
     createdAt: DateTime.now(),
     lastActiveDate: DateTime.now(),
   );

  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _error;

  UserProgress get userProgress => _userProgress;
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => 
      _achievements.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements => 
      _achievements.where((a) => !a.isUnlocked).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get levelProgress {
    if (_userProgress.currentLevel == 1) {
      return _userProgress.totalXP / _userProgress.xpToNextLevel;
    }
    
    final xpForCurrentLevel = _userProgress.xpForCurrentLevel;
    final currentLevelXP = _userProgress.totalXP - xpForCurrentLevel;
    
    return (currentLevelXP / _userProgress.xpToNextLevel).clamp(0.0, 1.0);
  }

  Future<void> loadUserProgress() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Start with fresh data (0 XP, level 1, no achievements)
      _userProgress = _createFreshUserProgress();
      _achievements = _createInitialAchievements();
    } catch (e) {
      _error = 'Failed to load user progress: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserProgress _createFreshUserProgress() {
    return UserProgress(
      totalXP: 0,
      currentLevel: 1,
      dailyStreak: 0,
      bestDailyStreak: 0,
      weeklyStreak: 0,
      bestWeeklyStreak: 0,
      totalHabitsCompleted: 0,
      totalPerfectDays: 0,
      lastActiveDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  List<Achievement> _createInitialAchievements() {
    return [
      Achievement(
        id: 'first_habit',
        title: 'First Steps',
        description: 'Create your first habit',
        type: AchievementType.category,
        rarity: AchievementRarity.common,
        xpReward: 50,
        iconData: '🌱',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 1,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_3',
        title: 'Three Day Streak',
        description: 'Maintain a 3-day streak',
        type: AchievementType.streak,
        rarity: AchievementRarity.common,
        xpReward: 30,
        iconData: '🔥',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 3,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        xpReward: 100,
        iconData: '🔥',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 7,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_14',
        title: 'Fortnight Fighter',
        description: 'Maintain a 14-day streak',
        type: AchievementType.streak,
        rarity: AchievementRarity.epic,
        xpReward: 200,
        iconData: '❄️',
        streakFreezeReward: 1,
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 14,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_30',
        title: 'Monthly Master',
        description: 'Maintain a 30-day streak',
        type: AchievementType.streak,
        rarity: AchievementRarity.legendary,
        xpReward: 500,
        iconData: '👑',
        streakFreezeReward: 3,
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 30,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'habit_master_10',
        title: 'Getting Started',
        description: 'Complete 10 habits',
        type: AchievementType.completion,
        rarity: AchievementRarity.common,
        xpReward: 75,
        iconData: '🎯',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 10,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'habit_master_50',
        title: 'Habit Master',
        description: 'Complete 50 habits',
        type: AchievementType.completion,
        rarity: AchievementRarity.rare,
        xpReward: 200,
        iconData: '👑',
        streakFreezeReward: 1,
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 50,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'level_5',
        title: 'Rising Star',
        description: 'Reach level 5',
        type: AchievementType.level,
        rarity: AchievementRarity.rare,
        xpReward: 150,
        iconData: '⭐',
        streakFreezeReward: 1,
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 5,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'level_10',
        title: 'Level Legend',
        description: 'Reach level 10',
        type: AchievementType.level,
        rarity: AchievementRarity.epic,
        xpReward: 300,
        iconData: '💫',
        streakFreezeReward: 2,
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 10,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> addXP(int amount, String source) async {
    if (amount <= 0) return;

    final newTotalXP = _userProgress.totalXP + amount;
    final newLevel = _calculateLevel(newTotalXP);
    final newXpToNextLevel = UserProgress.calculateXPForNextLevel(newLevel);

    _userProgress = _userProgress.copyWith(
      totalXP: newTotalXP,
      currentLevel: newLevel,
      xpToNextLevel: newXpToNextLevel,
    );

    // Check for level achievements
    if (newLevel > _userProgress.currentLevel) {
      await _checkLevelAchievements(newLevel);
    }

    notifyListeners();
  }

  Future<void> addXPWithAnimation(int amount, String source) async {
    if (amount <= 0) return;

    // Simulate animated XP gain by adding gradually
    final oldXP = _userProgress.totalXP;
    final newTotalXP = oldXP + amount;
    
    // Small delay for animation effect
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newLevel = _calculateLevel(newTotalXP);
    final newXpToNextLevel = UserProgress.calculateXPForNextLevel(newLevel);

    _userProgress = _userProgress.copyWith(
      totalXP: newTotalXP,
      currentLevel: newLevel,
      xpToNextLevel: newXpToNextLevel,
    );

    // Check for level achievements
    if (newLevel > _userProgress.currentLevel) {
      await _checkLevelAchievements(newLevel);
    }

    notifyListeners();
  }

  Future<void> incrementHabitCompletion() async {
    _userProgress = _userProgress.copyWith(
      totalHabitsCompleted: _userProgress.totalHabitsCompleted + 1,
    );
    
    // Check for completion achievements
    await _checkCompletionAchievements();
    
    notifyListeners();
  }

  Future<void> updateDailyStreak(int streak) async {
    _userProgress = _userProgress.copyWith(
      dailyStreak: streak,
      bestDailyStreak: streak > _userProgress.bestDailyStreak 
          ? streak 
          : _userProgress.bestDailyStreak,
    );

    // Check for streak achievements
    await _checkStreakAchievements(streak);
    
    notifyListeners();
  }

  Future<void> updateWeeklyStreak(int streak) async {
    _userProgress = _userProgress.copyWith(
      weeklyStreak: streak,
      bestWeeklyStreak: streak > _userProgress.bestWeeklyStreak 
          ? streak 
          : _userProgress.bestWeeklyStreak,
    );
    
    notifyListeners();
  }

  Future<void> incrementPerfectDays() async {
    _userProgress = _userProgress.copyWith(
      totalPerfectDays: _userProgress.totalPerfectDays + 1,
    );
    
    notifyListeners();
  }

  int _calculateLevel(int totalXP) {
    int level = 1;
    int xpNeeded = 0;
    
    while (true) {
      final xpForLevel = UserProgress.calculateXPForNextLevel(level);
      if (xpNeeded + xpForLevel > totalXP) break;
      xpNeeded += xpForLevel;
      level++;
    }
    
    return level;
  }

  Future<void> _checkLevelAchievements(int level) async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.level && 
          achievement.target == level && 
          !achievement.isUnlocked) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _checkStreakAchievements(int streak) async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.streak && 
          achievement.target <= streak && 
          !achievement.isUnlocked) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _checkCompletionAchievements() async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.completion && 
          achievement.target <= _userProgress.totalHabitsCompleted && 
          !achievement.isUnlocked) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _unlockAchievement(String achievementId) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 && !_achievements[index].isUnlocked) {
      final achievement = _achievements[index];
      _achievements[index] = achievement.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        progress: achievement.target,
      );
      
      // Add XP reward
      await addXP(achievement.xpReward, 'achievement_${achievement.id}');
      
      // Award streak freezes if applicable
      if (achievement.streakFreezeReward > 0) {
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          final habitProvider = Provider.of<HabitProvider>(context, listen: false);
          await habitProvider.awardStreakFreezes(achievement.streakFreezeReward.toString(), achievement.streakFreezeReward);
        }
      }
      
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  double getXPForDay(BuildContext context, DateTime date) {
    final habits = Provider.of<HabitProvider>(context, listen: false);
    return habits.getTotalXPForDay(date).toDouble();
  }

  Future<void> recalculateFromHabits(List<Habit> habits) async {
    int totalXp = 0;
    int totalCompletions = 0;
    for (final habit in habits) {
      totalXp += habit.xpValue * habit.totalCompletions;
      totalCompletions += habit.totalCompletions;
    }

    final newLevel = _calculateLevel(totalXp);
    final newXpToNext = UserProgress.calculateXPForNextLevel(newLevel);

    _userProgress = _userProgress.copyWith(
      totalXP: totalXp,
      currentLevel: newLevel,
      xpToNextLevel: newXpToNext,
      totalHabitsCompleted: totalCompletions,
    );
    notifyListeners();
  }
}