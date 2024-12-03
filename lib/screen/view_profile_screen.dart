
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/helper/my_date_util.dart';

import 'package:chatapp/main.dart';
import 'package:chatapp/model/chat_user.dart';
import 'package:flutter/material.dart';


class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(widget.user.name!,style:const TextStyle(fontSize: 20,fontWeight: FontWeight.w600,letterSpacing: 2),),
      ),
      floatingActionButton:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
               const Text(
                  'JoinUs: ',
                  style:  TextStyle(fontSize: 19, color: Colors.black,fontWeight: FontWeight.w600),
                ),
                Text(MyDateUtil.getLastMessageTime(context: context, time:widget.user.lastActive!,showyear: true),style:const TextStyle(color: Colors.black54))
                ],),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * 0.1),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: mq.width,
                  height: mq.height * 0.03,
                ),
                Stack(
                  children: [
                 ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .3),
                      child: CachedNetworkImage(
                        width: mq.width * .3,
                        height: mq.width * .3,
                        imageUrl: widget.user.image!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: mq.height * 0.03,
                ),
                Text(
                  widget.user.email!,
                  style: const TextStyle(fontSize: 19, color: Colors.black),
                ),
                SizedBox(
                  height: mq.height * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
               const Text(
                  'About: ',
                  style:  TextStyle(fontSize: 19, color: Colors.black,fontWeight: FontWeight.w600),
                ),
                Text(widget.user.about!,style:const TextStyle(color: Colors.black54))
                ],),
                SizedBox(
                  height: mq.height * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}