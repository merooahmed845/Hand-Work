import 'package:flutter/material.dart';
import 'package:hand2/screen/LoginPage.dart';
import 'package:hand2/screen/SignUp.dart';
import 'package:hand2/screen/forgetPassword.dart';
import 'package:hand2/screen/home_user.dart';
import 'package:hand2/screen/home_worker.dart';
import 'package:hand2/screen/intro_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:const IntroScreen(),
        initialRoute: 'IntroScreen',
        routes: {
          'SignUpPage': (context) => const SignUpPage(),
          'home_user': (context) => const SearchPage(),
          'home_worker': (context) => const WorkerPage(),
          'LoginPage': (context) => const LoginPage(),
          'IntroScreen': (context) => const IntroScreen(),
          'ForgetPassword': (context) => ForgetPassword(),
        });
  }
}
