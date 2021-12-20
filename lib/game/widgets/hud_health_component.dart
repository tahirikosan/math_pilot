import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:math_pilot/game/space_game.dart';
import 'package:math_pilot/util/fonts.dart';

class HudHealthComponent extends TextBoxComponent with HasGameRef<SpaceGame> {
  late int _health = 0;
  late int _maxHealth;
  HudHealthComponent({required int maxHealth, required Vector2 position})
      : super(
          position: position,
          textRenderer: TextPaint(
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: MyFonts.bungeeInline),
          ),
          boxConfig: TextBoxConfig(timePerChar: 0.05),
        ) {
    _maxHealth = maxHealth;
  }

  void setHealth(String newText, int health) {
    this.text = "$newText: $health";
    _health = health;
    redraw();
  }

  @override
  void drawBackground(Canvas c) {
    Rect rect = Rect.fromLTWH(0, 7, (_health / _maxHealth) * 100, 20);
    c.drawRect(rect, Paint()..color = Colors.blue);
  }
}
