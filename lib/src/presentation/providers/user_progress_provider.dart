import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shinko/src/domain/entities/user_progress.dart';
import 'package:shinko/src/domain/entities/user_stats.dart';
import 'package:shinko/src/domain/entities/habit.dart';
import 'package:shinko/src/domain/entities/achievement.dart';
import 'package:shinko/src/core/navigator_key.dart';
import 'package:shinko/src/presentation/providers/habit_provider.dart';

class UserProgressProvider with ChangeNotifier {
  static const _userProgressKey = 'user_progress';
  static const _achievementsKey = 'achievements';

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
    stats: const UserStats(),
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
      final prefs = await SharedPreferences.getInstance();
      final userProgressString = prefs.getString(_userProgressKey);
      if (userProgressString != null) {
        _userProgress = UserProgress.fromJson(jsonDecode(userProgressString));
      } else {
        _userProgress = _createFreshUserProgress();
      }

      final achievementsString = prefs.getString(_achievementsKey);
      if (achievementsString != null) {
        final decoded = jsonDecode(achievementsString) as List<dynamic>;
        _achievements =
            decoded.map((e) => Achievement.fromJson(e)).toList();
      } else {
        _achievements = _createInitialAchievements();
      }
    } catch (e) {
      _error = 'Failed to load user progress: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _userProgressKey, jsonEncode(_userProgress.toJson()));
  }

  Future<void> _saveAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _achievementsKey,
        jsonEncode(_achievements.map((e) => e.toJson()).toList()));
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
      stats: const UserStats(),
    );
  }

  List<Achievement> _createInitialAchievements() {
    return [
      Achievement(
        id: 'first_habit',
        title: 'First Steps',
        description: 'Create your first habit',
        type: AchievementType.firstHabit,
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
      Achievement(
        id: 'perfect_day_1',
        title: 'Perfectionist',
        description: 'Have 1 perfect day',
        type: AchievementType.perfectDays,
        rarity: AchievementRarity.common,
        xpReward: 50,
        iconData: '✅',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 1,
        createdAt: DateTime.now(),
      ),
      Achievement(
        id: 'streak_freeze_1',
        title: 'Ice Cold',
        description: 'Use a streak freeze',
        type: AchievementType.streakFreeze,
        rarity: AchievementRarity.common,
        xpReward: 20,
        iconData: '🧊',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
        target: 1,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> addXP(int amount, String source) async {
    if (amount == 0) return;

    final newTotalXP = _userProgress.totalXP + amount;
    final currentLevel = _userProgress.currentLevel;
    final newLevel = _calculateLevel(newTotalXP);
    final newXpToNextLevel =
        UserProgress.calculateXPForNextLevel(newLevel);

    _userProgress = _userProgress.copyWith(
      totalXP: newTotalXP,
      currentLevel: newLevel,
      xpToNextLevel: newXpToNextLevel,
    );

    if (newLevel > currentLevel) {
      await _checkLevelAchievements(newLevel);
    }

    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> addStatXP(HabitCategory category, int amount) async {
    UserStats newStats;
    switch (category) {
      case HabitCategory.fitness:
        newStats = _userProgress.stats
            .copyWith(strength: _userProgress.stats.strength + amount);
        break;
      case HabitCategory.learning:
        newStats = _userProgress.stats.copyWith(
            intelligence: _userProgress.stats.intelligence + amount);
        break;
      case HabitCategory.mindfulness:
        newStats = _userProgress.stats
            .copyWith(wisdom: _userProgress.stats.wisdom + amount);
        break;
      case HabitCategory.social:
        newStats = _userProgress.stats
            .copyWith(charisma: _userProgress.stats.charisma + amount);
        break;
      case HabitCategory.productivity:
        newStats = _userProgress.stats
            .copyWith(dexterity: _userProgress.stats.dexterity + amount);
        break;
      default:
        newStats = _userProgress.stats
            .copyWith(luck: _userProgress.stats.luck + amount);
        break;
    }
    _userProgress = _userProgress.copyWith(stats: newStats);
    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> removeStatXP(HabitCategory category, int amount) async {
    UserStats newStats;
    switch (category) {
      case HabitCategory.fitness:
        newStats = _userProgress.stats
            .copyWith(strength: _userProgress.stats.strength - amount);
        break;
      case HabitCategory.learning:
        newStats = _userProgress.stats.copyWith(
            intelligence: _userProgress.stats.intelligence - amount);
        break;
      case HabitCategory.mindfulness:
        newStats = _userProgress.stats
            .copyWith(wisdom: _userProgress.stats.wisdom - amount);
        break;
      case HabitCategory.social:
        newStats = _userProgress.stats
            .copyWith(charisma: _userProgress.stats.charisma - amount);
        break;
      case HabitCategory.productivity:
        newStats = _userProgress.stats
            .copyWith(dexterity: _userProgress.stats.dexterity - amount);
        break;
      default:
        newStats = _userProgress.stats
            .copyWith(luck: _userProgress.stats.luck - amount);
        break;
    }
    _userProgress = _userProgress.copyWith(stats: newStats);
    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> addXPWithAnimation(int amount, String source,
      [HabitCategory? category]) async {
    if (amount <= 0) return;

    final oldXP = _userProgress.totalXP;
    final newTotalXP = oldXP + amount;

    await Future.delayed(const Duration(milliseconds: 300));

    final currentLevel = _userProgress.currentLevel;
    final newLevel = _calculateLevel(newTotalXP);
    final newXpToNextLevel =
        UserProgress.calculateXPForNextLevel(newLevel);

    _userProgress = _userProgress.copyWith(
      totalXP: newTotalXP,
      currentLevel: newLevel,
      xpToNextLevel: newXpToNextLevel,
    );

    if (newLevel > currentLevel) {
      await _checkLevelAchievements(newLevel);
    }

    if (category != null) {
      await addStatXP(category, amount);
    }
    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> incrementHabitCompletion(HabitCategory category) async {
    _userProgress = _userProgress.copyWith(
      totalHabitsCompleted: _userProgress.totalHabitsCompleted + 1,
    );

    await _checkCompletionAchievements();
    await _checkFirstHabitAchievements();
    await addStatXP(category, 10); // award 10 stat points for each completion
    await _saveUserProgress();

    notifyListeners();
  }

  Future<void> decrementHabitCompletion(HabitCategory category) async {
    _userProgress = _userProgress.copyWith(
      totalHabitsCompleted: _userProgress.totalHabitsCompleted - 1,
    );

    await removeStatXP(category, 10);
    await _saveUserProgress();

    notifyListeners();
  }

  Future<void> updateDailyStreak(int streak) async {
    _userProgress = _userProgress.copyWith(
      dailyStreak: streak,
      bestDailyStreak:
          streak > _userProgress.bestDailyStreak ? streak : _userProgress.bestDailyStreak,
    );

    await _checkStreakAchievements(streak);
    await _saveUserProgress();

    notifyListeners();
  }

  Future<void> updateWeeklyStreak(int streak) async {
    _userProgress = _userProgress.copyWith(
      weeklyStreak: streak,
      bestWeeklyStreak:
          streak > _userProgress.bestWeeklyStreak ? streak : _userProgress.bestWeeklyStreak,
    );
    await _saveUserProgress();
    notifyListeners();
  }

  Future<void> incrementPerfectDays() async {
    _userProgress = _userProgress.copyWith(
      totalPerfectDays: _userProgress.totalPerfectDays + 1,
    );
    await _checkPerfectDaysAchievements();
    await _saveUserProgress();

    notifyListeners();
  }

  Future<void> useStreakFreeze() async {
    await _checkStreakFreezeAchievements();
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

  Future<void> _checkFirstHabitAchievements() async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.firstHabit &&
          !achievement.isUnlocked) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _checkPerfectDaysAchievements() async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.perfectDays &&
          achievement.target <= _userProgress.totalPerfectDays &&
          !achievement.isUnlocked) {
        await _unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _checkStreakFreezeAchievements() async {
    for (final achievement in _achievements) {
      if (achievement.type == AchievementType.streakFreeze &&
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

      await addXP(achievement.xpReward, 'achievement_${achievement.id}');

      if (achievement.streakFreezeReward > 0) {
        final context = navigatorKey.currentContext;
        if (context != null && context.mounted) {
          final habitProvider =
              Provider.of<HabitProvider>(context, listen: false);
          await habitProvider.awardStreakFreezes(
              achievement.streakFreezeReward.toString(),
              achievement.streakFreezeReward);
        }
      }

      await _saveAchievements();
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
}