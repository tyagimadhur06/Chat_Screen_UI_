import 'dart:async';
import 'dart:io';

import 'package:chat_screen/src/api/api_test.dart';
import 'package:chat_screen/src/common/icon_button.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/action_bar.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/appbar_title.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/message_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // List<String> messages = [
  //   'Hi , Madhur! How are you doing?',
  //   'Great bro....',
  //   'Lets go for a walk??',
  //   'Sure!',
  //   'Come fast',
  //   'Coming in 10 min ',
  // ];
  List<Map<String, dynamic>> messageData = [];
  late StreamSubscription _intentSub;
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final HttpService _httpService = HttpService();

  getData() async {
    await _httpService.getData().then((messages) {
      print('message data get$messages');
      setState(() {
        messageData.addAll(messages);
      });
    }).catchError((error) {
      // Handle errors here
      print(error);
    });
  }

  @override
  void initState() {
    super.initState();
    getData();

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.getMediaStream().listen((value) {
      setState(() {
        for (SharedMediaFile i in value) {
          messageData.insert(0, {"type": "IMAGE", "value": i});
          _httpService.postData(imagePath: i.path).then((_) {
            print('Data Posted Successfully');
          }).catchError((e) {
            print('Error posting the data : $e');
          });
        }
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
          messageData.insert(0, {"type": "IMAGE", "value": i});
          _httpService.postData(imagePath: i.path).then((_) {
            print('Data Posted Successfully');
          }).catchError((e) {
            print('Error posting the data : $e');
          });
        }
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

  void addNewMessage(String newMessage) async {
    if (newMessage.isNotEmpty) {
      // Add message to local data nimmediately
      setState(() {
        messageData.insert(0, {'note': newMessage});
        messageController.clear();
      });

      // Scroll to the bottom after adding the new message
      Timer(const Duration(milliseconds: 500), () {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });

      //Send message to API (handle errors)
      try {
        await _httpService.postData(note: newMessage);
        // Optionally refetch data for server-generated information
        // getData();
      } catch (error) {
        print('Error sending message: $error');
        // Show error message to user
      }
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
            scrollController: _scrollController,
            messageData: messageData.toList(),
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
    File newfile = File(pickedImage?.path ?? "");
    Future<File> compressedImagePath = _compressImage(newfile);
    print("Compress file is $compressedImagePath");
    if (pickedImage != null) {
      final String mimeType = 'image/${pickedImage.path.split('.').last}';
      final sharedMediaFile = SharedMediaFile(
        path: pickedImage.path,
        type: SharedMediaType.image,
        thumbnail: 'Image',
        mimeType: mimeType,
      );
      setState(() {
        messageData.insert(0, {"type": "IMAGE", "value": sharedMediaFile});
      });

      final imagePath = pickedImage.path;
      await _httpService.postData(imagePath: imagePath);
    }
  }

  _pickImageFromCamera() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    File newfile = File(pickedImage?.path ?? "");
    Future<File> compressedImagePath = _compressImage(newfile);
    print("Compress file is $compressedImagePath");

    if (pickedImage != null) {
      final String mimeType = 'image/${pickedImage.path.split('.').last}';
      final sharedMediaFile = SharedMediaFile(
        path: pickedImage.path,
        type: SharedMediaType.image,
        thumbnail: 'Image',
        mimeType: mimeType,
      );

      setState(() {
        messageData.insert(0, {"type": "IMAGE", "value": sharedMediaFile});
      });
      final imagePath = pickedImage.path;
      await _httpService.postData(imagePath: '');
    }
  }

  Future<File> _compressImage(File file) async {
    var compressedImage = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '',
      quality: 50, // Adjust quality as needed
    );
    File returnfile = File(compressedImage?.path ?? "");
    return returnfile;
  }
  // Future<File> testCompressAndGetFile(File file, String targetPath) async {
  //   var result = await FlutterImageCompress.compressAndGetFile(
  //       file.absolute.path, targetPath,
  //       quality: 88,
  //       rotate: 180,
  //     );

  //   // print(file.lengthSync());
  //   // print(result.lengthSync());

  //   return result;
  // }
}
