import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ping_me/model/message_model.dart';
import '../model/chat_user_model.dart';

class APIs {
  /// ---- Firebase auth --- ///
  static FirebaseAuth auth = FirebaseAuth.instance;

  /// --- Firebase firestore --- ///
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  /// --- Firebase storage --- ///
  static FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  /// --- Current user --- ///
  static ChatUserModel? currentUser;

  /// Function to return current user
  static User get user => auth.currentUser!;

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

  /// ---  Function to  update profile picture in 'users' collection --- ///
  static Future<void> updateUserProfilePicture(File file) async {
    try {
      final ext = file.path.split('.').last;

      // Storage reference path
      final ref = firebaseStorage
          .ref("profile")
          .child("profile_pictures/${currentUser!.userId}.$ext");

      // Upload file
      await ref.putFile(file);

      // Get the download URL
      final imageUrl = await ref.getDownloadURL();

      // Update current user object
      currentUser!.imageUrl = imageUrl;

      // Update Firestore user document
      await firebaseFirestore
          .collection("users")
          .doc(auth.currentUser!.uid)
          .update({'imageUrl': imageUrl});

      print("Profile picture updated successfully.");
    } catch (e) {
      print("Error updating profile picture: $e");
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

  /// ******************* Chat Screen Related APIs ********************* ///
  /// chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc) --> message (data)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
    ChatUserModel user,
  ) {
    return firebaseFirestore
        .collection("chats/${getConversationId(user.userId)}/messages/")
        .snapshots();
  }

  /// get conversation id
  static String getConversationId(String id) =>
      user.uid.hashCode <= id.hashCode
          ? '${user.uid}_$id'
          : '${id}_${user.uid}';

  /// --- send message --- ///
  static Future<void> sendMessage(ChatUserModel user, String msg) async {
    final ref = firebaseFirestore.collection(
      "chats/${getConversationId(user.userId)}/messages/",
    );

    /// message sending time also use as message id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    /// message to send
    final MessageModel messageModel = MessageModel(
      toId: user.userId,
      msg: msg,
      read: "false",
      type: Type.text,
      fromId: user.userId,
      sent: time,
    );
    await ref.doc(time).set(messageModel.toJson());
  }

  /// update read status of message
  static Future<void> updateMessageReadStatus(MessageModel message) async {
    firebaseFirestore
        .collection('chats/${getConversationId(message.fromId)}/messages')
        .doc(message.sent)
        .update({"read": "true"});
  }

  /// get only last message
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
    ChatUserModel user,
  ) {
    return firebaseFirestore
        .collection("chats/${getConversationId(user.userId)}/messages")
        .orderBy("sent", descending: true)
        .limit(1)
        .snapshots();
  }
}
