import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/api.dart';
import 'package:chatapp/api/message.dart';
import 'package:chatapp/helper/my_date_util.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/model/chat_user.dart';
import 'package:chatapp/screen/view_profile_screen.dart';
import 'package:chatapp/widgets/message_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Messages> _list = [];
  bool _showemoji = false, _isUploading = false;
  final _textedtioncontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        // ignore: deprecated_member_use
        child: WillPopScope(
          onWillPop: () {
            if (_showemoji) {
              setState(() {
                _showemoji = !_showemoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appbar(),
            ),
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            body: Column(
              children: [
                Expanded(
                    child: StreamBuilder(
                  stream: Apis.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        // log("data :${jsonEncode(data![0].data())}");
                        _list = data!
                            .map((e) => Messages.fromJson(e.data()))
                            .toList();
                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageScreen(messages: _list[index]);
                              });
                        } else {
                          return const Center(
                              child: Text(
                            "Say Hi 👋",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ));
                        }
                    }
                  },
                )),
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                _iconButton(),
                if (_showemoji)
                  SizedBox(
                    height: mq.height * 0.35,
                    child: EmojiPicker(
                      textEditingController:
                          _textedtioncontroller, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                      config: Config(
                        height: 256,
                        checkPlatformCompatibility: true,
                        emojiViewConfig: EmojiViewConfig(
                          // Issue: https://github.com/flutter/flutter/issues/28894
                          emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appbar() {
    return InkWell(
        onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: Apis.getUserInfo(widget.user),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // عرض مؤشر تحميل أثناء انتظار البيانات
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                // التعامل مع أي خطأ أثناء تحميل البيانات
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              // التحقق من وجود بيانات في الـ snapshot
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final data = snapshot.data!.docs;
                final list =
                    data.map((e) => ChatUser.fromJson(e.data())).toList();

                return Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black54,
                        )),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .3),
                      child: CachedNetworkImage(
                        width: mq.width * .05,
                        height: mq.width * .05,
                        imageUrl: list.isNotEmpty
                            ? list[0].image!
                            : widget.user.image!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          list.isNotEmpty ? list[0].name! : widget.user.name!,
                          style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          list.isNotEmpty
                              ? list[0].isOnline!
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive!)
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive!),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    )
                  ],
                );
              } else {
                // التعامل مع الحالة التي لا توجد بها بيانات
                return Center(child: Text('No data available'));
              }
            }));
  }

  Widget _iconButton() {
    return Row(
      children: [
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {
                        _showemoji = !_showemoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                      size: 26,
                    )),
                Expanded(
                  child: TextField(
                    controller: _textedtioncontroller,
                    onTap: () {
                      if (_showemoji) {
                        setState(() {
                          _showemoji = !_showemoji;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "type something...",
                        hintStyle: TextStyle(color: Colors.blueAccent)),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      for (var i in images) {
                        if (images.isNotEmpty) {
                          log("image path: ${i.path}");
                          setState(() {
                            _isUploading = true;
                          });
                          Apis.sendChatImage(widget.user, File(i.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.blueAccent,
                      size: 26,
                    )),
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        log("image path: ${image.path}");
                        setState(() {
                          _isUploading = true;
                        });
                        Apis.sendChatImage(widget.user, File(image.path));
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.camera,
                      color: Colors.blueAccent,
                      size: 26,
                    ))
              ],
            ),
          ),
        ),
        MaterialButton(
          shape: const CircleBorder(),
          minWidth: 0,
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
          color: Colors.green,
          onPressed: () {
            if (_textedtioncontroller.text.isNotEmpty) {
              Apis.sendMessage(
                  widget.user, _textedtioncontroller.text, Type.text);
              _textedtioncontroller.text = '';
            }
          },
          child: const Icon(
            Icons.send,
            size: 28,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}
