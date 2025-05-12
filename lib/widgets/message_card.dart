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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Message Options List
              ..._buildOptionItems(isMe),
              SizedBox(height: mqData.height * .05),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildOptionItems(bool isMe) {
    return [
      /// Copy or Download option
      _OptionItem(
        icon: Icon(
          widget.messageModel.type == Type.text
              ? Icons.copy_rounded
              : Icons.download_rounded,
          color: Colors.blue.shade600,
        ),
        name:
            widget.messageModel.type == Type.text ? 'Copy Text' : 'Save Image',
        description:
            widget.messageModel.type == Type.text
                ? 'Copy message to clipboard'
                : 'Save image to gallery',
        onTap: (context) async {
          if (widget.messageModel.type == Type.text) {
            await Clipboard.setData(
              ClipboardData(text: widget.messageModel.msg),
            );
            Navigator.pop(context);
            Dialogs.myShowSnackBar(
              context,
              "Text Copied",
              Colors.greenAccent.shade100,
              Colors.black54,
            );
          } else {
            try {
              await GallerySaver.saveImage(
                widget.messageModel.msg,
                albumName: 'Ping Me',
              ).then((success) {
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success != null && success) {
                    Dialogs.myShowSnackBar(
                      context,
                      "Image Downloaded",
                      Colors.greenAccent.shade200,
                      Colors.black54,
                    );
                  }
                }
              });
            } catch (e) {
              debugPrint('ErrorWhileSavingImg: $e');
            }
          }
        },
      ),

      /// Edit option (only for text messages sent by me)
      if (widget.messageModel.type == Type.text && isMe)
        _OptionItem(
          icon: Icon(Icons.edit_rounded, color: Colors.orange.shade600),
          name: 'Edit Message',
          description: 'Modify this message',
          onTap: (context) {
            Navigator.pop(context);
            _messageUpdateDialog();
          },
        ),

      // Delete option (only for my messages)
      if (isMe)
        _OptionItem(
          icon: Icon(Icons.delete_forever_rounded, color: Colors.red.shade600),
          name: 'Delete Message',
          description: 'Remove this message for everyone',
          onTap: (context) async {
            await APIs.deleteMessage(widget.messageModel);
            Navigator.pop(context);
          },
        ),

      // Message timestamps
      _OptionItem(
        icon: Icon(Icons.access_time_rounded, color: Colors.grey.shade600),
        name:
            'Sent at ${MyDateUtil.getMessageTime(time: widget.messageModel.sent)}',
        onTap: (context) {},
      ),

      // Read receipt
      _OptionItem(
        icon: Icon(
          Icons.done_all_rounded,
          color:
              widget.messageModel.read == "false" ||
                      widget.messageModel.read.isEmpty
                  ? Colors.grey
                  : Colors.blue,
        ),
        name:
            widget.messageModel.read == "false" ||
                    widget.messageModel.read.isEmpty
                ? 'Not seen yet'
                : 'Seen at ${MyDateUtil.getMessageTime(time: widget.messageModel.read)}',
        onTap: (context) {},
      ),
    ];
  }

  /// dialog for updating message content
  void _messageUpdateDialog() {
    // Check if widget is still mounted before proceeding
    if (!mounted) return;

    String updatedMessage = widget.messageModel.msg;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Check again in case widget was disposed while dialog was building
        if (!mounted) return const SizedBox.shrink();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  children: [
                    Icon(Icons.edit_rounded, color: AppColors.blue, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      "Edit Message",
                      style: myTextStyle18(
                        context,
                        fontWeight: FontWeight.w600,
                        fontColor: AppColors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Text Field
                TextFormField(
                  initialValue: updatedMessage,
                  maxLines: 4,
                  minLines: 1,
                  onChanged: (value) => updatedMessage = value,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue.shade400,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 24),

                /// Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: Text("Cancel", style: myTextStyle18(context)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // Use dialogContext for navigation
                          Navigator.pop(dialogContext);
                          if (mounted) {
                            await APIs.updateMessage(
                              widget.messageModel,
                              updatedMessage,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to update message: $e"),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Update",
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
        );
      },
    );
  }
}

/// custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final String? description;
  final Function(BuildContext) onTap;

  const _OptionItem({
    required this.icon,
    required this.name,
    this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: icon.color?.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      ),

      /// title
      title: Text(
        name,
        style: myTextStyle15(context, fontWeight: FontWeight.w500),
      ),

      /// sub title
      subtitle:
          description != null
              ? Text(
                description!,
                style: myTextStyle12(context, fontColor: Colors.grey.shade600),
              )
              : null,
      onTap: () => onTap(context),
    );
  }
}
