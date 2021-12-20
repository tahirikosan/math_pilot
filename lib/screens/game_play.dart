import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:math_pilot/game/space_game.dart';
import 'package:math_pilot/game/widgets/overlays/game_over_menu.dart';
import 'package:math_pilot/game/widgets/overlays/pause_button.dart';
import 'package:math_pilot/game/widgets/overlays/pause_menu.dart';
import 'package:math_pilot/main.dart';

class GamePlay extends StatefulWidget {
  GamePlay({Key? key}) : super(key: key);

  @override
  _GamePlayState createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  late SpaceGame _spaceGame;

  @override
  void initState() {
    super.initState();
    _spaceGame = SpaceGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _spaceGame,
        initialActiveOverlays: [
          PauseButton.ID,
        ],
        overlayBuilderMap: {
          PauseButton.ID: (BuildContext context, SpaceGame gameRef) =>
              PauseButton(
                gameRef: gameRef,
              ),
          PauseMenu.ID: (BuildContext context, SpaceGame gameRef) =>
              PauseMenu(gameRef: gameRef),
          GameOverMenu.ID: (BuildContext context, SpaceGame gameRef) =>
              GameOverMenu(gameRef: gameRef)
        },
      ),
    );
  }
}
