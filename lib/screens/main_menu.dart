import 'package:flutter/material.dart';
import 'package:math_pilot/screens/select_spaceship.dart';
import 'package:math_pilot/screens/settings_menu.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Text(
                "Math Pilot",
                style: TextStyle(color: Colors.black, fontSize: 50.0, shadows: [
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SelectSpaceship(),
                    ),
                  );
                },
                child: Text("Play"),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SettingsMenu()));
                },
                child: Text("Options"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
