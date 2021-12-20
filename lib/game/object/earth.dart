import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:math_pilot/game/space_game.dart';

class Earth extends SpriteComponent
    with HasHitboxes, Collidable, HasGameRef<SpaceGame> {
  static const EARHT_IMAGE = "earth.png";
  static const int MAX_HEALTH = 500;
  late int _health;
  int get health => _health;

  Earth(
      {required Sprite? sprite,
      required Vector2? size,
      required Vector2? position})
      : super(position: position, sprite: sprite, size: size) {
    _health = MAX_HEALTH;
  }

  @override
  void onMount() {
    final hitbox = HitboxCircle(normalizedRadius: 1);
    addHitbox(hitbox);
    super.onMount();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // To see hitbox borders
    //debugMode = true;
    super.render(canvas);
  }

  void increaseHealthBy() {
    _health += 20;
    if (_health >= MAX_HEALTH) {
      _health = MAX_HEALTH;
    }
  }

  // Decrease earth hp by enemy hp.
  void decreaseHealthBy(int enemyHp) {
    _health -= enemyHp;
    if (_health <= 0) {
      _health = 0;
    }
  }

  void reset() {
    _health = MAX_HEALTH;
  }
}
