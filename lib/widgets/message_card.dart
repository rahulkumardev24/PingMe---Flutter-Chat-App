import 'package:flutter/material.dart';
import 'package:ping_me/helper/my_date_util.dart';
import 'package:ping_me/model/message_model.dart';
import 'package:ping_me/utils/colors.dart';
import 'package:ping_me/utils/custom_text_style.dart';

import '../api/apis.dart';

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
    return isMe ? _orangeMessage() : _blueMessage();
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
            padding: EdgeInsets.symmetric(
              horizontal: mqData.width * .04,
              vertical: mqData.height * .015,
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
            child: Text(
              widget.messageModel.msg,
              style: myTextStyle18(
                context,
                fontColor: Colors.black54,
                fontWeight: FontWeight.w500,
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
            padding: EdgeInsets.symmetric(
              horizontal: mqData.width * .04,
              vertical: mqData.height * .015,
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
            child: Text(
              widget.messageModel.msg,
              style: myTextStyle18(
                context,
                fontColor: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

}
