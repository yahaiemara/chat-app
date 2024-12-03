import 'dart:developer';

import 'package:chatapp/api/api.dart';
import 'package:chatapp/model/chat_user.dart';
import 'package:chatapp/screen/profile_screen.dart';
import 'package:chatapp/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  List<ChatUser> _searchlist = [];
  bool _issearch = false;

  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();
 
    SystemChannels.lifecycle.setMessageHandler((message){
     log("message :${message}");
     if(Apis.auth.currentUser !=null){
     if(message.toString().contains("resume"))Apis.updateActiveStatus(true);
     if(message.toString().contains("pause"))Apis.updateActiveStatus(false);
     }

     return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () {
          if (_issearch) {
            setState(() {
              _issearch = !_issearch;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              leading: const Icon(CupertinoIcons.home),
              title: _issearch
                  ? TextField(
                      autofocus: true,
                      style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                      onChanged: (val) {
                        _searchlist.clear();
                        for (var i in list) {
                          if (i.name!
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email!
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchlist.add(i);
                          }
                          setState(() {
                            _searchlist;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Name Or Email....",
                      ),
                    )
                  : const Text(
                      "We Chat",
                    ),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _issearch = !_issearch;
                      });
                    },
                    icon: Icon(_issearch
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search)),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen(user: Apis.me)));
                    },
                    icon: const Icon(Icons.more_vert))
              ],
            ),
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () async {
            //     await Apis.auth.signOut();
            //     await GoogleSignIn().signOut();
            //     Navigator.pushReplacement(context,
            //         MaterialPageRoute(builder: (_) => const SplashScreen()));
            //   },
            //   child: const Icon(Icons.add_comment),
            // ),
            body: StreamBuilder(
              stream: Apis.getallUser(),
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
                    list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];
                    if (list.isNotEmpty) {
                      return ListView.builder(
                         
                          itemCount:
                              _issearch ? _searchlist.length : list.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ChatUserCard(
                              user:
                                  _issearch ? _searchlist[index] : list[index],
                            );
                          });
                    } else {
                      return const Center(
                          child: Text(
                        "No Connection Found",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ));
                    }
                }
              },
            )),
      ),
    );
  }
}
