import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ping_me/model/chat_user_model.dart';
import 'package:ping_me/screen/auth/auth_service/auth_service.dart';
import 'package:ping_me/utils/custom_text_style.dart';
import 'package:ping_me/widgets/my_navigation_button.dart';
import '../helper/my_date_util.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUserModel user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ViewProfileScreen> {
  late Size mqData = MediaQuery.of(context).size;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mqData = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        flexibleSpace: _myAppBar(),
        automaticallyImplyLeading: false,
        toolbarHeight: mqData.height * 0.4,
      ),

      /// --- body --- ///
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                /// User Email with nice icon
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.email, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.user.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// About Section
                _buildProfileSection(
                  context,
                  title: "About",
                  content: widget.user.about.toString(),
                  icon: Icons.info_outline,
                ),

                const SizedBox(height: 15),

                /// Status Section
                _buildProfileSection(
                  context,
                  title: "Status",
                  content: widget.user.status.toString(),
                  icon: Icons.circle_notifications,
                ),

                const SizedBox(height: 30),

                /// Joined Date Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Joined ${MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt)}",
                        style: myTextStyle15(
                          context,
                          fontColor: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reusable Profile Section Widget
  Widget _buildProfileSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      color: Colors.greenAccent.shade100.withAlpha(60),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  "$title:",
                  style: myTextStyle15(
                    context,
                    fontWeight: FontWeight.bold,
                    fontColor: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                content,
                style: myTextStyle15(context, fontColor: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _myAppBar() {
    return SizedBox(
      height: mqData.height * 0.38,
      child: Stack(
        children: [
          Container(
            width: mqData.width,
            height: mqData.height * 0.3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade100],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    /// navigation button --> Back button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 27,
                      ),
                      child: MyNavigationButton(
                        btnIcon: Icons.arrow_back_ios_new_rounded,
                        iconSize: 27,
                        btnBackground: Colors.white30,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.user.name,
                  style: myTextStyle24(context, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: mqData.width * 0.3,
            child: Container(
              width: mqData.width * 0.4,
              height: mqData.width * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 3, color: Colors.greenAccent),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withAlpha(70),
                    blurRadius: 3,
                    spreadRadius: 12,
                  ),
                ],
              ),

              /// --- user image --- ///
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.user.imageUrl.toString(),
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) =>
                          Icon(Icons.person, size: 60, color: Colors.grey[400]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
