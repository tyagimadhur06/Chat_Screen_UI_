import 'dart:async';

import 'package:chat_screen/src/common/icon_button.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/action_bar.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/appbar_title.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/message_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> messages = [
    'Hi , Madhur! How are you doing?',
    'Great bro....',
    'Lets go for a walk??',
    'Sure!',
    'Come fast',
    'Coming in 10 min ',
  ];
  List<Map<String, dynamic>> messageData = [];
  final sharedFiles = <SharedMediaFile>[];
  late StreamSubscription _intentSub;
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    // Listen to media sharing coming from outside the app while the app is in the memory.
    ReceiveSharingIntent.getMediaStream().listen((value) {
      setState(() {
        for (SharedMediaFile i in value) {
          messageData.add({"type": "IMAGE", "value": i});
        }
        //sharedFiles.addAll(value);
        // sharedFiles.clear();
        //print("the shared file is ${sharedFiles.map((f) => f.toMap())}");
      });
      // Scroll to the bottom after adding new message
      Timer(const Duration(milliseconds: 500), () {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.getInitialMedia().then((value) {
      setState(() {
        for (SharedMediaFile i in value) {
          messageData.add({"type": "IMAGE", "value": i});
        }

        //sharedFiles.addAll(value);
        // sharedFiles.clear();
        //print(sharedFiles.map((f) => f.toMap()));

        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.reset();
      });
      // Scroll to the bottom after adding new message
      Timer(const Duration(milliseconds: 500), () {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  void addNewMessage(String newMessage) {
    if (newMessage.isNotEmpty) {
      setState(() {
        messageData.add({"type": "TEXT", "value": newMessage});
        messages.add(newMessage);
        messageController.clear();
      });
      // Scroll to the bottom after adding new message
      Timer(const Duration(milliseconds: 500), () {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconBackground(
              icon: CupertinoIcons.back,
              onTap: () {
                Get.back();
              }),
        ),
        title: const AppBarTitle(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: IconBorder(
                icon: CupertinoIcons.video_camera_solid,
                onTap: () {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: IconBorder(
                icon: CupertinoIcons.phone_solid,
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: MessageList(
            messages: messages.reversed.toList(),
            sharedFiles: sharedFiles,
            scrollController: _scrollController,
            messageData: messageData.reversed.toList(),
          )),
          ActionBar(
            messageController: messageController,
            onSendPressed: () => addNewMessage(messageController.text),
            onCameraPressed: () => _pickImageFromCamera(),
            onGalleryPressed: () => _pickImageFromGallery(),
          ),
        ],
      ),
    );
  }

  _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final String mimeType = 'image/${pickedImage.path.split('.').last}';
      final sharedMediaFile = SharedMediaFile(
        path: pickedImage.path,
        type: SharedMediaType.image,
        thumbnail: 'Image',
        mimeType:mimeType, 
      );
      setState(() {
        messageData.add({"type": "IMAGE", "value": sharedMediaFile});
      });
    }
  }
  _pickImageFromCamera() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      final String mimeType = 'image/${pickedImage.path.split('.').last}';
      final sharedMediaFile = SharedMediaFile(
        path: pickedImage.path,
        type: SharedMediaType.image,
        thumbnail: 'Image',
        mimeType:mimeType, 
      );
      setState(() {
        messageData.add({"type": "IMAGE", "value": sharedMediaFile});
      });
    }
  }
}

class messageDTO {
  String? type;
  dynamic value;
  messageDTO({this.type, this.value});
}
