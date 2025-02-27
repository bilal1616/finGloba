import 'dart:async';
import 'package:flutter/material.dart';
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
            Image.asset('assets/fingloba.png', width: 300, height: 300),
            const SizedBox(height: 8),
            Text("Borsa-Döviz-Kripto",
                style: const TextStyle(
                    fontSize: 30,
                    fontFamily: "Popins",
                    fontWeight: FontWeight.w700)),
            const CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}
