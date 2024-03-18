// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:chat_screen/src/common/glowing_action_button.dart';

class ActionBar extends StatelessWidget {
  const ActionBar({
    Key? key,
    required this.messageController,
    required this.onSendPressed,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onPaperClipPressed,
  }) : super(key: key);

  final TextEditingController messageController;
  final VoidCallback onSendPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onPaperClipPressed;
  void _showImageSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text(
                  'Open Camera',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => onCameraPressed(),
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text(
                  'Pick from Gallery',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => onGalleryPressed(),
              ),
            ],
          ),
        );
      },
    );
  }

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
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IconButton(
                    onPressed: () => _showImageSourceBottomSheet(context),
                    icon: const Icon(CupertinoIcons.camera_fill)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: IconButton(
                  onPressed: onPaperClipPressed, 
                  icon: const Icon(CupertinoIcons.paperclip))
              ),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextField(
                textInputAction: TextInputAction.newline,
                maxLines: null,
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
                onPressed: onSendPressed),
          )
        ],
      ),
    );
  }
}
