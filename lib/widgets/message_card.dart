import 'package:flutter/material.dart';
import 'package:ping_me/model/message_model.dart';
import 'package:ping_me/utils/colors.dart';

import '../api/apis.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.messageModel});
  final MessageModel messageModel;

  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == messageModel.fromId
        ? _blueMessage(context)
        : _greenMessage(context);
  }

  /// 🟦 Sender message - current user
  Widget _blueMessage(BuildContext context) {
    return Text("Hello");
  }

  /// 🟩 Receiver message - other user
  Widget _greenMessage(BuildContext context) {
    return Text("Hello");
  }
}
