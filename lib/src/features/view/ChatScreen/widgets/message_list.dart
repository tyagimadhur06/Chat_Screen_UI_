// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class MessageList extends StatefulWidget {
  const MessageList(
      {Key? key,
      required this.messages,
      required this.sharedFiles,
      required this.messageData,
      required this.scrollController})
      : super(key: key);

  @override
  State<MessageList> createState() => MessageListState();
  final List<String> messages;
  final List<SharedMediaFile> sharedFiles;
  final List<Map<String, dynamic>> messageData;
  final scrollController;
}

class MessageListState extends State<MessageList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: ListView.builder(
          shrinkWrap: true,
          reverse: true,
          controller: widget.scrollController,
          itemCount: widget.messageData.length,
          //itemCount: widget.messages.length + widget.sharedFiles.length,
          itemBuilder: (context, index) {
            // if (index < widget.messages.length) {
            //   // Display regular message
            //   return _MessageOwnTile(message: widget.messages[index]);
            // } else {
            //   // Display shared file (photo or link)
            //   int sharedIndex = widget.sharedFiles.length -
            //       1 -
            //       (index - widget.messages.length);
            //   return _SharedFileTile(file: widget.sharedFiles[sharedIndex]);
            // }
            if (widget.messageData[index]['type'] == 'TEXT') {
              return _MessageOwnTile(
                  message: widget.messageData[index]["value"]);
            } else {
              return _SharedFileTile(file: widget.messageData[index]["value"]);
            }
          },
        ),
      ),
    );
  }
}

class _MessageOwnTile extends StatelessWidget {
  const _MessageOwnTile({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;
  static const _borderRadius = 26.0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_borderRadius),
                    bottomLeft: Radius.circular(_borderRadius),
                    bottomRight: Radius.circular(_borderRadius),
                  )),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SharedFileTile extends StatelessWidget {
  const _SharedFileTile({
    Key? key,
    required this.file,
  }) : super(key: key);

  final SharedMediaFile file;

  @override
  Widget build(BuildContext context) {
    // Determine if the file is an image or a link
    bool isImage = file.path.endsWith('.jpg') ||
        file.path.endsWith('.jpeg') ||
        file.path.endsWith('.png');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26.0),
                  bottomLeft: Radius.circular(26.0),
                  bottomRight: Radius.circular(26.0),
                ),
              ),
              child: isImage
                  ? Image.file(
                      File(file.path),
                      width: 200, // Adjust image width as needed
                      height: 200, // Adjust image height as needed
                      fit: BoxFit.cover,
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        file.path,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
