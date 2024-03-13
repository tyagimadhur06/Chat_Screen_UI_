import 'dart:async';

import 'package:chat_screen/src/common/icon_button.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/action_bar.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/appbar_title.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/message_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
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

  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // Setup receiving sharing intents
    setupSharingListener();
  }

  @override
  void dispose() {
    // Clean up receiving sharing intents
    disposeSharingListener();
    super.dispose();
  }

  void setupSharingListener() {
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile>? value) {
      if (value != null && value.isNotEmpty) {
        // Handle initial shared media (text) data
        addNewMessage(value.first.toString());
        print("The following media shared: $value");
      }
    });

    ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      // Handle the shared media (text) data
      if (value.isNotEmpty) {
        addNewMessage(value.first.toString());
        print("The following media shared: $value");

      }
    }, onError: (err) {
      print("Error receiving shared media: $err");
    });
  }

  void disposeSharingListener() {
    ReceiveSharingIntent.reset();
  }

  void addNewMessage(String newMessage) {
    if (newMessage.isNotEmpty) {
      setState(() {
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
            scrollController: _scrollController,
          )),
          ActionBar(
            messageController: messageController,
            onSendPressed: () => addNewMessage(messageController.text),
          ),
        ],
      ),
    );
  }
}
