import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:shinko/src/core/services/backup_service.dart';
import 'package:shinko/src/data/datasources/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;
  String? _lastExportPath;

  Future<void> _exportData() async {
    setState(() => _busy = true);
    try {
      final backup = BackupService(DatabaseHelper.instance);
      final jsonString = await backup.exportToJsonString();

      // Create a temporary file
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/shinko-backup-$timestamp.json');
      await file.writeAsString(jsonString);

      _lastExportPath = file.path;

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Shinkō Backup • Keep this file safe!',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup exported successfully'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importData() async {
    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _busy = false);
        return; // User cancelled
      }

      final path = result.files.single.path;
      if (path == null) throw 'Invalid file path';

      final jsonString = await File(path).readAsString();
      final backup = BackupService(DatabaseHelper.instance);
      await backup.importFromJsonString(jsonString);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Import complete. Restart app to ensure consistency.'),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Import failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup & Restore',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _busy ? null : _exportData,
              icon: const Icon(Icons.upload_file),
              label: const Text('Export to JSON'),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _busy ? null : _importData,
              icon: const Icon(Icons.download),
              label: const Text('Import from JSON'),
            ),
            const SizedBox(height: 16),

            if (_lastExportPath != null)
              SelectableText(
                '📂 Last export saved at:\n$_lastExportPath',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),

            if (_busy)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}