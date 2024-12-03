import 'dart:developer';
import 'package:chatapp/api/api.dart';
import 'package:chatapp/helper/dailo.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isanimated = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isanimated = true;
      });
    });
  }

 _handleGoogleSignin() async {
  // عرض مؤشر التحميل
  Dailog.showProccessBar(context);

  try {
    // محاولة تسجيل الدخول باستخدام Google
    final user = await _signInWithGoogle();

    // إغلاق مؤشر التحميل
    Navigator.pop(context);

    if (user != null) {
      log("User : ${user.user}");
      log("User Additional Info : ${user.additionalUserInfo}");

      // التحقق من وجود المستخدم في قاعدة البيانات
      final userExists = await Apis.userExist();

      if (userExists) {
        // الانتقال إلى الشاشة الرئيسية إذا كان المستخدم موجودًا
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // إنشاء مستخدم جديد ثم الانتقال إلى الشاشة الرئيسية
        await Apis.createUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      log("Google Sign-In returned null user");
    }
  } catch (e) {
    // معالجة الأخطاء أثناء تسجيل الدخول
    Navigator.pop(context); // إغلاق مؤشر التحميل إذا حدث خطأ
    log("Error during Google Sign-In: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error during Google Sign-In: $e")),
    );
  }
}


  Future<UserCredential?> _signInWithGoogle() async {
   try{
     // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
   }catch(e){
 log("ERROR : ${e}");
 Dailog.showSnackBar(context,"Please Check The Internet(SomeThing Wrong)");
 return null;
   }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              duration: const Duration(seconds: 2),
              width: mq.width * 0.4,
              top: mq.height * 0.1,
              right: _isanimated ? mq.width * 0.3 : -mq.width * 0.10,
              child: Image.asset("images/chat.png")),
          Positioned(
              width: mq.width * 0.7,
              bottom: mq.height * 0.1,
              left: mq.width * 0.2,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 223, 255, 187)),
                  onPressed: () {
                   _handleGoogleSignin();
                  },
                  icon: Image.asset(
                    "images/google.png",
                    height: mq.height * 0.1,
                    width: mq.width * 0.1,
                  ),
                  label: RichText(
                    text: const TextSpan(
                        text: "   Sign In With ",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                              text: "Google",
                              style: TextStyle(fontWeight: FontWeight.w500))
                        ]),
                  ))),
        ],
      ),
    );
  }
}
