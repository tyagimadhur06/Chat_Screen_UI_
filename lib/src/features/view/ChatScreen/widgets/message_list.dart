// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shimmer/shimmer.dart';

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
              final message = item['note'].toString();
              return _MessageOwnTile(message: message);
            } else if (item.containsKey('fileType')) {
              final filetype = item['fileType'] as String;
              if (filetype == 'jpg' ||
                  filetype == 'jpeg' ||
                  filetype == 'png') {
                final imageUrl = item['url'] as String;
                return _SharedFileTile(imageUrl: imageUrl);
              } else if (filetype == 'pdf') {
                final fileUrl = item['url'] as String;
                return _SharedFileTile(
                  fileUrl: fileUrl,
                );
              }
            } else if (item['type'] == 'IMAGE') {
              return _SharedFileTile(file: item['value']);
            } else if (item['type'] == 'FILE') {
              return _SharedFileTile(file: item['value']);
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
  final String? imageUrl;
  final String? fileUrl;
  final SharedMediaFile? file;

  const _SharedFileTile({
    Key? key,
    this.imageUrl,
    this.fileUrl,
    this.file,
  }) : super(key: key);

  @override
  _SharedFileTileState createState() => _SharedFileTileState();
}

class _SharedFileTileState extends State<_SharedFileTile> {
  late Future<Uint8List> _fileBytes;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrl != null) {
      _fileBytes = _fetchFileBytes(Uri.parse(widget.imageUrl!));
    } else if (widget.fileUrl != null) {
      _fileBytes = _fetchFileBytes(Uri.parse(widget.fileUrl!));
    }
  }

  Future<Uint8List> _fetchFileBytes(Uri uri) async {
    try {
      final response = await get(uri);
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load file');
      }
    } catch (e) {
      throw Exception('Error fetching file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.file != null) {
      final String path = widget.file!.path;
      final bool isImage = path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png');
      final bool isPdf = path.endsWith('.pdf');

      if (isImage) {
        return _buildImageWidget();
      } else if (isPdf) {
        return _buildPdfWidget();
      } else {
        return _buildDefaultWidget();
      }
    } else if (widget.imageUrl != null) {
      return _buildFutureBuilderWidgetImage();
    } else if (widget.fileUrl != null) {
      return _buildFutureBuilderWidgetFile();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildImageWidget() {
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
              child: GestureDetector(
                onTap: () {
                  OpenFile.open(widget.file?.path);
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(26.0),
                    bottomLeft: Radius.circular(26.0),
                    bottomRight: Radius.circular(26.0),
                  ),
                  child: Image.file(
                    File(widget.file!.path),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfWidget() {
    return GestureDetector(
      onTap: () {
        OpenFile.open(widget.file!.path);
      },
      child: Padding(
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
                child: const Icon(
                  Icons.picture_as_pdf,
                  size: 70,
                  color: Colors.blueAccent, // Customize PDF icon color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultWidget() {
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
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Unsupported file format',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureBuilderWidgetImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.greenAccent[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26.0),
                  bottomLeft: Radius.circular(26.0),
                  bottomRight: Radius.circular(26.0),
                ),
              ),
              child: FutureBuilder<Uint8List>(
                future: _fileBytes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                            color: Colors.greenAccent[200],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(26.0),
                              bottomLeft: Radius.circular(26.0),
                              bottomRight: Radius.circular(26.0),
                            )),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Error loading image',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () async {
                        final tempDir = await getTemporaryDirectory();
                        final file = File('${tempDir.path}/temp.jpg');
                        await file.writeAsBytes(snapshot.data!);
                        OpenFile.open(file.path);
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(26.0),
                          bottomLeft: Radius.circular(26.0),
                          bottomRight: Radius.circular(26.0),
                        ),
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                      ),
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

  Widget _buildFutureBuilderWidgetFile() {
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
                future: _fileBytes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!, // Light grey
                      highlightColor: Colors.grey[100]!, // Darker grey
                      child: const Icon(
                        Icons.picture_as_pdf,
                        size: 70,
                        color: Colors.blueAccent, // Customize PDF icon color
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Error loading file',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () async {
                        // Open PDF file
                        final tempDir = await getTemporaryDirectory();
                        final file = File('${tempDir.path}/temp.pdf');
                        await file.writeAsBytes(snapshot.data!);
                        OpenFile.open(file.path);
                      },
                      child: const Icon(
                        Icons.picture_as_pdf,
                        size: 70,
                        color: Colors.blueAccent, // Customize PDF icon color
                      ),
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
