import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_user_model.dart';

/// Admin authentication.
/// Primary check: UID whitelist (most secure).
/// Secondary check: Firestore admins/{uid}.role == 'admin' (if the doc exists).
/// This way the app works even before the Firestore role doc is written.
class AdminAuthService {
  // The registered admin UID from Firebase Auth
  static const String _adminUid = 'GGPKFSbr4jSfAv3lE8i2yMUXqCi2';

  // Fallback email whitelist — used if UID doesn't match
  static const List<String> _adminEmails = [
    'admin@cropguard.ai',
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AdminUserModel?> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      final user = cred.user;
      if (user == null) return null;

      // Check 1: UID match (fast, no Firestore needed)
      if (user.uid == _adminUid) {
        // Also write/update the role doc while we have access
        _ensureRoleDoc(user.uid, user.email ?? email);
        return AdminUserModel(
          id: user.uid,
          email: user.email ?? email,
          name: user.displayName ?? 'Admin',
          role: 'admin',
        );
      }

      // Check 2: email whitelist
      final emailLower = (user.email ?? '').toLowerCase();
      if (_adminEmails.any((e) => e.toLowerCase() == emailLower)) {
        _ensureRoleDoc(user.uid, user.email ?? email);
        return AdminUserModel(
          id: user.uid,
          email: user.email ?? email,
          name: user.displayName ?? 'Admin',
          role: 'admin',
        );
      }

      // Check 3: Firestore role doc (if UID/email didn't match)
      try {
        final doc = await _db.collection('admins').doc(user.uid).get();
        if (doc.exists && doc.data()?['role'] == 'admin' && doc.data()?['active'] == true) {
          return AdminUserModel(
            id: user.uid,
            email: user.email ?? email,
            name: user.displayName ?? 'Admin',
            role: 'admin',
          );
        }
      } catch (_) {}

      // Not an admin
      await _auth.signOut();
      throw 'Access denied. This account is not authorised as admin.';
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  /// Write the admin role doc to Firestore so future checks work.
  /// Fire-and-forget — never blocks login.
  void _ensureRoleDoc(String uid, String email) {
    _db.collection('admins').doc(uid).set({
      'uid': uid,
      'email': email,
      'role': 'admin',
      'active': true,
    }, SetOptions(merge: true)).catchError((_) {});
  }

  Future<void> signOut() async => _auth.signOut();

  bool get isLoggedIn {
    final u = _auth.currentUser;
    if (u == null) return false;
    final emailLower = (u.email ?? '').toLowerCase();
    return u.uid == _adminUid ||
        _adminEmails.any((e) => e.toLowerCase() == emailLower);
  }

  AdminUserModel? get currentUser {
    final u = _auth.currentUser;
    if (u == null) return null;
    final emailLower = (u.email ?? '').toLowerCase();
    final allowed = u.uid == _adminUid ||
        _adminEmails.any((e) => e.toLowerCase() == emailLower);
    if (!allowed) return null;
    return AdminUserModel(
        id: u.uid,
        email: u.email ?? '',
        name: u.displayName ?? 'Admin',
        role: 'admin');
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}

class AdminAuthException implements Exception {
  final String message;
  final String? errorCode;
  AdminAuthException(this.message, this.errorCode);
  @override
  String toString() => message;
}
