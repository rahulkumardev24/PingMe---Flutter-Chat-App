import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping_me/api/apis.dart';
import 'package:ping_me/screen/auth/auth_service/auth_service.dart';
import 'package:ping_me/screen/profile_screen.dart';
import 'package:ping_me/utils/custom_text_style.dart';
import 'package:ping_me/widgets/user_chat_card.dart';
import '../helper/dialogs.dart';
import '../model/chat_user_model.dart';
import '../utils/colors.dart';

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
    APIs.updateActiveStatus(true);

    /// for updating user active status according to lifecycle events
    /// resume -- active or online
    /// pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      print('Message: $message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40)),
            ),
            title: Text(
              "Ping Me",
              style: myTextStyle24(
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
            backgroundColor: AppColors.primary,
          ),

          /// ----- Body ---- ///
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
                  stream: APIs.getMyUsersId(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      Center(child: Text("Something went going wrong"));
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!.docs;
                      if (data.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.black38,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Your contacts list is empty",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Tap the + button to add new users",
                                  textAlign: TextAlign.center,
                                  style: myTextStyle18(
                                    context,
                                    fontColor: Colors.grey.shade500,
                                  ),
                                ),
                                SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () => _userAddDialog(),
                                  icon: Icon(
                                    Icons.person_add_alt_1,
                                    size: 27,
                                    color: AppColors.primary,
                                  ),
                                  label: Text(
                                    "Add User",
                                    style: myTextStyle15(
                                      context,
                                      fontColor: AppColors.primary,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(60),
                                      side: BorderSide(
                                        width: 1,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return StreamBuilder(
                        stream: APIs.getAllUsers(
                          List<String>.from(
                            snapshot.data!.docs.map((e) => e.id),
                          ),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                  _isSearching
                                      ? _searchUser.length
                                      : list.length,
                              itemBuilder: (context, index) {
                                /// Convert doc to model
                                /// Clear and add fetched users
                                users =
                                    list
                                        .map(
                                          (doc) => ChatUserModel.fromJson(
                                            doc.data(),
                                          ),
                                        )
                                        .toList();
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
                      );
                    }
                    return Center(child: Text("No user found "));
                  },
                ),
              ),
            ],
          ),

          /// floating action button
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.secondary,
            elevation: 0,
            onPressed: () {
              _userAddDialog();
            },
            child: const Icon(Icons.add_comment_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// add user person
  void _userAddDialog() {
    String email = "";
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title Section
                  Row(
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        color: AppColors.blue,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text("Add New User", style: myTextStyle18(context)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// Form Section
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onChanged: (value) => email = value,
                      decoration: InputDecoration(
                        hintText: "user@example.com",
                        hintStyle: myTextStyle15(
                          context,
                          fontColor: Colors.black54,
                        ),
                        labelText: "Email Address",
                        labelStyle: myTextStyle15(
                          context,
                          fontColor: AppColors.primary,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.blue.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.blue.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                  const SizedBox(height: 25),

                  ///---- Button Section ---- ///
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      /// cancel button ///
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: myTextStyle18(
                            context,
                            fontColor: Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// user add button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            APIs.addChatUser(email).then((success) {
                              if (!success) {
                                Dialogs.myShowSnackBar(
                                  context,
                                  "User does not exist",
                                  Colors.red.shade100,
                                  Colors.black87,
                                );
                              } else {
                                Navigator.pop(context);
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary.withAlpha(120),
                          foregroundColor: Colors.white,
                          side: BorderSide(width: 1, color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Add User",
                          style: myTextStyle18(
                            context,
                            fontColor: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
