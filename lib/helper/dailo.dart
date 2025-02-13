import 'package:flutter/material.dart';

class Dailog {
  static void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.blue.withOpacity(.8),
      behavior: SnackBarBehavior.floating,
    ));
  }

   static void showProccessBar(BuildContext context) {
    showDialog(context: context,builder: (_)=>const Center(child:  CircularProgressIndicator(),));
  }
}
