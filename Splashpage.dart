import 'package:flutter/material.dart';
import 'package:jmc_syllabus/pages/Homepage.dart';

class Splashpage extends StatefulWidget {
  @override
  createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {
  @override
  void initState() {
    super.initState();
    Splashtohome();
  }

  void Splashtohome() async {
    await Future.delayed(const Duration(milliseconds: 1500), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Homepage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 200,
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Image(
                      image: AssetImage("assets/images/jmc_new_logo.png")),
                Container(
                    height: 300,
                    width: 300,
                    color: Colors.black12,
                  ),
                ],
              ),
            ),
            // if you want to show any text bellow the logo then use this...
            const DefaultTextStyle(
                style: TextStyle(
                    fontSize: 35,
                    color: Colors.white54,
                    fontWeight: FontWeight.w300),
                child: Text(""))
          ],
        ),
      ),
    );
  }
}
