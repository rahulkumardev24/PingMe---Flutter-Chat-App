import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ping_me/model/chat_user_model.dart';
import 'package:ping_me/utils/custom_text_style.dart';

import '../screen/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUserModel user;
  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final mqData = MediaQuery.of(context).size;
    return AlertDialog(
      backgroundColor: Colors.white.withAlpha(150),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: mqData.width * 0.6,
        height: mqData.height * 0.35,
        child: Stack(
          children: [
            Text(user.name, style: myTextStyle15(context)),

            /// --- user image --- ///
            Center(
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.imageUrl.toString(),
                  fit: BoxFit.cover,
                  width: mqData.width * 0.6,
                  height: mqData.width * 0.6,
                  placeholder:
                      (context, url) =>
                          Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) =>
                          Icon(Icons.person, size: 60, color: Colors.grey[400]),
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);

                  /// Navigate to View profile screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewProfileScreen(user: user),
                    ),
                  );
                },
                child: Icon(Icons.info_outline_rounded, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
