import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/fingloba.png', width: 250, height: 250),
            const SizedBox(height: 12),
            const Text(
              "Borsa - Döviz - Kripto",
              style: TextStyle(
                fontSize: 26,
                fontFamily: "Popins",
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            const SpinKitCircle(
              color: Color.fromARGB(255, 158, 10, 10),
              size: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}
