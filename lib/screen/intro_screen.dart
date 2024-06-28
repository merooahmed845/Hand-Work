import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // لحزمة الرسوم المتحركة
import '../model/server.dart';
import 'home_user.dart';
import 'home_worker.dart';
import 'LoginPage.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nationalID = prefs.getString('nationalID');
    String? password = prefs.getString('password');

    await Future.delayed(const Duration(seconds: 3));

    if (nationalID != null && password != null) {
      var result = await Account.checkUser(nationalID, password);
      if (result['authenticated']) {
        if (result['user_type'] == 'User') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        } else if (result['user_type'] == 'Worker') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WorkerPage()),
          );
        }
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/pkpk.png', height: 200),
              const SizedBox(height: 20),
              const Text(
                "Welcome to HandWork Application",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              const SizedBox(height: 20),
              const SpinKitFadingCircle( // حزمة الرسوم المتحركة
                color: Colors.green,
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
