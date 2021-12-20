import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:math_pilot/game/object/enemy/enemy.dart';
import 'package:math_pilot/game/space_game.dart';

class Bullet extends SpriteComponent with HasHitboxes, Collidable {
  late SpaceGame _gameRef;
  late MaterialColor _particleColor;
  double _speed = 450;
  Vector2 direction = Vector2(0, -1);

  final int level;

  Random _random = Random();
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 200;
  }

  Bullet({
    required SpaceGame gameRef,
    required Sprite? sprite,
    required Vector2? position,
    required Vector2? size,
    required this.level,
    required particleColor,
  }) : super(sprite: sprite, position: position, size: size) {
    this._gameRef = gameRef;
    this._particleColor = particleColor;
  }

  @override
  void onMount() {
    super.onMount();
    final hitbox = HitboxCircle(normalizedRadius: 0.4);
    addHitbox(hitbox);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Enemy) {
      _gameRef.remove(this);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    this.position += direction * this._speed * dt;

    //Add particles to the bullet
    final bulletParticle = ParticleComponent(
      Particle.generate(
        count: 5,
        lifespan: 0.05,
        generator: (i) => AcceleratedParticle(
            acceleration: getRandomVector(),
            speed: getRandomVector(),
            position: this.position.clone() + Vector2(0, this.size.y / 3),
            child: CircleParticle(
              radius: 1,
              paint: Paint()..color = _particleColor,
            )),
      ),
    );

    _gameRef.add(bulletParticle);

    if (this.position.y < 0) {
      _gameRef.remove(this);
      _gameRef.remove(bulletParticle);
    }
  }
}
