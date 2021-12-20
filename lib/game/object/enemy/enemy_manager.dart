import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:math_pilot/game/object/enemy/enemy.dart';
import 'package:math_pilot/game/space_game.dart';
import 'package:math_pilot/models/enemy_data.dart';
import 'package:math_pilot/models/math_equation_data.dart';
import 'package:math_pilot/models/player_data.dart';
import 'package:provider/provider.dart';

class EnemyManager extends Component with HasGameRef<SpaceGame> {
  late MathEquationData _mathEquationData;
  late Timer _respawnTimer;
  late Timer _freezeTimer;
  SpriteSheet spriteSheet;
  Random random = Random();
  int enemyTypeId = 11;
  // bool for enemy with math correct answer
  bool _isDangerousSpawned = false;
  set isDangerousSpawned(bool value) {
    _isDangerousSpawned = value;
  }

  EnemyManager({required this.spriteSheet}) : super() {
    _respawnTimer = Timer(1, onTick: _spawnEnemy, repeat: true);
    _freezeTimer = Timer(2, onTick: () {
      _respawnTimer.start();
    });
  }

  void _spawnEnemy() {
    _setMathEquationData();

    Vector2 initialSize = Vector2(64, 64);
    // random.nextDouble() generates a random number between 0 and 1.
    // Multiplying it by vector such that the enemy sprite remains within the screen.
    Vector2 position = Vector2(random.nextDouble() * this.gameRef.size.x, 0);

    // Clamps the vector such that the enemt sprite remains within the screen.
    position.clamp(
        Vector2.zero() + initialSize / 2, this.gameRef.size - initialSize / 2);

    if (gameRef.buildContext != null) {
      int currentScore =
          Provider.of<PlayerData>(gameRef.buildContext!, listen: false)
              .currentScore;
      int maxLevel = mapScoreToMaxEnemyLevel(currentScore);
      final enemyData = _enemyDataList.elementAt(random.nextInt(maxLevel * 4));

      Enemy enemy = Enemy(
        sprite: spriteSheet.getSpriteById(enemyData.spriteId),
        size: initialSize,
        position: position,
        spaceGame: gameRef,
        enemyData: enemyData,
      );

      if (!_isDangerousSpawned) {
        enemy.mathNumber = _mathEquationData.answer;
        enemy.dangerous = true;
        isDangerousSpawned = true;
      } else {
        enemy.mathNumber = random.nextInt(10);
        enemy.dangerous = false;
      }

      // Make sure that the enemy sprite is centered.
      enemy.anchor = Anchor.center;
      gameRef.add(enemy);
    }
  }

  int mapScoreToMaxEnemyLevel(int score) {
    int level = 1;
    if (score > 1500) {
      level = 4;
    } else if (score > 500) {
      level = 3;
    } else if (score > 100) {
      level = 2;
    }
    return level;
  }

  @override
  void onMount() {
    super.onMount();
    // start the _respawnTimer as soon as current enemy manager get prepared
    // and added to the game isntance.
    _respawnTimer.start();
  }

  @override
  void onRemove() {
    super.onRemove();
    _respawnTimer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _respawnTimer.update(dt);
    _freezeTimer.update(dt);
  }

  void reset() {
    isDangerousSpawned = false;
    _respawnTimer.stop();
    _respawnTimer.start();
  }

  void freeze() {
    _respawnTimer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }

  // Get math equation data to attach answer to enemy.
  void _setMathEquationData() {
    if (gameRef.buildContext != null) {
      _mathEquationData =
          Provider.of<MathEquationData>(gameRef.buildContext!, listen: false);
    }
  }

  /// A private list of all [EnemyData]s.
  static const List<EnemyData> _enemyDataList = [
    EnemyData(
      killPoint: 1,
      speed: 100,
      spriteId: 8,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 2,
      speed: 100,
      spriteId: 9,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 4,
      speed: 100,
      spriteId: 10,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 4,
      speed: 100,
      spriteId: 11,
      level: 1,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 150,
      spriteId: 12,
      level: 2,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 150,
      spriteId: 13,
      level: 2,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 150,
      spriteId: 14,
      level: 2,
      hMove: false,
    ),
    EnemyData(
      killPoint: 6,
      speed: 150,
      spriteId: 15,
      level: 2,
      hMove: true,
    ),
    EnemyData(
      killPoint: 10,
      speed: 200,
      spriteId: 16,
      level: 3,
      hMove: false,
    ),
    EnemyData(
      killPoint: 10,
      speed: 200,
      spriteId: 17,
      level: 3,
      hMove: false,
    ),
    EnemyData(
      killPoint: 10,
      speed: 250,
      spriteId: 18,
      level: 3,
      hMove: true,
    ),
    EnemyData(
      killPoint: 10,
      speed: 250,
      spriteId: 19,
      level: 3,
      hMove: false,
    ),
    EnemyData(
      killPoint: 10,
      speed: 250,
      spriteId: 20,
      level: 4,
      hMove: false,
    ),
    EnemyData(
      killPoint: 50,
      speed: 250,
      spriteId: 21,
      level: 4,
      hMove: true,
    ),
    EnemyData(
      killPoint: 50,
      speed: 300,
      spriteId: 22,
      level: 4,
      hMove: false,
    ),
    EnemyData(
      killPoint: 50,
      speed: 300,
      spriteId: 23,
      level: 4,
      hMove: false,
    )
  ];
}
