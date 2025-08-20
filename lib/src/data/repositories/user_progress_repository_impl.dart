
import 'package:shinko/src/data/datasources/database_helper.dart';
import 'package:shinko/src/domain/entities/user_progress.dart';
import 'package:shinko/src/domain/repositories/user_progress_repository.dart';

class UserProgressRepositoryImpl implements UserProgressRepository {
  final DatabaseHelper _databaseHelper;

  UserProgressRepositoryImpl(this._databaseHelper);

  @override
  Future<UserProgress> getUserProgress() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(DatabaseHelper.tableUserProgress);
    if (maps.isNotEmpty) {
      return UserProgress.fromJson(maps.first);
    } else {
      // This should not happen in a normal scenario as the database is initialized with a user progress row.
      throw Exception('User progress not found');
    }
  }

  @override
  Future<void> updateUserProgress(UserProgress userProgress) async {
    final db = await _databaseHelper.database;
    await db.update(
      DatabaseHelper.tableUserProgress,
      userProgress.toJson(),
      where: 'id = ?',
      whereArgs: [1], // There is only one user progress row with id 1
    );
  }
}
