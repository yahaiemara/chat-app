import 'dart:developer';

import 'package:chatapp/api/api.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/screen/auth/login_screen.dart';
import 'package:chatapp/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // تأجيل التنفيذ لمدة 5 ثوانٍ
    Future.delayed(const Duration(seconds:2 ), () {
      // إعداد شريط الحالة
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,statusBarColor: Colors.white),
      );

      // استخدام WidgetsBinding لتأجيل التنقل إلى ما بعد اكتمال بناء الشاشة
      WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      // التحقق من حالة تسجيل الدخول للمستخدم
      if (Apis.auth.currentUser != null) {
        log("User is already signed in: ${Apis.auth.currentUser!.uid}");

        // الانتقال إلى الشاشة الرئيسية
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        log("No user signed in");

        // الانتقال إلى شاشة تسجيل الدخول
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      // معالجة الأخطاء أثناء التحقق
      log("Error during splash screen navigation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  });
});
   
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة
    mq = MediaQuery.of(context).size;
    return Scaffold(
    
      body: Stack(
        children: [
          // عرض صورة في الأعلى
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            width: mq.width * 0.4,
            top: mq.height * 0.1,
            right: mq.width * 0.3,
            child: Image.asset("images/chat.png"),
          ),
          // نص في الأسفل
          Positioned(
            width: mq.width * 0.7,
            bottom: mq.height * 0.1,
            left: mq.width*0.2,
            child: const Text(
              "Made In Egypt ❤️",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
