import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ping_me/api/apis.dart';
import 'package:ping_me/screen/auth/auth_service/auth_service.dart';
import 'package:ping_me/utils/custom_text_style.dart';
import 'package:ping_me/widgets/user_chat_card.dart';

import '../model/chat_user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Ping Me",
          style: myTextStyle18(
            context,
          ).copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home_filled, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[800]!, Colors.blue[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: APIs.firebaseFirestore.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }else if(snapshot.hasError){
            return Center(child: Text("Something went wrong"));
          } else if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
            return Center(child: Text("No user found"));
          } else if (snapshot.hasData) {
            final list = snapshot.data!.docs;

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                // Convert doc to model
                final userModel = ChatUserModel.fromJson(list[index].data());
                return UserChatCard(
                  userName: userModel.name,
                  lastMessage: 'This is my last message',
                  time: '12:00 AM',
                  imagePath: userModel.imageUrl ?? '', // null check
                );
              },
            );
          }

          return Center(child: Text("Something went wrong"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => authService.signOut(),
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
    );
  }
}
