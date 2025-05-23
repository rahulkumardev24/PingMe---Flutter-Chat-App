import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ping_me/helper/my_date_util.dart';
import 'package:ping_me/model/chat_user_model.dart';
import 'package:ping_me/model/message_model.dart';
import 'package:ping_me/screen/view_profile_screen.dart';
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
  /// ---- store all messages  --- ///
  List<MessageModel> _list = [];
  final _textController = TextEditingController();
  File? imageFile;
  bool _showEmoji = false;
  bool _isUploading = false;

  @override
  void dispose() {
    super.dispose();
  }

  /// --- pick image form camera --- ///
  Future<void> _pickImageFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
      setState(() {
        _isUploading = true;
      });

      /// here we call profile image change function
      APIs.sendChatImage(widget.user, imageFile!).then((value) {
        setState(() {
          _isUploading = false;
        });
      });
    }
  }

  /// --- pick image from gallery --- ///
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();

    /// pick multiple image
    final List<XFile> pickedImage = await picker.pickMultiImage(
      imageQuality: 70,
    );

    /// uploading image
    for (var myImage in pickedImage) {
      setState(() {
        _isUploading = true;
      });

      /// here we call profile image change function
      await APIs.sendChatImage(widget.user, File(myImage.path)).then((value) {
        setState(() {
          _isUploading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// final mqData = MediaQuery.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        /// --- appbar --- ///
        appBar: AppBar(
          flexibleSpace: _buildAppBar(),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.white,

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
                        reverse: true,
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

              /// ---- Liner Progress indicator --> Only Show when uploading ----- ///
              if (_isUploading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.black12,
                    color: Colors.lightBlue.shade200,
                    borderRadius: BorderRadius.circular(10),
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
      onTap: () {
        /// click on user profile navigate to view profile screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewProfileScreen(user: widget.user),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withAlpha(100),
              AppColors.secondary.withAlpha(100),
            ],
          ),
        ),
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LinearProgressIndicator();
            }
            final data = snapshot.data?.docs ?? [];
            final list =
                data.map((e) => ChatUserModel.fromJson(e.data())).toList();
            return Column(
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
                          imageUrl:
                              list.isNotEmpty
                                  ? list[0].imageUrl ?? ''
                                  : widget.user.imageUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) =>
                                  const CircularProgressIndicator(),
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
                          list.isNotEmpty
                              ? list[0].name ?? 'Unknown'
                              : widget.user.name ?? 'Unknown',
                          style: myTextStyle18(
                            context,
                            fontColor: Colors.black87,
                          ),
                        ),

                        /// --- last active --- ///
                        Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive.toString(),
                                  )
                              : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive.toString(),
                              ),
                          style: myTextStyle12(context, fontColor: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
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
                      onPressed: () {
                        /// call function
                        _pickImageFromGallery();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.photo_camera_rounded,
                        color: AppColors.secondary,
                      ),
                      onPressed: () {
                        _pickImageFromCamera();
                      },
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
                  /// on first message (add user to my friend list (user list))
                  if (_list.isEmpty) {
                    APIs.sendFirstMessage(
                      widget.user,
                      _textController.text,
                      Type.text,
                    );
                  }
                  /// --- simply send message
                  else {
                    APIs.sendMessage(
                      widget.user,
                      _textController.text,
                      Type.text,
                    );
                  }
                  _textController.text = "";
                  Dialogs.myShowSnackBar(
                    context,
                    "Please type a message",
                    Colors.red,
                    Colors.white,
                  );
                } else {
                  APIs.sendMessage(
                    widget.user,
                    _textController.text,
                    Type.text,
                  );
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
