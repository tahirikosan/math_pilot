import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:math_pilot/game/object/enemy/enemy.dart';
import 'package:math_pilot/game/object/enemy/enemy_manager.dart';
import 'package:math_pilot/game/object/power_up/power_up_manager.dart';
import 'package:math_pilot/game/player.dart';
import 'package:math_pilot/game/space_game.dart';
import 'package:math_pilot/util/audio_player_component.dart';
import 'package:math_pilot/util/command.dart';

abstract class PowerUp extends SpriteComponent with HasHitboxes, Collidable {
  late Timer _timer;

  late SpaceGame spaceGame;
  Sprite getSprite();
  void onActivated();

  PowerUp({
    required SpaceGame spaceGame,
    required Vector2? position,
    required Vector2? size,
    Sprite? sprite,
  }) : super(position: position, size: size, sprite: sprite) {
    this.spaceGame = spaceGame;
    _timer = Timer(3, onTick: () {
      spaceGame.remove(this);
    });
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  @override
  void onMount() {
    final hitbox = HitboxCircle(normalizedRadius: 0.5);
    addHitbox(hitbox);

    this.sprite = getSprite();

    _timer.start();
    super.onMount();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    if (other is Player) {
      spaceGame.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
        audioPlayer.playSoundEffect(AudioPlayerComponent.audioNamePowerUp, 1);
      }));
      onActivated();
      // remove power up
      spaceGame.remove(this);
    }
    super.onCollision(intersectionPoints, other);
  }
}

class PowerUpNuke extends PowerUp {
  PowerUpNuke({
    required SpaceGame spaceGame,
    required Vector2? position,
    required Vector2? size,
    Sprite? sprite,
  }) : super(
            spaceGame: spaceGame,
            position: position,
            size: size,
            sprite: sprite);

  @override
  Sprite getSprite() {
    return PowerUpManager.nukeSprite;
  }

  @override
  void onActivated() {
    // First destroy all
    final commandDestroyAll = Command<Enemy>(action: (enemy) {
      enemy.destroy();
    });
    spaceGame.addCommand(commandDestroyAll);
  }
}

class PowerUpHealth extends PowerUp {
  PowerUpHealth({
    required SpaceGame spaceGame,
    required Vector2? position,
    required Vector2? size,
    Sprite? sprite,
  }) : super(
            spaceGame: spaceGame,
            position: position,
            size: size,
            sprite: sprite);

  @override
  Sprite getSprite() {
    return PowerUpManager.healthSprite;
  }

  @override
  void onActivated() {
    final commandHealth = Command<Player>(action: (player) {
      player.increaseHealthBy(10);
    });
    spaceGame.addCommand(commandHealth);
  }
}

class PowerUpFreeze extends PowerUp {
  PowerUpFreeze({
    required SpaceGame spaceGame,
    required Vector2? position,
    required Vector2? size,
    Sprite? sprite,
  }) : super(
            spaceGame: spaceGame,
            position: position,
            size: size,
            sprite: sprite);

  @override
  Sprite getSprite() {
    return PowerUpManager.freezeSprite;
  }

  @override
  void onActivated() {
    final commandFreezeEnemy = Command<Enemy>(action: (enemy) {
      enemy.freeze();
    });

    final commandFreezeEnemyManager =
        Command<EnemyManager>(action: (enemyManager) {
      enemyManager.freeze();
    });

    final commandFreezePowerUpManager =
        Command<PowerUpManager>(action: (powerUpManager) {
      powerUpManager.freeze();
    });
    spaceGame.addCommand(commandFreezeEnemy);
    spaceGame.addCommand(commandFreezeEnemyManager);
    spaceGame.addCommand(commandFreezePowerUpManager);
  }
}

class PowerUpMultiFire extends PowerUp {
  PowerUpMultiFire({
    required SpaceGame spaceGame,
    required Vector2? position,
    required Vector2? size,
    Sprite? sprite,
  }) : super(
            spaceGame: spaceGame,
            position: position,
            size: size,
            sprite: sprite);

  @override
  Sprite getSprite() {
    return PowerUpManager.multiFireSprite;
  }

  @override
  void onActivated() {
    final commandMultiFire = Command<Player>(action: (player) {
      player.shootMultipleBullets();
    });
    spaceGame.addCommand(commandMultiFire);
  }
}
