import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shinko/src/domain/entities/quest.dart';
import 'package:shinko/src/presentation/providers/habit_provider.dart';

class QuestProvider with ChangeNotifier {
  final HabitProvider habitProvider;
  List<Quest> _todayQuests = [];
  bool _generatedForToday = false;

  QuestProvider(this.habitProvider);

  List<Quest> get todayQuests => _todayQuests;

  DateTime get _today => DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Future<void> ensureGeneratedForToday() async {
    if (_generatedForToday) return;
    _generatedForToday = true;
    _todayQuests = _generateDailyQuests();
    _recalculateProgress();
    notifyListeners();
  }

  void onHabitsChanged() {
    _recalculateProgress();
    notifyListeners();
  }

  void _recalculateProgress() {
    for (int i = 0; i < _todayQuests.length; i++) {
      final q = _todayQuests[i];
      int progress = 0;
      switch (q.type) {
        case QuestType.completeHabitsTotal:
          progress = habitProvider.completedTodayHabits.length;
          break;
        case QuestType.completeHabitsBeforeNoon:
          progress = habitProvider.completedTodayHabits.length; // simplified; per-habit timestamp not stored
          break;
        case QuestType.perfectDay:
          progress = habitProvider.pendingTodayHabits.isEmpty && habitProvider.activeHabits.isNotEmpty ? 1 : 0;
          break;
        case QuestType.streakSave:
          progress = 0; // tracked when user uses streak freeze; advanced later via provider call
          break;
      }
      final done = progress >= q.target;
      _todayQuests[i] = q.copyWith(progress: progress, isCompleted: done);
    }
  }

  List<Quest> _generateDailyQuests() {
    final rng = Random();
    final count = 3 + rng.nextInt(3); // 3..5
    final quests = <Quest>[];
    for (int i = 0; i < count; i++) {
      final type = QuestType.values[rng.nextInt(QuestType.values.length)];
      int target;
      String title;
      String description;
      switch (type) {
        case QuestType.completeHabitsTotal:
          target = 2 + rng.nextInt(4); // 2..5
          title = 'Complete $target habits';
          description = 'Knock out $target habits anytime today.';
          break;
        case QuestType.completeHabitsBeforeNoon:
          target = 2 + rng.nextInt(3); // 2..4
          title = 'Beat noon with $target habits';
          description = 'Complete $target habits before 12:00.';
          break;
        case QuestType.perfectDay:
          target = 1;
          title = 'Perfect Day';
          description = 'Complete all active habits today.';
          break;
        case QuestType.streakSave:
          target = 1;
          title = 'Streak Save';
          description = 'Use 1 streak freeze to protect a streak.';
          break;
      }
      final reward = 15 + rng.nextInt(36); // 15..50 XP
      quests.add(Quest(
        id: 'q_${_today.millisecondsSinceEpoch}_$i',
        date: _today,
        type: type,
        title: title,
        description: description,
        target: target,
        progress: 0,
        rewardXp: reward,
      ));
    }
    return quests;
  }

  Quest? get bonusChest {
    if (habitProvider.activeHabits.isEmpty) return null;
    final allDone = habitProvider.pendingTodayHabits.isEmpty;
    return Quest(
      id: 'bonus_${_today.millisecondsSinceEpoch}',
      date: _today,
      type: QuestType.perfectDay,
      title: 'Mystery Chest',
      description: allDone ? 'All habits done! Claim your chest.' : 'Finish all habits to unlock.',
      target: 1,
      progress: allDone ? 1 : 0,
      rewardXp: 50,
      isCompleted: allDone,
      isClaimed: false,
    );
  }

  Future<Quest?> claimBonusChest(BuildContext context, void Function(int xp, String? cosmeticId) onReward) async {
    final chest = bonusChest;
    if (chest == null || !chest.isCompleted) return null;
    // cosmetic reward chance
    final rewardXp = chest.rewardXp;
    String? cosmeticId;
    // CosmeticProvider lives above; optional unlock
    // Keeping it simple: 30% chance to unlock a random cosmetic if any locked remain
    // Caller can wire CosmeticProvider here if desired
    onReward(rewardXp, cosmeticId);
    return chest.copyWith(isClaimed: true);
  }
}


