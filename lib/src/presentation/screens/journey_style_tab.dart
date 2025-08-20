import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shinko/src/presentation/providers/cosmetic_provider.dart';

class JourneyStyleTab extends StatelessWidget {
  const JourneyStyleTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cos = context.watch<CosmeticProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Style')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCosmeticSection(context, cos, 'Themes', 'theme', Icons.color_lens),
          const SizedBox(height: 16),
          _buildCosmeticSection(context, cos, 'Icons', 'icon', Icons.insert_emoticon),
          const SizedBox(height: 16),
          _buildCosmeticSection(context, cos, 'Trails', 'trail', Icons.motion_photos_on),
        ],
      ),
    );
  }

  /// Builds a generic cosmetic section for different item types
  Widget _buildCosmeticSection(
    BuildContext context,
    CosmeticProvider cos,
    String title,
    String type,
    IconData icon,
  ) {
    final items = cos.allItems.where((e) => e.type == type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          final isEquipped = cos.equippedByType[type] == item.id;
          final isUnlocked = cos.unlocked.contains(item.id);

          return ListTile(
            title: Text(item.name),
            trailing: isEquipped
                ? const Icon(Icons.check, color: Colors.green)
                : ElevatedButton(
                    onPressed: isUnlocked ? () => cos.equip(item.id) : null,
                    child: Text(isUnlocked ? 'Equip' : 'Locked'),
                  ),
          );
        }),
      ],
    );
  }
}