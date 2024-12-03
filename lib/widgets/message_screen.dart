import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/api.dart';
import 'package:chatapp/api/message.dart';
import 'package:chatapp/helper/dailo.dart';
import 'package:chatapp/helper/my_date_util.dart';
import 'package:chatapp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key, required this.messages});
  final Messages messages;
  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user.uid == widget.messages.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    if (widget.messages.read.isNotEmpty) {
      Apis.updateMessageReadStatus(widget.messages);
      log("Message is read");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                border: Border.all(color: Colors.lightBlue)),
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            child: Text(widget.messages.msg),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: widget.messages.type == Type.text
              ? Text(
                  MyDateUtil.getFormattedtime(
                      context: context, time: widget.messages.sent),
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: widget.messages.msg,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image,
                      size: 70,
                      color: Colors.grey,
                    ),
                  ),
                ),
        )
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * .04,
            ),
            if (widget.messages.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                size: 25,
                color: Colors.blue,
              ),
            Text(
              MyDateUtil.getFormattedtime(
                  context: context, time: widget.messages.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black),
            ),
          ],
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
                border: Border.all(color: Colors.lightGreen)),
            padding: EdgeInsets.all(widget.messages.type == Type.image
                ? mq.width * 0.3
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            child: widget.messages.type == Type.text
                ? Text(widget.messages.msg)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.messages.msg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              margin: EdgeInsets.symmetric(
                  vertical: mq.height * 0.015, horizontal: mq.width * 0.4),
            ),
            widget.messages.type == Type.text
                ? OptionItem(
                    icon: const Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Copy all',
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.messages.msg))
                          .then((value) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        Dailog.showSnackBar(context, 'Text Is Copied');
                      });
                    },
                  )
                : OptionItem(
                    icon: const Icon(
                      Icons.download,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Save as',
                    onTap: () async {
                      log("Image Url :${widget.messages.msg}");
                      await GallerySaver.saveImage(widget.messages.msg,
                              albumName: "We Chat")
                          .then((value) {
                        // for hiding Bottom Sheet
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        if (value != null && value) {
                          Dailog.showSnackBar(
                              // ignore: use_build_context_synchronously
                              context,
                              "Image Successfully Saved");
                        }
                      });
                    },
                  ),
            if (isMe)
              Divider(
                color: Colors.black54,
                indent: mq.width * .04,
                endIndent: mq.width * .04,
              ),
            if (widget.messages.type == Type.text && isMe)
              OptionItem(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                  size: 26,
                ),
                name: 'Edit Massege',
                onTap: () {
                  Navigator.pop(context);
                  _showMessageUpdateDailog();
                },
              ),
            if (isMe)
              OptionItem(
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 26,
                ),
                name: 'Delete Massege',
                onTap: () {
                  Apis.DeleteMessage(widget.messages).then((value) {
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  });
                },
              ),
            Divider(
              color: Colors.black54,
              indent: mq.width * .04,
              endIndent: mq.width * .04,
            ),
            OptionItem(
              icon: const Icon(
                Icons.remove_red_eye,
                color: Colors.blue,
                size: 26,
              ),
              name:
                  'sent At:${MyDateUtil.getLastMessageTime(context: context, time: widget.messages.sent)} ',
              onTap: () {},
            ),
            OptionItem(
              icon: const Icon(
                Icons.remove_red_eye,
                color: Colors.red,
                size: 26,
              ),
              name: widget.messages.read.isEmpty
                  ? 'Read At : Not seen yet'
                  : 'Read At : ${MyDateUtil.getLastMessageTime(context: context, time: widget.messages.read)}',
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
  void _showMessageUpdateDailog() async {
    // ignore: non_constant_identifier_names
    String UpdateMsg = widget.messages.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 25, top: 20, bottom: 10),
              title: const Row(
                children: [
                  Icon(Icons.message, color: Colors.blue, size: 26),
                  Text(
                    "Update Message",
                    style: TextStyle(color: Colors.black87),
                  )
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (val) => UpdateMsg = val,
                initialValue: UpdateMsg,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancle',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Apis.UpdateMessage(widget.messages, UpdateMsg);
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                )
              ],
            ));
  }
}

class OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final void Function()? onTap;
  const OptionItem(
      {super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .025),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              " ${name}",
              style: const TextStyle(
                  color: Colors.black54, letterSpacing: 0.5, fontSize: 15),
            )),
          ],
        ),
      ),
    );
  }
}
