import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

/// Local progress service — stores completed chapters per course
/// Uses SharedPreferences (no Firebase in this phase)
class ProgressService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get completed chapter IDs for a course
  Future<List<String>> getCompletedChapters(String courseId) async {
    await init();
    return _prefs!.getStringList(
      '${StorageKeys.chapterProgressPrefix}$courseId',
    ) ?? [];
  }

  /// Toggle chapter completion (complete → incomplete, incomplete → complete)
  Future<bool> toggleChapter(String courseId, String chapterId) async {
    await init();
    final completed = await getCompletedChapters(courseId);

    if (completed.contains(chapterId)) {
      completed.remove(chapterId);
    } else {
      completed.add(chapterId);
    }

    await _prefs!.setStringList(
      '${StorageKeys.chapterProgressPrefix}$courseId',
      completed,
    );
    return completed.contains(chapterId);
  }

  /// Check if a chapter is completed
  Future<bool> isChapterCompleted(
      String courseId, String chapterId) async {
    final completed = await getCompletedChapters(courseId);
    return completed.contains(chapterId);
  }

  /// Get course progress as 0.0 to 1.0
  Future<double> getCourseProgress(
      String courseId, int totalChapters) async {
    if (totalChapters == 0) return 0.0;
    final completed = await getCompletedChapters(courseId);
    return completed.length / totalChapters;
  }

  /// Get courses that have progress (for Continue Learning section)
  Future<List<String>> getCourseIdsWithProgress(
      List<String> allCourseIds) async {
    final result = <String>[];
    for (final id in allCourseIds) {
      final completed = await getCompletedChapters(id);
      if (completed.isNotEmpty) {
        result.add(id);
      }
    }
    return result;
  }

  /// Clear all progress (for testing/logout)
  Future<void> clearAllProgress() async {
    await init();
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith(StorageKeys.chapterProgressPrefix)) {
        await _prefs!.remove(key);
      }
    }
  }
}

/// Provider for ProgressService
final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});
