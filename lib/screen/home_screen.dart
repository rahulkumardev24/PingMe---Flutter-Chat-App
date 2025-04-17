import 'package:flutter/material.dart';
import 'package:ping_me/api/apis.dart';
import 'package:ping_me/screen/auth/auth_service/auth_service.dart';
import 'package:ping_me/screen/profile_screen.dart';
import 'package:ping_me/utils/custom_text_style.dart';
import 'package:ping_me/widgets/user_chat_card.dart';
import '../model/chat_user_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  bool _isSearching = false;
  List<ChatUserModel> users = [];
  final List<ChatUserModel> _searchUser = [];

  @override
  void initState() {
    super.initState();
    APIs.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async {
          if (_isSearching) {
            setState(() {
              _isSearching = false;
            });
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],

          /// --- App bar --- ///
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
                icon: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
              ),

              /// --- here we navigate to profile screen --- ///
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(user: APIs.currentUser!),
                    ),
                  );
                },
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

          /// --- Body --- ///
          body: Column(
            children: [
              _isSearching
                  ? TextField(
                    decoration: InputDecoration(hintText: "Search..."),
                    autofocus: true,
                    onChanged: (val) {
                      /// --- search logic --- ///
                      _searchUser.clear();
                      for (var i in users) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchUser.add(i);
                          setState(() {});
                        }
                      }
                    },
                  )
                  : SizedBox(),
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Something went wrong"));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No user found"));
                    } else if (snapshot.hasData) {
                      final list = snapshot.data!.docs;
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount:
                            _isSearching ? _searchUser.length : list.length,
                        itemBuilder: (context, index) {
                          /// Convert doc to model
                          /// Clear and add fetched users
                          users = list.map((doc) => ChatUserModel.fromJson(doc.data()),).toList();
                          return UserChatCard(
                            user:
                            _isSearching
                                    ? _searchUser[index]
                                    : users[index],
                          );
                        },
                      );
                    }
                    return Center(child: Text("Something went wrong"));
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => authService.signOut(),
            backgroundColor: Colors.blue[600],
            child: const Icon(Icons.add_comment_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
