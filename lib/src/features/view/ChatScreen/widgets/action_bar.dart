import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chat_screen/src/common/glowing_action_button.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({
    Key? key,
    required this.messageController,
    required this.onSendPressed,
  }) : super(key: key);
  
  final TextEditingController messageController;
  final VoidCallback onSendPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
              width: 2,
              color: Theme.of(context).dividerColor,
            ))),
            child: const Row(children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(CupertinoIcons.camera_fill),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1),
                child: Icon(CupertinoIcons.paperclip),
              ),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextField(
                controller: messageController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Enter your message',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 24,
            ),
            child: GlowingActionButton(
                color: const Color(0xFFD6755B),
                icon: Icons.send_rounded,
                onPressed: onSendPressed
              ),
          )
        ],
      ),
    );
  }
}
