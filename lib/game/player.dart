// This componen class represents the player character in game.
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:math_pilot/game/object/bullet.dart';
import 'package:math_pilot/game/object/enemy/enemy.dart';
import 'package:math_pilot/game/space_game.dart';
import 'package:math_pilot/models/player_data.dart';
import 'package:math_pilot/models/spaceship_details.dart';
import 'package:math_pilot/util/audio_player_component.dart';
import 'package:math_pilot/util/command.dart';
import 'package:math_pilot/util/conts_priority.dart';
import 'package:provider/provider.dart';

class Player extends SpriteComponent
    with HasHitboxes, Collidable, HasGameRef<SpaceGame> {
  static const MAX_HEALTH = 100;

  late int _health;
  int get health => _health;

  // Type of current spaceship
  SpaceshipType spaceshipType;
  // Deatils of current spaceship
  Spaceship _spaceship;

  late PlayerData _playerData;
  int get score => _playerData.currentScore;

  late Timer _multipleBulletTimer;
  bool _shootMultipleBullets = false;

  Random _random = Random();
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 200;
  }

  Player({
    required this.spaceshipType,
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  })  : this._spaceship = Spaceship.getSpaceshipType(spaceshipType),
        super(sprite: sprite, position: position, size: size) {
    _multipleBulletTimer = Timer(4, onTick: () {
      _shootMultipleBullets = false;
    });
    _health = MAX_HEALTH;
  }

  void onAttach() {
    if (gameRef.buildContext != null) {
      _playerData =
          Provider.of<PlayerData>(gameRef.buildContext!, listen: true);
    }
  }

  @override
  void onMount() {
    super.onMount();
    final hitbox = HitboxCircle(normalizedRadius: 0.8);
    addHitbox(hitbox);

    gameRef.children.changePriority(this, PLAYER_PRIORITY);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    if (other is Enemy) {
      other.remove(other);
      _health -= 10;
      if (_health < 0) {
        _health = 0;
      }

      // Shake camera on collision.
      gameRef.camera.shake(intensity: 5);
    }
  }

  // Called by game class for every frame.
  @override
  void update(double dt) {
    super.update(dt);

    _multipleBulletTimer.update(dt);

    /* Increment the current position of player by speed * delta time along moveDirection
    Delta is the time elapsed since last update.For devices with higher frame rates,
    delta time will be smaller and for devices with lower frame rates , it will be larger.Multiplying speed with
    delta time ensure that player speed remains same irrespective of the device FPS.
     */
    if (gameRef.joystickMovement.direction != JoystickDirection.idle) {
      position.add(gameRef.joystickMovement.delta * _spaceship.speed * dt);
      //angle = gameRef.joystickMovement.delta.screenAngle();
    }
    //this.position += _moveDirection.normalized() * _speed * dt;
    // random.nextDouble() generates a random number between 0 and 1.
    // Multiplying it by vector such that the player sprite remains within the screen.
    this.position.clamp(
        Vector2.zero() + this.size / 2, this.gameRef.size - this.size / 2);

    final particleComponent = ParticleComponent(
      Particle.generate(
        count: 5,
        lifespan: 0.1,
        generator: (i) => AcceleratedParticle(
          acceleration: getRandomVector(),
          speed: getRandomVector(),
          position: this.position.clone() + Vector2(0, this.size.y / 4),
          child: CircleParticle(
              radius: 1, paint: Paint()..color = _spaceship.color),
        ),
      ),
    );

    gameRef.add(particleComponent);
  }

  void shoot() {
    //Bullet goes directly north
    Bullet bullet = Bullet(
      gameRef: gameRef,
      sprite: gameRef.spriteSheet.getSpriteById(gameRef.ID_SPRITE_BULLET),
      size: Vector2(64, 64),
      position: this.position.clone(),
      level: _spaceship.level,
      particleColor: _spaceship.color,
    );
    bullet.anchor = Anchor.center;
    gameRef.add(bullet);

    gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSoundEffect(
          AudioPlayerComponent.audioNamePlayerLaser, 0.7);
    }));

    //Bullet goes directly north west and north east
    if (_shootMultipleBullets) {
      for (int i = -1; i < 2; i += 2) {
        Bullet bullet = Bullet(
          gameRef: gameRef,
          sprite: gameRef.spriteSheet.getSpriteById(gameRef.ID_SPRITE_BULLET),
          size: Vector2(64, 64),
          position: this.position.clone(),
          level: _spaceship.level,
          particleColor: _spaceship.color,
        );
        bullet.anchor = Anchor.center;
        bullet.direction.rotate(i * pi / 6);
        gameRef.add(bullet);
      }
    }
  }

  void addToScore(int points) {
    _playerData.currentScore += points;
    _playerData.money += points;
    _playerData.save();
  }

  // Increase use health by healthPoints
  void increaseHealthBy(int healthPoints) {
    _health += healthPoints;
    if (_health > 100) {
      _health = 100;
    }
  }

  void reset() {
    _playerData.currentScore = 0;
    this._health = 100;
    this.position = gameRef.canvasSize / 2;
  }

  void setSpaceshipType(SpaceshipType spaceshipType) {
    this.spaceshipType = spaceshipType;
    this._spaceship = Spaceship.getSpaceshipType(spaceshipType);
    sprite = gameRef.spriteSheet.getSpriteById(_spaceship.spriteId);
  }

  void shootMultipleBullets() {
    _shootMultipleBullets = true;
    _multipleBulletTimer.stop();
    _multipleBulletTimer.start();
  }
}
