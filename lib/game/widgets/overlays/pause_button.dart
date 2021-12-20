import 'package:flutter/material.dart';
import 'package:math_pilot/game/space_game.dart';
import 'package:math_pilot/game/widgets/overlays/pause_menu.dart';

class PauseButton extends StatelessWidget {
  static const String ID = "PauseButton";
  final SpaceGame gameRef;
  const PauseButton({Key? key, required this.gameRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(
        child: Icon(
          Icons.pause_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          gameRef.pauseGame();
          gameRef.overlays.add(PauseMenu.ID);
          gameRef.overlays.remove(PauseButton.ID);
        },
      ),
    );
  }
}
