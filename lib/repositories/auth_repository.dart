import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager_app/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository()
      : _firebaseAuth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<UserModel> signUp(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      final userModel = UserModel(id: user.uid, email: email);

      await _firestore.collection('users').doc(user.uid).set(
        userModel.toFirestore(),
      );

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign up failed');
    }
  }

  Future<UserModel> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        final userModel = UserModel(id: user.uid, email: email);
        await _firestore.collection('users').doc(user.uid).set(
          userModel.toFirestore(),
        );
        return userModel;
      }

      return UserModel.fromFirestore(user.uid, userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(user.uid, userDoc.data()!);
      }
    }
    return null;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}