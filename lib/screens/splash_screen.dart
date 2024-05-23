import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'user_list_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250.0,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 30.0,
                  fontFamily: 'Bobbers',
                  color: Colors.black,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText('Amine Jameli'),
                    TypewriterAnimatedText('Flutter Project'),
                  ],
                  onTap: () {
                    print("Tap Event");
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
