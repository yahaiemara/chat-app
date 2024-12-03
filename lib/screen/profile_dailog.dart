import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/model/chat_user.dart';
import 'package:chatapp/screen/view_profile_screen.dart';
import 'package:flutter/material.dart';

class ProfileDailog extends StatelessWidget {
  const ProfileDailog({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        height: mq.height * .35,
        width: mq.width * .4,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .25),
                child: CachedNetworkImage(
                  width: mq.width * .5,
                  imageUrl: user.image!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Positioned(
              left: mq.width * .04,
              top: mq.height * .02,
              width: mq.width * .55,
              child: Text(
                user.name!,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Positioned(
              right: 8,
              top: 6,
              child: Align(
                alignment: Alignment.topRight,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewProfileScreen(user: user)));
                  },
                  padding:const EdgeInsets.all(0),
                  minWidth: 0,
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
