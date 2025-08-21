import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinko/src/domain/entities/quest.dart';
import 'package:shinko/src/presentation/providers/quest_provider.dart';
import 'package:shinko/src/presentation/providers/user_progress_provider.dart';
import 'package:shinko/src/presentation/theme/app_theme.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  const QuestCard({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (quest.progress / quest.target).clamp(0.0, 1.0);
    final isCompleted = quest.isCompleted;

    return Container(
      decoration: AppTheme.glassCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isCompleted
                ? Colors.green.withValues(alpha: 0.2)
                : theme.colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.flag,
              size: 22,
              color: isCompleted ? Colors.green : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : theme.colorScheme.primary,
                    ),
                    semanticsLabel: 'Quest Progress',
                    semanticsValue:
                        '${(progress * 100).toStringAsFixed(0)} percent complete',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (quest.isClaimed)
            const Column(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                Text('Claimed', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            )
          else if (isCompleted)
            ElevatedButton(
              onPressed: () async {
                final questProvider = context.read<QuestProvider>();
                final localContext = context;
                await questProvider.claimQuest(localContext, quest.id, (xp, coins) async {
                  final up = localContext.read<UserProgressProvider>();
                  await up.addXPWithAnimation(xp, 'quest_${quest.id}');
                  if (localContext.mounted) {
                    ScaffoldMessenger.of(localContext).showSnackBar(
                      SnackBar(content: Text('Quest completed: +$xp XP, +$coins 🪙')),
                    );
                  }
                });
              },
              child: const Text('Claim'),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${quest.rewardXp} XP',
                  style: AppTheme.caption.copyWith(
                    color: isCompleted ? Colors.green : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (quest.rewardCoins > 0)
                  Text(
                    '+${quest.rewardCoins} 🪙',
                    style: AppTheme.caption.copyWith(
                      color: isCompleted ? Colors.green : Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}