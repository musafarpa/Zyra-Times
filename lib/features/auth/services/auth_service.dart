import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:zyraslot/models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUserModel;
  UserModel? get currentUserModel => _currentUserModel;

  User? get currentUser => _auth.currentUser;

  bool get isLoading => _currentUserModel == null && _auth.currentUser != null;

  // Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create User Document
      UserModel newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(result.user!.uid).set(newUser.toMap());
      _currentUserModel = newUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _fetchUserData();
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUserModel = null;
    notifyListeners();
  }

  // Fetch User Data from Firestore
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUserModel = UserModel.fromMap(doc.data() as Map<String, dynamic>, user.uid);
        notifyListeners();
      }
    }
  }

  // Check Auth State on App Start
  Future<void> initializeUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _fetchUserData();
    }
  }
}
