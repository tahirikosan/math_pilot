import 'dart:math';
import 'package:flame/components.dart';
import 'package:math_pilot/game/object/power_up/powerup.dart';
import 'package:math_pilot/game/space_game.dart';

enum PowerUpTypes { Health, Freeze, Nuke, MultiFire }

class PowerUpManager extends Component with HasGameRef<SpaceGame> {
  late Timer _respawnTimer;
  late Timer _freezeTimer;
  Random random = Random();

  static late Sprite healthSprite;
  static late Sprite nukeSprite;
  static late Sprite freezeSprite;
  static late Sprite multiFireSprite;

  static Map<PowerUpTypes,
          PowerUp Function(Vector2 position, Vector2 size, SpaceGame spaceGame)>
      _powerUpMap = {
    PowerUpTypes.Health: (position, size, spaceGame) =>
        PowerUpHealth(spaceGame: spaceGame, position: position, size: size),
    PowerUpTypes.Freeze: (position, size, spaceGame) =>
        PowerUpFreeze(spaceGame: spaceGame, position: position, size: size),
    PowerUpTypes.Nuke: (position, size, spaceGame) =>
        PowerUpNuke(spaceGame: spaceGame, position: position, size: size),
    PowerUpTypes.MultiFire: (position, size, spaceGame) =>
        PowerUpMultiFire(spaceGame: spaceGame, position: position, size: size),
  };

  PowerUpManager() : super() {
    _respawnTimer = Timer(5, onTick: _spawnPowerUp, repeat: true);
    _freezeTimer = Timer(2, onTick: () {
      _respawnTimer.start();
    });
  }

  void _spawnPowerUp() {
    Vector2 initialSize = Vector2(64, 64);
    Vector2 position = Vector2(
      random.nextDouble() * this.gameRef.size.x,
      random.nextDouble() * this.gameRef.size.y,
    );

    position.clamp(
        Vector2.zero() + initialSize / 2, this.gameRef.size - initialSize / 2);

    int randomIndex = random.nextInt(PowerUpTypes.values.length);
    final fn = _powerUpMap[PowerUpTypes.values.elementAt(randomIndex)];
    var powerUp = fn?.call(position, initialSize, gameRef);
    powerUp?.anchor = Anchor.center;
    if (powerUp != null) {
      gameRef.add(powerUp);
    }
  }

  @override
  void onMount() {
    _respawnTimer.start();

    healthSprite = Sprite(gameRef.images.fromCache('health.png'));
    nukeSprite = Sprite(gameRef.images.fromCache('nuke.png'));
    freezeSprite = Sprite(gameRef.images.fromCache('freeze.png'));
    multiFireSprite = Sprite(gameRef.images.fromCache('multi_fire.png'));
    super.onMount();
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
    _respawnTimer.stop();
    _respawnTimer.start();
  }

  void freeze() {
    _respawnTimer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
