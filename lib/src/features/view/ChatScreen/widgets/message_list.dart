// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class MessageList extends StatefulWidget {
  const MessageList(
      {Key? key, required this.messageData, required this.scrollController})
      : super(key: key);

  @override
  State<MessageList> createState() => MessageListState();

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
            // if (widget.messageData[index]['id'] == 'TEXT') {
            //   return _MessageOwnTile(
            //       message: widget.messageData[index]["value"]);
            // } else {
            //   return _SharedFileTile(file: widget.messageData[index]["value"]);
            // }
            // return _MessageOwnTile(
            //   message: widget.messageData[index]['id'].toString(),
            // );
            final item = widget.messageData[index];
            if (item.containsKey('note') && item.containsKey('fileType')) {
              // Render shared file
              final imageUrl = item['url'] as String;
              return _SharedFileTile(imageUrl: imageUrl);
            } else if (item.containsKey('note')) {
              // Render note
              final message = item['note'] as String;
              return _MessageOwnTile(message: message);
            } else if (item.containsKey('fileType')) {
              final imageUrl = item['url'] as String;
              return _SharedFileTile(imageUrl: imageUrl);
            } else {
              // Handle other cases
              return const SizedBox.shrink(); // Or any default widget
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

class _SharedFileTile extends StatefulWidget {
  final String imageUrl;

  const _SharedFileTile({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _SharedFileTileState createState() => _SharedFileTileState();
}

class _SharedFileTileState extends State<_SharedFileTile> {
  late Future<Uint8List> _imageBytes;

  @override
  void initState() {
    super.initState();
    _imageBytes = _fetchImageBytes();
  }

  Future<Uint8List> _fetchImageBytes() async {
    final response = await get(Uri.parse(widget.imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

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
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26.0),
                  bottomLeft: Radius.circular(26.0),
                  bottomRight: Radius.circular(26.0),
                ),
              ),
              child: FutureBuilder<Uint8List>(
                future: _imageBytes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Error loading image',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return Image.memory(
                      snapshot.data!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
