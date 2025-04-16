import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ping_me/model/chat_user_model.dart';
import 'package:ping_me/model/message_model.dart';
import 'package:ping_me/utils/custom_text_style.dart';
import 'package:ping_me/widgets/message_card.dart';

import '../api/apis.dart';
import '../utils/colors.dart';

class ChatScreen extends StatefulWidget {
  final ChatUserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<MessageModel> _list = [];
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        /// --- appbar --- ///
        appBar: AppBar(
          flexibleSpace: _buildAppBar(),
          automaticallyImplyLeading: false,
        ),

        /// ---- body ---- ///
        body: SafeArea(
          child: Column(
            children: [
              /// ---- steam builder --- ///
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Something went wrong"));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "Say Hii! 👋",
                          style: myTextStyle24(context),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      _list.add(MessageModel(toId: "xyz", msg: "Hii", read: "", type: Type.text, fromId: APIs.user.uid, sent: "12:00AM"));
                      _list.add(MessageModel(toId: "xyz", msg: "Hii", read: "", type: Type.text, fromId: APIs.user.uid, sent: "12:00AM"));

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          return MessageCard(messageModel: _list[index]);
                        },
                      );
                    }
                    return Center(child: Text("Something went wrong"));
                  },
                ),
              ),

              /// --- here we call chat input box --- ///
              _chatInput(),
            ],
          ),
        ),
      ),
    );
  }

  /// --- here we create custom app bar --- ///
  Widget _buildAppBar() {
    return InkWell(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 31),
          Row(
            children: [
              /// --- back button --- ///
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_rounded),
              ),

              /// --- user image --- ////
              SizedBox(
                width: 50,
                height: 50,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.user.imageUrl.toString(),
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => const CircularProgressIndicator(),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(width: 11),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- user name --- ///
                  Text(
                    widget.user.name,
                    style: myTextStyle18(context, fontColor: Colors.black87),
                  ),
                  Text(
                    "last seen is not available",
                    style: myTextStyle12(context, fontColor: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---- chat input box ---- ////
  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2.0,
                  vertical: 2,
                ),
                child: Row(
                  children: [
                    /// Left side - emoji and attachment buttons
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: AppColors.secondary,
                      ),
                      onPressed: () {},
                    ),

                    /// Middle - text input field
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type a message...',
                          hintStyle: myTextStyle15(
                            fontColor: AppColors.secondary,
                            context,
                          ),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.image, color: AppColors.secondary),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.photo_camera_rounded,
                        color: AppColors.secondary,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Right side - send button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
