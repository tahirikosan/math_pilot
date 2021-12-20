import 'package:flutter/material.dart';
import 'package:math_pilot/game/space_game.dart';
import 'package:math_pilot/game/widgets/overlays/pause_button.dart';
import 'package:math_pilot/screens/main_menu.dart';

class GameOverMenu extends StatelessWidget {
  static const String ID = "GameOverMenu";
  final SpaceGame gameRef;
  const GameOverMenu({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Text(
              "Game Over",
              style: TextStyle(color: Colors.black, fontSize: 50.0, shadows: [
                Shadow(
                  blurRadius: 20.0,
                  color: Colors.blue,
                  offset: Offset(0, 0),
                ),
              ]),
            ),
          ),
          // Restart Button
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              onPressed: () {
                gameRef.overlays.add(PauseButton.ID);
                gameRef.overlays.remove(GameOverMenu.ID);
                gameRef.reset();
                gameRef.resumeEngine();
              },
              child: Text("Restart"),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          // Exit Button
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton(
              onPressed: () {
                gameRef.overlays.remove(GameOverMenu.ID);
                gameRef.reset();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => MainMenu(),
                ));
              },
              child: Text("Exit"),
            ),
          ),
        ],
      ),
    );
  }
}
