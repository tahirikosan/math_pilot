import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:math_pilot/firebase/authentication.dart';
import 'package:math_pilot/screens/main_menu.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  Future<void> signInWithGoole() async {
    await Authentication.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);
    if (user != null) {
      return MainMenu();
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Text(
                  "Math Pilot Splash",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.black, fontSize: 50.0, shadows: [
                    Shadow(
                      blurRadius: 20.0,
                      color: Colors.blue,
                      offset: Offset(0, 0),
                    ),
                  ]),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: ElevatedButton(
                  onPressed: () {
                    signInWithGoole();
                  },
                  child: Text("Sign in"),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
