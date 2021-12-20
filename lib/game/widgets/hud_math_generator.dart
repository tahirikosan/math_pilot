import 'dart:math';

import 'package:flame/components.dart';
import 'package:math_pilot/game/space_game.dart';
import 'package:flutter/material.dart';
import 'package:math_pilot/models/math_equation_data.dart';
import 'package:math_pilot/util/fonts.dart';
import 'package:provider/provider.dart';

final TextPaint _textRenderer = TextPaint(
  style: TextStyle(
    color: Colors.white,
    fontFamily: MyFonts.bungeeInline,
    fontSize: 16,
  ),
);

final TextBoxConfig _boxConfig = TextBoxConfig(
  timePerChar: 0.05,
  growingBox: true,
  margins: EdgeInsets.fromLTRB(12, 12, 18, 12),
);

class HudMathGenerator extends TextBoxComponent with HasGameRef<SpaceGame> {
  List operators = ["+", "-", "÷", "×"];
  Random _random = Random();
  late MathEquationData _mathEquationData;

  HudMathGenerator({
    required Vector2? position,
  }) : super(
          position: position,
          textRenderer: _textRenderer,
          boxConfig: _boxConfig,
        );

  @override
  void onMount() {
    if (gameRef.buildContext != null) {
      _mathEquationData =
          Provider.of<MathEquationData>(gameRef.buildContext!, listen: false);
    }
    resetMathEquation();
    super.onMount();
  }

  void resetMathEquation() {
    int firstNumber = _random.nextInt(5);
    int secondNumber = _random.nextInt(4) + 1; // 1 upto 4;

    //Select a random operator
    int operatorIndex = _random.nextInt(3);
    String operator = operators[operatorIndex];
    this.text = "$firstNumber $operator $secondNumber = ? ";

    // Set math equation data to consume later
    _mathEquationData.setNewData(
      firstNumber: firstNumber,
      secondNumber: secondNumber,
      answer: getAnswer(operatorIndex, firstNumber, secondNumber),
    );
    redraw();
  }

  @override
  void drawBackground(Canvas c) {
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    c.drawRect(rect, Paint()..color = Colors.blue);
  }

  int getAnswer(int operatorIndex, int firstNumber, int secondNumber) {
    switch (operatorIndex) {
      case 0:
        return firstNumber + secondNumber;
      case 1:
        return firstNumber - secondNumber;
      case 2:
        return firstNumber ~/ secondNumber;
      case 3:
        return firstNumber * secondNumber;
      default:
        return firstNumber + secondNumber;
    }
  }
}
