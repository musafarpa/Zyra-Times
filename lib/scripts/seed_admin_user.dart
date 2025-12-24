// One-time script to create initial admin user in Firebase
// Run this script once, then delete it or comment out the call
//
// To use: Uncomment the call in main.dart's main() function after Firebase.initializeApp()
//   await seedAdminUser();
// Then run the app once and comment it back out.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Seeds an admin user into Firebase Auth and Firestore
/// Call this once during development to create the initial admin account
Future<void> seedAdminUser() async {
  const email = 'musafarfake1@gmail.com';
  const password = '2244Hopper';
  const name = 'Admin User';
  const phone = '+1234567890';

  try {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // Check if user already exists in Firestore
    final existingUsers = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (existingUsers.docs.isNotEmpty) {
      debugPrint('🔵 Admin user already exists in Firestore');
      return;
    }

    // Try to create the user in Firebase Auth
    UserCredential? credential;
    try {
      credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Created Firebase Auth user: ${credential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // User exists in Auth but not in Firestore, sign in to get UID
        debugPrint('🔵 User exists in Auth, signing in...');
        credential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        rethrow;
      }
    }

    if (credential.user == null) {
      debugPrint('❌ Failed to get user credential');
      return;
    }

    final uid = credential.user!.uid;

    // Create the user document in Firestore with admin role
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': 'admin', // Admin role
      'createdAt': Timestamp.now(),
    });

    debugPrint('✅ Admin user created successfully!');
    debugPrint('   Email: $email');
    debugPrint('   Password: $password');
    debugPrint('   Role: admin');
    debugPrint('   UID: $uid');

    // Sign out so the app starts fresh
    await auth.signOut();
    debugPrint('🔵 Signed out - ready for normal app use');
  } catch (e) {
    debugPrint('❌ Error seeding admin user: $e');
  }
}
