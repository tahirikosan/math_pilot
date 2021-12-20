import 'package:flutter/cupertino.dart';

class MathEquationData extends ChangeNotifier {
  int firstNumber;
  int secondNumber;
  int answer;
  MathEquationData({
    required this.firstNumber,
    required this.secondNumber,
    required this.answer,
  });

  void setNewData(
      {required firstNumber, required secondNumber, required answer}) {
    this.firstNumber = firstNumber;
    this.secondNumber = secondNumber;
    this.answer = answer;
    notifyListeners();
  }

  static MathEquationData defaultData() {
    return MathEquationData(firstNumber: 1, secondNumber: 1, answer: 1);
  }
}
