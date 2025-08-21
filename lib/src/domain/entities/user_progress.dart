import 'package:flutter/foundation.dart';
import 'package:shinko/src/domain/entities/user_stats.dart';

@immutable
class UserProgress {
  final int totalXP;
  final int currentLevel;
  final int xpToNextLevel;
  final int dailyStreak;
  final int bestDailyStreak;
  final int weeklyStreak;
  final int bestWeeklyStreak;
  final int totalHabitsCompleted;
  final int totalPerfectDays;
  final int totalStreakFreezesUsed;
  final int coins;
  final DateTime? lastActiveDate;
  final DateTime createdAt;
  final UserStats stats;

  const UserProgress({
    this.totalXP = 0,
    this.currentLevel = 1,
    this.xpToNextLevel = 100,
    this.dailyStreak = 0,
    this.bestDailyStreak = 0,
    this.weeklyStreak = 0,
    this.bestWeeklyStreak = 0,
    this.totalHabitsCompleted = 0,
    this.totalPerfectDays = 0,
    this.totalStreakFreezesUsed = 0,
    this.coins = 0,
    this.lastActiveDate,
    required this.createdAt,
    this.stats = const UserStats(),
  });

  UserProgress copyWith({
    int? totalXP,
    int? currentLevel,
    int? xpToNextLevel,
    int? dailyStreak,
    int? bestDailyStreak,
    int? weeklyStreak,
    int? bestWeeklyStreak,
    int? totalHabitsCompleted,
    int? totalPerfectDays,
    int? totalStreakFreezesUsed,
    int? coins,
    DateTime? lastActiveDate,
    DateTime? createdAt,
    UserStats? stats,
  }) {
    return UserProgress(
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      bestDailyStreak: bestDailyStreak ?? this.bestDailyStreak,
      weeklyStreak: weeklyStreak ?? this.weeklyStreak,
      bestWeeklyStreak: bestWeeklyStreak ?? this.bestWeeklyStreak,
      totalHabitsCompleted: totalHabitsCompleted ?? this.totalHabitsCompleted,
      totalPerfectDays: totalPerfectDays ?? this.totalPerfectDays,
      totalStreakFreezesUsed: totalStreakFreezesUsed ?? this.totalStreakFreezesUsed,
      coins: coins ?? this.coins,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      createdAt: createdAt ?? this.createdAt,
      stats: stats ?? this.stats,
    );
  }

  int get xpForCurrentLevel {
    int xpNeeded = 0;
    for (int level = 1; level < currentLevel; level++) {
      xpNeeded += _calculateXPForLevel(level);
    }
    return xpNeeded;
  }

  static int calculateXPForNextLevel(int level) {
    return 100 + (level * 25);
  }

  int _calculateXPForLevel(int level) {
    return 100 + (level * 25);
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalXP: json['totalXP'] as int,
      currentLevel: json['currentLevel'] as int,
      xpToNextLevel: json['xpToNextLevel'] as int,
      dailyStreak: json['dailyStreak'] as int,
      bestDailyStreak: json['bestDailyStreak'] as int,
      weeklyStreak: json['weeklyStreak'] as int,
      bestWeeklyStreak: json['bestWeeklyStreak'] as int,
      totalHabitsCompleted: json['totalHabitsCompleted'] as int,
      totalPerfectDays: json['totalPerfectDays'] as int,
      totalStreakFreezesUsed: json['totalStreakFreezesUsed'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalXP': totalXP,
        'currentLevel': currentLevel,
        'xpToNextLevel': xpToNextLevel,
        'dailyStreak': dailyStreak,
        'bestDailyStreak': bestDailyStreak,
        'weeklyStreak': weeklyStreak,
        'bestWeeklyStreak': bestWeeklyStreak,
        'totalHabitsCompleted': totalHabitsCompleted,
        'totalPerfectDays': totalPerfectDays,
        'totalStreakFreezesUsed': totalStreakFreezesUsed,
        'lastActiveDate': lastActiveDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'stats': stats.toJson(),
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProgress &&
        other.totalXP == totalXP &&
        other.currentLevel == currentLevel &&
        other.xpToNextLevel == xpToNextLevel &&
        other.dailyStreak == dailyStreak &&
        other.bestDailyStreak == bestDailyStreak &&
        other.weeklyStreak == weeklyStreak &&
        other.bestWeeklyStreak == bestWeeklyStreak &&
        other.totalHabitsCompleted == totalHabitsCompleted &&
        other.totalPerfectDays == totalPerfectDays &&
        other.totalStreakFreezesUsed == totalStreakFreezesUsed &&
        other.lastActiveDate == lastActiveDate &&
        other.createdAt == createdAt &&
        other.stats == stats;
  }

  @override
  int get hashCode {
    return totalXP.hashCode ^
        currentLevel.hashCode ^
        xpToNextLevel.hashCode ^
        dailyStreak.hashCode ^
        bestDailyStreak.hashCode ^
        weeklyStreak.hashCode ^
        bestWeeklyStreak.hashCode ^
        totalHabitsCompleted.hashCode ^
        totalStreakFreezesUsed.hashCode ^
        totalPerfectDays.hashCode ^
        lastActiveDate.hashCode ^
        createdAt.hashCode ^
        stats.hashCode;
  }
}