
import 'package:shinko/src/domain/entities/user_progress.dart';

abstract class UserProgressRepository {
  Future<UserProgress> getUserProgress();
  Future<void> updateUserProgress(UserProgress userProgress);
}
