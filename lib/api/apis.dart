import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/chat_user_model.dart'; // path sahi rakhna

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  static ChatUserModel? currentUser;

  ///  Function to get all users from 'users' collection
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firebaseFirestore
        .collection("users")
        .where('userId', isNotEqualTo: auth.currentUser?.uid)
        .snapshots();
  }

  /// Function to get current user info from 'users' collection
  static Future<void> getCurrentUser() async {
    try {
      final snapshot =
          await firebaseFirestore
              .collection("users")
              .where('userId', isEqualTo: auth.currentUser?.uid)
              .get();

      if (snapshot.docs.isNotEmpty) {
        currentUser = ChatUserModel.fromJson(snapshot.docs.first.data());
      }
    } catch (e) {
      print("Error getting current user: $e");
    }
  }

  /// --- Function to update current user info in 'users' collection --- ///
  static Future<void> updateCurrentUser() async {
    try {
      await firebaseFirestore
          .collection("users")
          .doc(auth.currentUser!.uid)
          .update(currentUser!.toJson());

      print("User updated successfully.");
    } catch (e) {
      print("Error updating user: $e");
    }
  }

}
