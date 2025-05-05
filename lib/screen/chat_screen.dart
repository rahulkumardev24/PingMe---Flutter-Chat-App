import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:ping_me/model/chat_user_model.dart';
import 'package:ping_me/model/message_model.dart';
import 'package:ping_me/utils/custom_text_style.dart';
import 'package:ping_me/widgets/message_card.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../utils/colors.dart';

class ChatScreen extends StatefulWidget {
  final ChatUserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// store all messages
  List<MessageModel> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqData = MediaQuery.of(context);
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
                  stream: APIs.getAllMessage(widget.user),
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
                    } else {
                      final data = snapshot.data!.docs;
                      _list =
                          data
                              .map((doc) => MessageModel.fromJson(doc.data()))
                              .toList();
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          final message = _list[index];

                          /// Update read status if unread and message is for current user
                          if (message.read == "false" &&
                              message.toId == APIs.user.uid) {
                            APIs.updateMessageReadStatus(message);
                          }

                          return MessageCard(messageModel: message);
                        },
                      );
                    }
                  },
                ),
              ),

              /// --- here we call chat input box --- ///
              _chatInput(),

              /// -------- here we show the emoji ---------- ///
              _showEmoji
                  ? SizedBox(
                    height: 300,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        emojiViewConfig: EmojiViewConfig(emojiSizeMax: 28),
                      ),
                    ),
                  )
                  : const SizedBox(),
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
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                    ),

                    /// Middle - text input field
                    Expanded(
                      child: TextField(
                        controller: _textController,
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
                        onTap: () {
                          setState(() {
                            if (_showEmoji) _showEmoji = !_showEmoji;
                          });
                        },
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
              onPressed: () {
                if (_textController.text.isEmpty) {
                  Dialogs.myShowSnackBar(
                    context,
                    "Please type a message",
                    Colors.red,
                    Colors.white,
                  );
                } else {
                  APIs.sendMessage(widget.user, _textController.text);
                  _textController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
