import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for writing quiz results to Firestore.
///
/// Stores results at: users/{uid}/quizResults/{autoId}
/// Fields: courseId, quizId, score, total, timeTakenSec, date
///
/// Uses Firestore's built-in offline persistence — writes queue automatically
/// when offline and sync when back online.
class FirestoreQuizService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreQuizService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Current user's UID — null if not logged in
  String? get _uid => _auth.currentUser?.uid;

  /// Save a quiz result to Firestore
  Future<void> saveResult({
    required String courseId,
    required String quizId,
    required int score,
    required int total,
    required int timeTakenSec,
  }) async {
    final uid = _uid;
    if (uid == null) return; // Not logged in — skip

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('quizResults')
          .add({
        'courseId': courseId,
        'quizId': quizId,
        'score': score,
        'total': total,
        'timeTakenSec': timeTakenSec,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Offline → Firestore queues automatically when back online
    }
  }

  /// Get all quiz results for current user (stream)
  Stream<List<Map<String, dynamic>>> watchResults() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('quizResults')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  /// Get best score for a specific quiz
  Future<int> getBestScore(String quizId) async {
    final uid = _uid;
    if (uid == null) return 0;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('quizResults')
          .where('quizId', isEqualTo: quizId)
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return 0;
      return snapshot.docs.first.data()['score'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }
}

/// Provider for FirestoreQuizService
final firestoreQuizServiceProvider = Provider<FirestoreQuizService>((ref) {
  return FirestoreQuizService();
});
