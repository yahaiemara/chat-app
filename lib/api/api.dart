import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatapp/api/message.dart';
import 'package:chatapp/model/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class Apis {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static late ChatUser me;

//For Accessing FirebaseMessaging
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log("push Token :${t}");
      }
    });
  }

// For Sending Notification
  static Future<void> sendPushNotification(
      ChatUser chatuser, String msg) async {
    try {
      final body = {
        "message": {
          "token": chatuser.pushToken,
          "notification": {"title": chatuser.name, "body": msg},
          "android": {
            "notification": {
              "notification_priority": "PRIORITY_MAX",
              "sound": "default"
            }
          },
          "apns": {
            "payload": {
              "aps": {"content_available": true}
            }
          },
          "data": {
            "type": "type",
            "id": "userId",
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          }
        }
      };
      var response = await post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/chatapp-6777f/messages:send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=ya29.c.c0ASRK0GbG2KlX1srucs91zMriO8CWb1Apno7XmuGwxQVLdKZHSE1E1ofVc-MgGYc8YzTbzjZVt_ELgbxv-T4rXXEyhAu6ukLHlmc_zTLbWWvPH8P1469CLKNbbi_CvtS6uXA3jNquTwfELYUKbm1nxVydEtuY6Hr8Rvc1smvoI6f_zphuUmn7kOuMzylj1VA6pi1PskyT8-y0MoYBtFTwoiq-WfpEeaiDLK77lSn3DWK4UT33pfyV-6zGEkGu64XRaTBrpVD1A_I8INbN_MkKTE-cd_ZM3zfgzHWtDXd7ZFQ46kKPCvYHTHfVnASkFfhi0mtdNkSYHWH_oLG9030Vda-_YnualaGZStAD8OrepSO82vf_R1EqZxgAmCQSXQT391KRU1jgZ4YcJc_3qV-bU0B75xIzcsnyBuUwpw868IUpxvZ_rd1JVJW93VOmk1drJus6kl-tv07BY1wgpt4pFIq9XwxlFzZ-xoc2fS0pu1_9-_nda4WJRheXbgVd_6wFJ2MW3qjm615lVB2JVUFcm4iBzcVtZu1Be63a4flxZg90fQUw8pd4mBJcmQqbdeXUeif8Iw6YSvlswf0kn7fbQVg2syRI-FkshgMQa6rn7zSBtlJR2aq3RpxxnraI_i0OXIefV2yJ-dj7p6vjk6OVloOMuJVkfhYSt14IobwOp1hOurjefyq_to6OrMbjhaYgQrQcm5xa194m7vea6SjRgyb-O1-11wpWbc-Wk4klxkgx3OjmqmopIp3_1n6sc9aoiUomnfvcJzBvyyd2eXg_xkJ6V1hX2QbW8xeQgZir6_8od1a28Ik9XiQ4oW7JogRu4tStrF2swU-Zn85JvMuR95n63-kpi2wrR7tcpywa4jzYi4RUWnwOakWssJOztRbr3BsoeM1xfxVkpnZvea9-sYQb_dwFIfisaRatjI7Iv_OvU1frY_3ohhu8OQF-rR1z6Y-t9s67zo5X4mdds44Xo1wUZihXzIpUvqhMxn21'
          },
          body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      log("noneSendNotification: $e");
    }
  }

  // to return current user
  static User get user => auth.currentUser!;
  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        getFirebaseMessagingToken();
        Apis.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for checking if user exists or not?
  static Future<bool> userExist() async {
    return (await firestore.collection("users").doc(user.uid).get()).exists;
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey,im useing We Chat",
        image: user.photoURL,
        createdAt: time,
        lastActive: time,
        isOnline: false,
        pushToken: '');
    return (await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatuser.toJson()));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getallUser() {
    return firestore
        .collection("users")
        .where("id", isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({"name": me.name, "about": me.about});
  }

  static Future<void> updateProfileimage(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child("profile_picture/${user.uid}.$ext");
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    me.image = await ref.getDownloadURL();
    await firestore
        .collection("users")
        .doc(user.uid)
        .update({"image": me.image});
  }

// Get specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatuser) {
    return firestore
        .collection("users")
        .where("id", isEqualTo: chatuser.id)
        .snapshots();
  }

// update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection("users").doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  static String getConvertStationID(String id) =>
      user.uid.hashCode <= id.hashCode
          ? '${user.uid}_$id'
          : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection("cahts/${getConvertStationID(user.id!)}/messages")
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatuser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Messages messages = Messages(
        toId: chatuser.id!,
        msg: msg,
        read: '',
        type: type,
        sent: time,
        fromId: user.uid);
    final ref = firestore
        .collection("cahts/${getConvertStationID(chatuser.id!)}/messages");

    await ref
        .doc(time)
        .set(messages.toJson())
        .then((value) => sendPushNotification(
            chatuser,
            type == Type.text
                ? msg
                : type == Type.image
                    ? 'image'
                    : 'emojin'));
  }

  static Future<void> updateMessageReadStatus(Messages message) async {
    firestore
        .collection("cahts/${getConvertStationID(message.fromId)}/messages")
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection("cahts/${getConvertStationID(user.id!)}/messages")
        .limit(1)
        .orderBy('sent', descending: true)
        .snapshots();
  }

// send ChatCamera image
  static Future<void> sendChatImage(ChatUser chatuser, File file) async {
    // get Extantion image
    final ext = file.path.split('.').last;
    // Stroing file ref with path
    final ref = storage.ref().child(
        "images/${getConvertStationID(chatuser.id!)}/${DateTime.now().millisecondsSinceEpoch}.$ext");
    // Uploading images
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    //  updateing image in firesotre
    final imageurl = await ref.getDownloadURL();
    await sendMessage(chatuser, imageurl, Type.image);
  }

  // ignore: non_constant_identifier_names
  static Future<void> DeleteMessage(Messages message) async {
   await firestore
        .collection("cahts/${getConvertStationID(message.toId)}/messages")
        .doc(message.sent)
        .delete();
        if(message.type==Type.image){
          await storage.refFromURL(message.msg).delete();
        }
  }
    // ignore: non_constant_identifier_names
    static Future<void> UpdateMessage(Messages message,String UpdateMsg) async {
   await firestore
        .collection("cahts/${getConvertStationID(message.toId)}/messages")
        .doc(message.sent)
        .update({'msg':UpdateMsg});
     
  }
}
