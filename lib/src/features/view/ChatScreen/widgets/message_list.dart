// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class MessageList extends StatefulWidget {
  const MessageList({
    Key? key,
    required this.messages,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<MessageList> createState() => MessageListState();
  final List<String> messages;
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
          itemCount: widget.messages.length,
          itemBuilder: (context, index) {
            return _MessageOwnTile(message: widget.messages[index]);
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
