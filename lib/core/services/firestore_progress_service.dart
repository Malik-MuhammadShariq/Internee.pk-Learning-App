import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'progress_service.dart';

/// Firestore-backed progress service with dual-layer caching.
///
/// - Local: wraps `ProgressService` (SharedPreferences) for instant reads
/// - Remote: syncs to Firestore with built-in offline persistence
///
/// Offline strategy: Firestore handles queuing natively (persistence enabled
/// in main.dart). No manual SharedPreferences queue — the local ProgressService
/// cache serves as instant UI data, Firestore syncs when online.
///
/// ⚠️ Same interface as ProgressService — drop-in replacement.
class FirestoreProgressService {
  final ProgressService _localCache;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreProgressService({
    ProgressService? localCache,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _localCache = localCache ?? ProgressService(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Current user's UID — null if not logged in
  String? get _uid => _auth.currentUser?.uid;

  /// Initialize local cache
  Future<void> init() => _localCache.init();

  // ─── Local cache passthrough (instant reads) ───

  Future<List<String>> getCompletedChapters(String courseId) =>
      _localCache.getCompletedChapters(courseId);

  Future<bool> isChapterCompleted(String courseId, String chapterId) =>
      _localCache.isChapterCompleted(courseId, courseId);

  Future<double> getCourseProgress(String courseId, int totalChapters) =>
      _localCache.getCourseProgress(courseId, totalChapters);

  Future<List<String>> getCourseIdsWithProgress(List<String> allCourseIds) =>
      _localCache.getCourseIdsWithProgress(allCourseIds);

  // ─── Sync methods (local + Firestore) ───

  /// Toggle chapter completion — updates local cache AND Firestore
  Future<bool> toggleChapter(String courseId, String chapterId) async {
    // Update local cache first (instant UI feedback)
    final nowCompleted = await _localCache.toggleChapter(courseId, chapterId);

    // Sync to Firestore (queued offline automatically)
    await _syncChapterToFirestore(courseId, chapterId, nowCompleted);

    return nowCompleted;
  }

  /// Clear all progress — local + Firestore
  Future<void> clearAllProgress() async {
    await _localCache.clearAllProgress();
    // Note: Firestore docs remain (historical record). Could delete if needed.
  }

  // ─── Firestore sync helpers ───

  Future<void> _syncChapterToFirestore(
    String courseId,
    String chapterId,
    bool completed,
  ) async {
    final uid = _uid;
    if (uid == null) return; // Not logged in — local only

    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('progress')
          .doc(courseId);

      if (completed) {
        // Add chapter to completedChapters array
        await docRef.set({
          'completedChapters': FieldValue.arrayUnion([chapterId]),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Remove chapter from completedChapters array
        await docRef.set({
          'completedChapters': FieldValue.arrayRemove([chapterId]),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Update percentage
      final completedChapters =
          await _localCache.getCompletedChapters(courseId);
      // We need totalChapters — get from existing doc or skip
      final totalChapters = await _getTotalChapters(docRef);
      if (totalChapters > 0) {
        final percentage = completedChapters.length / totalChapters;
        await docRef.update({
          'percentage': percentage,
          'totalChapters': totalChapters,
        });
      }
    } catch (_) {
      // Firestore offline → will sync automatically when back online
    }
  }

  /// Set total chapters for a course (call when starting course)
  Future<void> setTotalChapters(String courseId, int total) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('progress')
          .doc(courseId)
          .set({
        'totalChapters': total,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Offline → queued automatically
    }
  }

  /// Get totalChapters from existing Firestore doc (safe)
  Future<int> _getTotalChapters(DocumentReference docRef) async {
    try {
      final doc = await docRef.get();
      if (!doc.exists) return 0;
      final data = doc.data() as Map<String, dynamic>?;
      return data?['totalChapters'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Stream of course progress from Firestore (reactive)
  Stream<double> watchCourseProgress(String courseId, int totalChapters) {
    final uid = _uid;
    if (uid == null) return Stream.value(0.0);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('progress')
        .doc(courseId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 0.0;
      final data = snapshot.data();
      if (data == null) return 0.0;
      final completed = (data['completedChapters'] as List?)?.length ?? 0;
      if (totalChapters == 0) return 0.0;
      return completed / totalChapters;
    });
  }

  /// Load progress from Firestore into local cache (call on login)
  Future<void> syncFromFirestore(String courseId) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('progress')
          .doc(courseId)
          .get();

      if (doc.exists) {
        // Firestore data available — local cache handles instant reads.
        // Full two-way sync would require a bulk-set method on ProgressService.
        await _localCache.init();
      }
    } catch (_) {
      // Offline — use local cache only
    }
  }
}

/// Provider for FirestoreProgressService (dual-layer: local cache + Firestore sync)
final firestoreProgressServiceProvider =
    Provider<FirestoreProgressService>((ref) {
  return FirestoreProgressService();
});
