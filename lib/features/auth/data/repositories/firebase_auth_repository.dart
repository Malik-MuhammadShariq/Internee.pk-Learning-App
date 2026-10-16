import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Auth repository — wraps Firebase Auth + Firestore profile docs.
///
/// ⚠️ AUTH SEPARATION: This handles APP login (Firebase Auth).
/// Internee.pk WebView auth (course content) is a completely separate
/// cookie-based session — independent of Firebase user ID.
class FirebaseAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of auth state changes — emits User? on login/logout
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current signed-in user (null if logged out)
  User? get currentUser => _auth.currentUser;

  /// Sign up with email/password + create Firestore profile doc
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Create Firebase Auth user
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return;

    // Update display name on the Auth profile
    await user.updateDisplayName(name);

    // Create Firestore profile doc: users/{uid}
    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'photoUrl': '',
      'joinDate': FieldValue.serverTimestamp(),
    });

    // Ensure profile exists (redundant here but guarantees consistency)
    await ensureUserProfile(email: email);
  }

  /// Ensure a Firestore profile doc exists for the current user.
  /// Called automatically after login AND signup.
  /// - If doc exists: no-op (preserves existing data)
  /// - If doc missing (e.g. console-created user): creates it with
  ///   name = email prefix (first letter capitalized)
  Future<void> ensureUserProfile({String? email}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (doc.exists) return; // Profile already exists — nothing to do

    // Derive display name from email prefix (e.g. "ahmed" → "Ahmed")
    final emailAddr = email ?? _auth.currentUser?.email ?? '';
    final prefix = emailAddr.split('@').first;
    final name = prefix.isNotEmpty
        ? prefix[0].toUpperCase() + prefix.substring(1)
        : 'User';

    await docRef.set({
      'name': name,
      'email': emailAddr,
      'photoUrl': '',
      'joinDate': FieldValue.serverTimestamp(),
    });
  }

  /// Log in with email/password
  /// Automatically ensures a Firestore profile doc exists (for console-created users)
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Ensure profile doc exists after login (handles console-created users)
    await ensureUserProfile(email: email);
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Log out
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Update user's display name (Auth + Firestore)
  Future<void> updateName(String name) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Update Auth profile display name
    await _auth.currentUser!.updateDisplayName(name);

    // Update Firestore profile doc
    await _firestore.collection('users').doc(uid).update({'name': name});
  }

  /// Map FirebaseAuthException codes to friendly error messages
  String mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'No internet connection';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
