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
          const Text('Themes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...cos.allItems.where((e) => e.type == 'theme').map((item) => ListTile(
                title: Text(item.name),
                trailing: cos.equippedByType['theme'] == item.id
                    ? const Icon(Icons.check, color: Colors.green)
                    : ElevatedButton(
                        onPressed: cos.unlocked.contains(item.id) ? () => cos.equip(item.id) : null,
                        child: Text(cos.unlocked.contains(item.id) ? 'Equip' : 'Locked'),
                      ),
              )),
          const SizedBox(height: 16),
          const Text('Icons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...cos.allItems.where((e) => e.type == 'icon').map((item) => ListTile(
                title: Text(item.name),
                trailing: cos.equippedByType['icon'] == item.id
                    ? const Icon(Icons.check, color: Colors.green)
                    : ElevatedButton(
                        onPressed: cos.unlocked.contains(item.id) ? () => cos.equip(item.id) : null,
                        child: Text(cos.unlocked.contains(item.id) ? 'Equip' : 'Locked'),
                      ),
              )),
          const SizedBox(height: 16),
          const Text('Trails', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...cos.allItems.where((e) => e.type == 'trail').map((item) => ListTile(
                title: Text(item.name),
                trailing: cos.equippedByType['trail'] == item.id
                    ? const Icon(Icons.check, color: Colors.green)
                    : ElevatedButton(
                        onPressed: cos.unlocked.contains(item.id) ? () => cos.equip(item.id) : null,
                        child: Text(cos.unlocked.contains(item.id) ? 'Equip' : 'Locked'),
                      ),
              )),
        ],
      ),
    );
  }
}


