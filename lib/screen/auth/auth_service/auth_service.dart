
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ping_me/api/apis.dart';

import '../../../model/chat_user_model.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

class AuthService {
  Future<User?> signInWithGoogle() async {
    try {
      // Step 1: Google sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Step 2: Get Google Auth credentials
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 3: Sign in with Firebase
      final UserCredential userCredential = await APIs.auth
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      // Step 4: Check if user already exists in Firestore
      if (user != null) {
        final userDoc = APIs.firebaseFirestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        final time = DateTime.now().millisecondsSinceEpoch.toString();
        /// If the user doesn't exist, create a new user document
        if (!docSnapshot.exists) {
          final newUser = ChatUserModel(
            userId: user.uid,
            name: user.displayName ?? "No Name",
            email: user.email ?? "",
            imageUrl: user.photoURL,
            about: "Hey, i'am using we chat",
            lastActive: time,
            isOnline: false,
            pushToken: "",
          );

          /// Set user data in Firestore (only if the user is new)
          await userDoc.set(newUser.toJson());
        }
        /// Return the existing user if the user exists in Firestore
        return user;
      }
      return null;
    } catch (error) {
      print("Google Sign-in failed: $error");
      return null;
    }
  }

  // Optional: Sign out method
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await APIs.auth.signOut();
  }
}
