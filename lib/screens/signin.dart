import 'package:flutter/material.dart';
import 'package:kelemni/widgets/google_sign_in_button.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Padding(
        padding: EdgeInsets.only(bottom: 20.0, left: 15.0, right: 15.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Bienvenue à Kelemni Chat App',
                          style:
                              TextStyle(fontSize: 20, color: Color(0xFF8a2c02)),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Image.asset(
                      'assets/Kelemni.png',
                      height: 160,
                    ),
                  ),
                  SizedBox(height: 20),
                  Flexible(
                    flex: 1,
                    child: Image.asset(
                      'assets/sign_in.png',
                      height: 160,
                    ),
                  ),
                  SizedBox(height: 50),
                  GoogleSignInButton()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
