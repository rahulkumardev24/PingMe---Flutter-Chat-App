import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  /// --- firebase messaging --- ///
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  /// --- Current user --- ///
  static ChatUserModel? currentUser;

  /// Function to return current user
  static User get user => auth.currentUser!;

  ///  Function to get all users from 'users' collection
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
    List<String> userIds,
  ) {
    return firebaseFirestore
        .collection("users")
        .where('userId', whereIn: userIds)
        .snapshots();
  }

  ///  for adding an chat user info
  static Future<bool> addChatUser(String email) async {
    final data =
        await firebaseFirestore
            .collection("users")
            .where("email", isEqualTo: email)
            .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      /// if user exit
      firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .collection("my_users")
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      /// user does not exit
      return false;
    }
  }

  ///  Function to get all users from 'users' collection
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .collection("my_users")
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

      /// here we call function to get token for push notification
      getFirebaseMessagingToken();
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

  /// ------ for getting specific info --- ///
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
    ChatUserModel chatUser,
  ) {
    return firebaseFirestore
        .collection("users")
        .where("userId", isEqualTo: chatUser.userId)
        .snapshots();
  }

  /// --- update online or last seen status --- ///
  static Future<void> updateActiveStatus(bool isOnline) async {
    firebaseFirestore.collection("users").doc(user.uid).update({
      "isOnline": isOnline,
      "lastActive": DateTime.now().millisecondsSinceEpoch.toString(),
      "pushToken": currentUser!.pushToken,
    });
  }

  /// For getting firebase messaging (push Notification)
  static Future<void> getFirebaseMessagingToken() async {
    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await firebaseMessaging.getToken().then((t) {
      if (t != null) {
        currentUser!.pushToken = t;
        print("Push Token : $t");
      }
    });
  }

  /// send push notification
  static Future<void> sendPushNotification(
    ChatUserModel chatUser,
    String msg,
  ) async {}

  /// ******************* Chat Screen Related APIs ********************* ///
  /// chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc) --> message (data)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
    ChatUserModel user,
  ) {
    return firebaseFirestore
        .collection("chats/${getConversationId(user.userId)}/messages/")
        .orderBy('sent', descending: true)
        .snapshots();
  }

  /// get conversation id
  static String getConversationId(String id) =>
      user.uid.hashCode <= id.hashCode
          ? '${user.uid}_$id'
          : '${id}_${user.uid}';

  /// --- send message --- ///
  static Future<void> sendMessage(
    ChatUserModel chatUser,
    String msg,
    Type type,
  ) async {
    final ref = firebaseFirestore.collection(
      "chats/${getConversationId(chatUser.userId)}/messages/",
    );

    /// message sending time also use as message id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    /// message to send
    final MessageModel messageModel = MessageModel(
      toId: chatUser.userId,
      msg: msg,
      read: "false",
      type: type,
      fromId: user.uid,
      sent: time,
    );
    await ref.doc(time).set(messageModel.toJson());
  }

  /// update read status of message
  static Future<void> updateMessageReadStatus(MessageModel message) async {
    firebaseFirestore
        .collection('chats/${getConversationId(message.fromId)}/messages')
        .doc(message.sent)
        .update({"read": DateTime.now().millisecondsSinceEpoch.toString()});
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

  /// send chat image
  static Future<void> sendChatImage(ChatUserModel chatUser, File file) async {
    /// getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = firebaseStorage.ref().child(
      'images/${getConversationId(chatUser.userId)}/${DateTime.now().millisecondsSinceEpoch}.$ext',
    );

    /// uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((
      p0,
    ) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    /// updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  /// delete message
  static Future<void> deleteMessage(MessageModel message) async {
    await firebaseFirestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await firebaseStorage.refFromURL(message.msg).delete();
    }
  }

  /// delete update
  static Future<void> updateMessage(
    MessageModel message,
    String updatedMsg,
  ) async {
    await firebaseFirestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({"msg": updatedMsg});
  }
}
