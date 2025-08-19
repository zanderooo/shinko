import 'package:flutter/material.dart';
import 'package:shinko/src/domain/entities/user_progress.dart';
import 'package:shinko/src/domain/entities/achievement.dart';

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
      // For now, use mock data
      _userProgress = _createSampleUserProgress();
      _achievements = _createSampleAchievements();
    } catch (e) {
      _error = 'Failed to load user progress: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserProgress _createSampleUserProgress() {
    return UserProgress(
      totalXP: 285,
      currentLevel: 5,
      dailyStreak: 7,
      bestDailyStreak: 12,
      totalHabitsCompleted: 35,
      totalPerfectDays: 3,
      lastActiveDate: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  List<Achievement> _createSampleAchievements() {
    return [
      Achievement(
        id: 'first_habit',
        title: 'First Steps',
        description: 'Create your first habit',
        type: AchievementType.category,
        rarity: AchievementRarity.common,
        xpReward: 50,
        iconData: '🌱',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
        progress: 1,
        target: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        xpReward: 100,
        iconData: '🔥',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
        progress: 7,
        target: 7,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Achievement(
        id: 'habit_master',
        title: 'Habit Master',
        description: 'Complete 50 habits',
        type: AchievementType.level,
        rarity: AchievementRarity.rare,
        xpReward: 200,
        iconData: '👑',
        isUnlocked: false,
        unlockedAt: null,
        progress: 35,
        target: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
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
      
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  double getXPForDay(DateTime date) {
    // This is a placeholder. In a real app, you would fetch this from a repository.
    // For now, let's generate some sample data.
    final day = date.weekday;
    switch (day) {
      case DateTime.monday:
        return 50;
      case DateTime.tuesday:
        return 75;
      case DateTime.wednesday:
        return 60;
      case DateTime.thursday:
        return 90;
      case DateTime.friday:
        return 120;
      case DateTime.saturday:
        return 150;
      case DateTime.sunday:
        return 100;
      default:
        return 0;
    }
  }
}