import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ping_me/api/apis.dart';
import 'package:ping_me/helper/my_date_util.dart';
import 'package:ping_me/model/message_model.dart';
import 'package:ping_me/screen/chat_screen.dart';

import '../model/chat_user_model.dart';
import '../utils/custom_text_style.dart';

class UserChatCard extends StatefulWidget {
  final ChatUserModel user;
  UserChatCard({required this.user});

  @override
  State<UserChatCard> createState() => _UserChatCardState();
}

class _UserChatCardState extends State<UserChatCard> {
  /// last message
  MessageModel? _messageModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data!.docs;
              final list =
                  data.map((e) => MessageModel.fromJson(e.data())).toList() ??
                  [];
              if (list.isNotEmpty) {
                _messageModel = list[0];
              }
            }
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      /// Profile image
                      ClipOval(
                        child: CachedNetworkImage(
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.imageUrl!,
                          placeholder:
                              (context, url) => SizedBox(
                                width: 56,
                                height: 56,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(CupertinoIcons.person, size: 28),
                              ),
                        ),
                      ),

                      /// online
                      if (widget.user.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// --- username --- ///
                            Text(
                              widget.user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _messageModel != null
                                  ? _messageModel!.msg
                                  : widget.user.about.toString(),
                              maxLines: 1,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),

                  /// --- latest active time or blue dot indicator --- ///
                  _messageModel == null
                      ? const SizedBox()
                      : _messageModel!.read.isEmpty &&
                          _messageModel!.fromId != APIs.user.uid
                      ? Container(
                        // Show blue dot
                        height: 15,
                        width: 15,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      )
                      : Text(
                        // Show time
                        MyDateUtil.getLastMessageTime(
                          context: context,
                          time: _messageModel!.sent,
                        ),
                        style: myTextStyle15(context),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
