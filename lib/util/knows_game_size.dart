import 'package:flame/components.dart';
import 'package:flame/input.dart';

mixin KnowsGameSize on Component {
  late Vector2 gameSize;

  void onResize(Vector2 newGameSize) {
    gameSize = newGameSize;
  }
}
