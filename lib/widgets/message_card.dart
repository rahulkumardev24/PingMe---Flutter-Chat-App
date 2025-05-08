import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:ping_me/helper/my_date_util.dart';
import 'package:ping_me/model/message_model.dart';
import 'package:ping_me/utils/colors.dart';
import 'package:ping_me/utils/custom_text_style.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.messageModel});
  final MessageModel messageModel;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  late Size mqData = MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.messageModel.fromId;
    return InkWell(
      onLongPress: () {
        _messageModelBottomSheet(isMe);
      },
      child: isMe ? _orangeMessage() : _blueMessage(),
    );
  }

  /// 🟦 Sender message - current user
  Widget _blueMessage() {
    /// update last read message if sender and receiver are different
    if (widget.messageModel.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.messageModel);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
              widget.messageModel.type == Type.image
                  ? mqData.width * .01
                  : mqData.width * .03,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: mqData.width * .04,
              vertical: mqData.height * .01,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blueAccent.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(1),
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.lightBlue),
            ),

            /// message and image show here
            child:
                widget.messageModel.type == Type.text
                    ?
                    /// text message show here
                    Text(
                      widget.messageModel.msg,
                      style: myTextStyle18(
                        context,
                        fontColor: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                    /// --- here image show --- ///
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.messageModel.msg,
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
                              child: Icon(Icons.image, size: 28),
                            ),
                      ),
                    ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mqData.width * .04),

          /// sent time
          child: Text(
            MyDateUtil.getFormattedTime(
              context: context,
              time: widget.messageModel.sent,
            ),
            style: myTextStyle15(context, fontColor: Colors.black38),
          ),
        ),
      ],
    );
  }

  /// 🟩 Receiver message - other user
  Widget _orangeMessage() {
    bool isSentByMe = widget.messageModel.fromId == APIs.user.uid;
    bool isRead = widget.messageModel.read != "false";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mqData.width * .04),

            /// Show double-tick icon only for messages sent by me
            if (isSentByMe)
              Icon(
                Icons.done_all_rounded,
                size: 20,
                color: isRead ? Colors.blue : Colors.grey,
              ),

            SizedBox(width: 4),

            /// Sent time display
            Text(
              MyDateUtil.getFormattedTime(
                context: context,
                time: widget.messageModel.sent,
              ),
              style: myTextStyle15(context, fontColor: Colors.black38),
            ),
          ],
        ),

        Flexible(
          child: Container(
            padding: EdgeInsets.all(
              widget.messageModel.type == Type.image
                  ? mqData.width * .01
                  : mqData.width * .03,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: mqData.width * .04,
              vertical: mqData.height * .01,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withAlpha(100),
                  AppColors.primary.withAlpha(100),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(1),
                topRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.orange),
            ),

            /// message or image show here
            child:
                widget.messageModel.type == Type.text
                    ? Text(
                      widget.messageModel.msg,
                      style: myTextStyle18(
                        context,
                        fontColor: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                    /// --- here image show --- ///
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: widget.messageModel.msg,
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
                              child: Icon(Icons.image, size: 28),
                            ),
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  /// --- model bottom sheet --- ///
  void _messageModelBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.messageModel.type == Type.text
                  ?
                  /// text copy
                  _OptionItem(
                    icon: Icon(Icons.copy_rounded),
                    name: 'Copy Text',
                    onTap: (BuildContext) async {
                      await Clipboard.setData(
                        ClipboardData(text: widget.messageModel.msg),
                      ).then((value) {
                        Navigator.pop(context);
                        Dialogs.myShowSnackBar(
                          context,
                          "Text Copied",
                          Colors.greenAccent.shade100,
                          Colors.black54,
                        );
                      });
                    },
                  )
                  :
                  /// --- download --- ///
                  _OptionItem(
                    icon: Icon(Icons.download_rounded),
                    name: 'Save image',
                    onTap: (BuildContext) async {
                      try {
                        print('Image Url: ${widget.messageModel.msg}');
                        await GallerySaver.saveImage(
                          widget.messageModel.msg,
                          albumName: 'We Chat',
                        ).then((success) {
                          if (BuildContext.mounted) {
                            //for hiding bottom sheet
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.myShowSnackBar(
                                context,
                                "Image is Downloaded",
                                Colors.greenAccent.shade200,
                                Colors.black54,
                              );
                            }
                          }
                        });
                      } catch (e) {
                        print('ErrorWhileSavingImg: $e');
                      }
                    },
                  ),

              /// edit message
              if (widget.messageModel.type == Type.text && isMe)
                _OptionItem(
                  icon: Icon(Icons.edit_rounded),
                  name: 'Edit Message',
                  onTap: (BuildContext) {
                    _messageUpdateDialog();
                  },
                ),

              /// delete message
              if (isMe)
                _OptionItem(
                  icon: Icon(Icons.delete_forever_rounded),
                  name: 'Delete Message',
                  onTap: (BuildContext) async {
                    await APIs.deleteMessage(widget.messageModel).then((value) {
                      Navigator.pop(context);
                    });
                  },
                ),

              /// send time
              _OptionItem(
                icon: Icon(Icons.remove_red_eye_rounded),
                name:
                    'Send At : ${MyDateUtil.getMessageTime(time: widget.messageModel.sent)}',
                onTap: (BuildContext) {},
              ),

              /// read time
              _OptionItem(
                icon: Icon(Icons.remove_red_eye_rounded),
                name:
                    widget.messageModel.read == "false" ||
                            widget.messageModel.read.isEmpty
                        ? 'Read At : Not seen yet'
                        : 'Read At : ${MyDateUtil.getMessageTime(time: widget.messageModel.read)}',
                onTap: (BuildContext) {},
              ),
            ],
          ),
        );
      },
    );
  }

  /// dialog for updating message content
  void _messageUpdateDialog() {
    String updatedMessage = widget.messageModel.msg;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            /// title
            title: Row(
              children: [
                Icon(Icons.message, color: Colors.blue, size: 28),
                Text("Update Message"),
              ],
            ),

            /// content
            content: TextFormField(
              initialValue: updatedMessage,
              maxLines: null,
              onChanged: (value) => updatedMessage = value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  APIs.updateMessage(widget.messageModel, updatedMessage);
                },
                child: Text("Update"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("cancel"),
              ),
            ],
          ),
    );
  }
}

/// custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final Function(BuildContext) onTap;

  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mqData = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => onTap(context),
      child: Padding(
        padding: EdgeInsets.only(
          left: mqData.width * .05,
          top: mqData.height * .015,
          bottom: mqData.height * .015,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '    $name',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
