import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:math_pilot/game/object/earth.dart';
import 'package:math_pilot/game/object/enemy/enemy_manager.dart';
import 'package:math_pilot/game/player.dart';
import 'package:math_pilot/game/space_game.dart';
import 'package:math_pilot/game/object/bullet.dart';
import 'package:math_pilot/game/widgets/hud_math_generator.dart';
import 'package:math_pilot/models/enemy_data.dart';
import 'package:math_pilot/models/math_equation_data.dart';
import 'package:math_pilot/util/audio_player_component.dart';
import 'package:math_pilot/util/command.dart';
import 'package:math_pilot/util/fonts.dart';
import 'package:math_pilot/util/knows_game_size.dart';

// This class represent an enemt component.
class Enemy extends SpriteComponent
    with HasHitboxes, Collidable, HasGameRef<SpaceGame> {
  // The speed of the enemy
  double _defaultSpeed = 250;
  double _speed = 250;
  late Vector2 _gameSize;
  Random _random = Random();
  Vector2 moveDirection = Vector2(0, 1);
  late Timer _freezeTimer;
  late SpaceGame spaceGame;
  final EnemyData enemyData;
  int _hitpoints = 10;

  // Mark enemy as dangerous or not.
  late bool _dangerous;
  set dangerous(bool value) {
    _dangerous = value;
  }

  // Give enemy a mathNumber to show, this can be math equation answer.
  late int _mathNumber;
  set mathNumber(int value) {
    _mathNumber = value;
  }

  TextComponent _hpText = TextComponent(
    text: "10 HP",
    textRenderer: TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontFamily: MyFonts.bungeeInline,
      ),
    ),
  );

  TextComponent _mathNumberText = TextComponent(
    text: "10",
    textRenderer: TextPaint(
      style: TextStyle(
        color: Colors.blue,
        fontSize: 16,
        fontFamily: MyFonts.bungeeInline,
      ),
    ),
  );

  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2.random(_random)) * 500;
  }

  Vector2 getRandomDirection() {
    return (Vector2.random(_random) - Vector2(0.5, -1)).normalized();
  }

  Enemy({
    required Sprite? sprite,
    required Vector2? position,
    required Vector2? size,
    required this.enemyData,
    required SpaceGame spaceGame,
  }) : super(sprite: sprite, position: position, size: size) {
    // Rotates the enemy component by 180 degrees.This is needed because
    // all the sprites initally face the same direct, but we want enemies to be
    // moving in opposite direction.
    angle = pi;

    _speed = enemyData.speed;

    _hitpoints = enemyData.level * 10;

    _freezeTimer = Timer(2, onTick: () {
      _speed = enemyData.speed;
    });

    if (true) {
      moveDirection = getRandomDirection();
    }

    this.spaceGame = spaceGame;
  }

  @override
  void onMount() {
    super.onMount();
    // Add hitbox to enemy for detect collisions.
    final hitbox = HitboxCircle(normalizedRadius: 0.8);
    addHitbox(hitbox);

    // Set hpText to show top of enemy.
    _hpText.angle = pi;
    _hpText.position = Vector2(50, 80);
    add(_hpText);

    // Set mathNumberText to show below enemy.
    _mathNumberText.text = _mathNumber.toString();
    _mathNumberText.angle = pi;
    _mathNumberText.position = Vector2(this.size.x / 2 + 5, 0);
    add(_mathNumberText);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);
    // If collidable is Bullet then remove this enemy;
    if (other is Bullet) {
      _hitpoints -= other.level * 10;
    } else if (other is Player) {
      _hitpoints = 0;
    }
  }

  void destroy() {
    destroyedByPlayer();
    spaceGame.remove(this);

    spaceGame.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSoundEffect(
          AudioPlayerComponent.audioNameEnemyDestroy, 0.5);
    }));

    // Increase player score.
    final command = Command<Player>(action: (player) {
      player.addToScore(enemyData.killPoint);
    });
    spaceGame.addCommand(command);

    final particleComponent = ParticleComponent(
      Particle.generate(
        count: 20,
        lifespan: 0.5,
        generator: (i) => AcceleratedParticle(
          acceleration: getRandomVector(),
          speed: getRandomVector() / 2,
          position: this.position.clone(),
          child: CircleParticle(
            radius: 1,
            paint: Paint()
              ..color = Color((_random.nextDouble() * 0xFFFFFF).toInt())
                  .withOpacity(1.0),
          ),
        ),
      ),
    );
    spaceGame.add(particleComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _hpText.text = "$_hitpoints HP";
    if (_hitpoints <= 0) {
      destroy();
    }

    _freezeTimer.update(dt);

    this.position += moveDirection * _speed * dt;

    if (this.position.y > this._gameSize.y) {
      remove(this);
      destroyedByOutOfMap();
    } else if ((this.position.x < this.size.x / 2) ||
        (this.position.x > (this._gameSize.x - this.size.x / 2))) {
      // On enemy hit left or right of the screen change enemy's horizontal direction
      moveDirection.x *= -1;
    }
  }

  @override
  void render(Canvas canvas) {
    // To see hitbox borders
    // debugMode = true;
    super.render(canvas);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    _gameSize = gameSize;
  }

  @override
  void onRemove() {
    super.onRemove();
  }

  // Our player destroyed dangerous enemy so kill all and reset equation.
  void destroyedByPlayer() {
    if (_dangerous) {
      _dangerous = false;
      final commanResetMathEquation =
          Command<HudMathGenerator>(action: (hudMathGenerator) {
        hudMathGenerator.resetMathEquation();
      });
      spaceGame.addCommand(commanResetMathEquation);

      final resetIsDangerousSpawned =
          Command<EnemyManager>(action: (enemyManager) {
        enemyManager.isDangerousSpawned = false;
      });
      spaceGame.addCommand(resetIsDangerousSpawned);

      final destroyAll = Command<Enemy>(action: (enemy) {
        enemy.destroy();
      });

      spaceGame.addCommand(destroyAll);
    }
  }

  // Dangerous Enemy destroyed by out of map.Just reset equation.
  void destroyedByOutOfMap() {
    if (!this.shouldRemove) {
      this.shouldRemove = true;
      if (_dangerous) {
        _dangerous = false;

        // Reset math equation
        final commanResetMathEquation =
            Command<HudMathGenerator>(action: (hudMathGenerator) {
          hudMathGenerator.resetMathEquation();
        });
        spaceGame.addCommand(commanResetMathEquation);

        // Reset isDangerousSpawned inside enemy manager to create another enemy that is dangerous and has answer to equation.
        final commandResetIsDangerousSpawned =
            Command<EnemyManager>(action: (enemyManager) {
          enemyManager.isDangerousSpawned = false;
        });
        spaceGame.addCommand(commandResetIsDangerousSpawned);
      }

      final commandDamageToEarth = Command<Earth>(action: (earth) {
        earth.decreaseHealthBy(this._hitpoints);
      });
      spaceGame.addCommand(commandDamageToEarth);
    }
  }

  void freeze() {
    _speed = 0;
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
