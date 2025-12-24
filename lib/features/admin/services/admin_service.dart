import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zyraslot/models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> deleteUser(String uid) async {
    // Note: This only deletes from Firestore. Deleting from Auth requires Cloud Functions or Admin SDK.
    // We will just delete the profile record for now.
    await _firestore.collection('users').doc(uid).delete();
  }
}
