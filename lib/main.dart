import 'package:chatapp/screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
late Size mq;
void main() {
   WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]).then((value)async{
   await Firebase.initializeApp();
  runApp(const MyApp());
  });

}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
       appBarTheme:const AppBarTheme(
           centerTitle: true,
        elevation: 1,
         iconTheme:IconThemeData(color: Colors.black),
         titleTextStyle: TextStyle(color:Colors.black,fontSize: 19, fontWeight: FontWeight.normal),
       )
      ),
      home: const SplashScreen()
    );
  }
}

