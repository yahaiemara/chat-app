import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/api.dart';
import 'package:chatapp/helper/dailo.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/model/chat_user.dart';
import 'package:chatapp/screen/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormFieldState>();
  final _aboutKey = GlobalKey<FormFieldState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Screen"),
      ),
     floatingActionButton: Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: FloatingActionButton.extended(
    backgroundColor: Colors.orange,
    onPressed: () async {
      Dailog.showProccessBar(context); // إظهار مؤشر تحميل
      Apis.updateActiveStatus(false);
      await Apis.auth.signOut().then((value)async{
        await GoogleSignIn().signOut().then((value){
           Navigator.pop(context);
        Apis.auth=FirebaseAuth.instance;
    // إزالة جميع الشاشات السابقة والانتقال لشاشة تسجيل الدخول
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
              // عرض رسالة تأكيد تسجيل الخروج
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully!')),
          );
        });
     
      });

    },
    icon: const Icon(
      Icons.logout,
      color: Colors.white,
    ),
    label: const Text(
      "LogOut",
      style: TextStyle(fontSize: 19, color: Colors.white),
    ),
  ),
),

      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Form(
          key: _formKey,
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
                     _image !=null ? ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .3),
                        child: Image.file(
                          File(_image!),
                          width: mq.width * .3,
                          height: mq.width * .3,
                          fit: BoxFit.cover,
                          
                        ),
                      ): ClipRRect(
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          onPressed: _showBottomSheet,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.blue,
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
                  TextFormField(
                    key: _nameKey,
                    onSaved: (val) => Apis.me.name = val,
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required Field",
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                      label: const Text("Name"),
                      hintText: "He We Chat",
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  TextFormField(
                    key: _aboutKey,
                    onSaved: (val) => Apis.me.about = val,
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required Field",
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                      label: const Text("Info"),
                      hintText: "He We Chat",
                      prefixIcon: const Icon(
                        Icons.info,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * .5, mq.height * .08),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Apis.updateUserInfo().then((value) {
                          Dailog.showSnackBar(
                            context,
                            "Profile Update Successfully",
                          );
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Update",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            top: mq.height * 0.03,
            bottom: mq.height * 0.05,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: mq.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * .15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                          if(image !=null){
                            log("image path: ${image.path}");
                            setState(() {
                              _image=image.path;
                            });
                            Apis.updateProfileimage(File(_image!));
                            Navigator.pop(context);
                          }
                    },
                    child: Image.asset("images/add_image.png"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * .15),
                    ),
                    onPressed: () async {
                         final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                          if(image !=null){
                            log("image path: ${image.path}");
                            setState(() {
                              _image=image.path;
                            });
                            Apis.updateProfileimage(File(_image!));
                            Navigator.pop(context);
                          }
                    },
                    child: Image.asset("images/camera.png"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}
