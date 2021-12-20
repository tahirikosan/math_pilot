import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:math_pilot/game/object/bullet.dart';
import 'package:math_pilot/game/space_game.dart';

class CustomButton extends SpriteComponent
    with Tappable, HasGameRef<SpaceGame> {
  void Function(TapDownInfo info) myOnTapDown;

  CustomButton({
    required Sprite? sprite,
    Vector2? position,
    Vector2? size,
    Paint? paint,
    required this.myOnTapDown,
  }) : super(sprite: sprite, position: position, size: size, paint: paint);

  @override
  bool onTapDown(TapDownInfo info) {
    myOnTapDown.call(info);
    return super.onTapDown(info);
  }
}
