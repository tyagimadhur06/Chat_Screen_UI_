import 'dart:async';

import 'package:chat_screen/src/api/api_test.dart';
import 'package:chat_screen/src/common/icon_button.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/action_bar.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/appbar_title.dart';
import 'package:chat_screen/src/features/view/ChatScreen/widgets/message_list.dart';
import 'package:file_picker/file_picker.dart';
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
  int page = 0;
  List<Map<String, dynamic>> messageData = [];
  late StreamSubscription _intentSub;
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final HttpService _httpService = HttpService();

  bool isLoading = false;
  getData() async {
    await _httpService.getData(page).then((messages) {
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
    _scrollController.addListener(_scrollListener);

    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub = ReceiveSharingIntent.getMediaStream().listen((value) {
      setState(() {
        for (SharedMediaFile i in value) {
          messageData.insert(0, {"type": "fileType", "value": i});
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
          messageData.insert(0, {"type": "fileType", "value": i});
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
            isLoadingMore: isLoading,
            scrollController: _scrollController,
            messageData: messageData.toList(),
          )),
          ActionBar(
            messageController: messageController,
            onSendPressed: () => addNewMessage(messageController.text),
            onCameraPressed: () => _pickImageFromCamera(),
            onGalleryPressed: () => _pickImageFromGallery(),
            onPaperClipPressed: () => _pickFileFromDevice(),
          ),
        ],
      ),
    );
  }

  _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // Compress the image
      final XFile? compressedImage = await _compressImage(pickedImage);
      print("Compressed file is $compressedImage");

      if (compressedImage != null) {
        final String mimeType = 'image/${pickedImage.path.split('.').last}';
        final sharedMediaFile = SharedMediaFile(
          path: compressedImage.path,
          type: SharedMediaType.image,
          thumbnail: 'Image',
          mimeType: mimeType,
        );

        setState(() {
          messageData.insert(0, {"type": "IMAGE", "value": sharedMediaFile});
        });

        await _httpService.postData(imagePath: compressedImage.path);
      } else {
        print("Compression failed or image is null.");
      }
    }
  }

  _pickImageFromCamera() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      // Compress the image
      final XFile? compressedImage = await _compressImage(pickedImage);
      print("Compressed file is $compressedImage");

      if (compressedImage != null) {
        final String mimeType = 'image/${pickedImage.path.split('.').last}';
        final sharedMediaFile = SharedMediaFile(
          path: compressedImage.path,
          type: SharedMediaType.image,
          thumbnail: 'Image',
          mimeType: mimeType,
        );

        setState(() {
          messageData.insert(0, {"type": "IMAGE", "value": sharedMediaFile});
        });

        await _httpService.postData(imagePath: compressedImage.path);
      } else {
        print("Compression failed or image is null.");
      }
    }
  }

  _pickFileFromDevice() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      allowMultiple: true,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.extension == 'pdf' ||
          file.extension == 'doc' ||
          file.extension == 'docx') {
        // Handle the file based on its extension
        final String mimeType = 'application/${file.extension}';
        final sharedMediaFile = SharedMediaFile(
          path: file.path!,
          type: SharedMediaType.file,
          thumbnail: file.name,
          mimeType: mimeType,
        );

        setState(() {
          messageData.insert(0, {"type": "FILE", "value": sharedMediaFile});
        });

        await _httpService.postData(filePath: file.path);
      } else {
        // Invalid file type selected
        print("Unsupported file type selected.");
      }
    } else {
      // User canceled the file picker
      print("File picking canceled by user.");
    }
  }

  Future<XFile?> _compressImage(XFile? file) async {
    if (file == null) return null;

    final filePath = file.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      outPath,
      quality: 80,
    );
    return result;
  }

  Future<void> _scrollListener() async {
    if (isLoading) return;
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      page++;
      await getData();
      setState(() {
        isLoading = false;
      });
    }
  }
}
