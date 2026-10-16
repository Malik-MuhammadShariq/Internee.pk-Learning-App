import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/firebase_auth_repository.dart';

/// Provider for FirebaseAuthRepository
final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Stream of Firebase auth state changes — emits User? on login/logout
/// Used by splash screen + GoRouter redirect guard
final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(firebaseAuthRepositoryProvider);
  return repository.authStateChanges;
});

/// Stream of the current user's Firestore profile doc (users/{uid})
/// Emits DocumentSnapshot? — null when logged out
final userProfileProvider =
    StreamProvider.family<DocumentSnapshot?, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots();
});

/// Convenience provider: is a user currently logged in?
final isLoggedInProvider = Provider<bool>((ref) {
  final asyncUser = ref.watch(authStateProvider);
  return asyncUser.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});
