import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/api.dart';
import 'package:chatapp/api/message.dart';
import 'package:chatapp/helper/my_date_util.dart';
import 'package:chatapp/model/chat_user.dart';
import 'package:chatapp/screen/chat_screen.dart';
import 'package:chatapp/screen/profile_dailog.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Messages? _messages;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0.5,
      // color:Colors.blue.shade600 ,
      // margin: EdgeInsets.symmetric(horizontal: mq.width*0.4,vertical: mq.width*4),
      child: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: Apis.getLastMessage(widget.user),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final data = snapshot.data!.docs;
                final list =
                    data.map((e) => Messages.fromJson(e.data())).toList();

                if (list.isNotEmpty) {
                  _messages = list[0];
                }
              } else {
                return const Center(child: Text("No data available"));
              }
              return ListTile(
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => ProfileDailog(user: widget.user));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                        imageUrl: widget.user.image ??
                            '', // تأكد من أن الصورة ليست null
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(), // صورة تحميل
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error), // صورة خطأ
                      ),
                    ),
                  ),
                  title: Text("${widget.user.name}"),
                  subtitle: Text(
                    "${_messages != null ? _messages!.type == Type.image ? 'image' : _messages!.msg : widget.user.about}",
                    maxLines: 1,
                  ),
                  trailing: _messages == null
                      ? null
                      : _messages!.read.isEmpty &&
                              _messages!.fromId != Apis.user.uid
                          ? Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.green.shade400,
                                  borderRadius: BorderRadius.circular(10)),
                            )
                          : Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context, time: _messages!.sent),
                              style: const TextStyle(color: Colors.black54),
                            ));
            }),
      ),
    );
  }
}
