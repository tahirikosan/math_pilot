import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:math_pilot/game/object/bullet.dart';
import 'package:math_pilot/game/object/earth.dart';
import 'package:math_pilot/game/object/enemy/enemy.dart';
import 'package:math_pilot/game/object/enemy/enemy_manager.dart';
import 'package:math_pilot/game/object/power_up/power_up_manager.dart';
import 'package:math_pilot/game/object/power_up/powerup.dart';
import 'package:math_pilot/game/player.dart';
import 'package:math_pilot/game/widgets/custom_button.dart';
import 'package:math_pilot/game/widgets/hud_health_component.dart';
import 'package:math_pilot/game/widgets/hud_math_generator.dart';
import 'package:math_pilot/game/widgets/overlays/game_over_menu.dart';
import 'package:math_pilot/game/widgets/overlays/pause_button.dart';
import 'package:math_pilot/game/widgets/overlays/pause_menu.dart';
import 'package:math_pilot/models/player_data.dart';
import 'package:math_pilot/models/spaceship_details.dart';
import 'package:math_pilot/util/audio_player_component.dart';
import 'package:math_pilot/util/command.dart';
import 'package:math_pilot/util/fonts.dart';
import 'package:math_pilot/util/knows_game_size.dart';
import 'package:provider/provider.dart';

// This class is responsible for initalizing and running the game-loop.
class SpaceGame extends FlameGame
    with HasCollidables, HasDraggables, HasTappables {
  // Stores a reference to player component.
  late Player _player;
  Player get player => _player;
  late PlayerData _playerData;
  // Store a reference to earh component.
  late Earth _earth;
  // Global Joystick for player movement
  late JoystickComponent joystickMovement;
  late CustomButton btnShoot;
  late EnemyManager _enemyManager;
  late PowerUpManager _powerUpManager;

  late SpriteSheet spriteSheet;
  final int ID_SPRITE_BULLET = 28;

  // Shows user score
  late TextComponent _playerScore;
  // Shows user health with background
  late HudHealthComponent _playerHealthHud;
  // Shows earth health with background
  late HudHealthComponent _earthHealthHud;
  // Shows Mathmatic panel
  late HudMathGenerator _hudMathGenerator;

  // Handle game audio
  late AudioPlayerComponent _audioPlayerComponent;

  // Command Lists for actions
  final _commandList = List<Command>.empty(growable: true);
  final _addLaterCommandList = List<Command>.empty(growable: true);

  // to dont load game multiple times
  bool _isAlreadyLoaded = false;

  // This method gets called by Flame before the game-loop begins.
  // Assets loading and adding component should be done here.
  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (!_isAlreadyLoaded) {
      await images.loadAll([
        'simpleSpace_tilesheet@2.png',
        'joystick_bg.png',
        'joystick_knob.png',
        'btn_shoot.png',
        'freeze.png',
        'health.png',
        'multi_fire.png',
        'nuke.png',
        Earth.EARHT_IMAGE,
      ]);

      ParallaxComponent _stars = await ParallaxComponent.load(
        [
          ParallaxImageData('stars1.png'),
          ParallaxImageData('stars2.png'),
        ],
        repeat: ImageRepeat.repeat,
        baseVelocity: Vector2(0, -50),
        velocityMultiplierDelta: Vector2(0, 1.5),
      );
      add(_stars);

      spriteSheet = SpriteSheet.fromColumnsAndRows(
        image: images.fromCache('simpleSpace_tilesheet@2.png'),
        columns: 8,
        rows: 6,
      );

      _audioPlayerComponent = AudioPlayerComponent();
      add(_audioPlayerComponent);

      //Prepare initial data for eath
      setEarth();
      // Prepare initial data for player
      setPlayer();

      _enemyManager = EnemyManager(spriteSheet: spriteSheet);
      add(_enemyManager);

      _powerUpManager = PowerUpManager();
      add(_powerUpManager);

      // Set game hud components
      setHudComponents();

      // set it to true for prevent multiple loading data
      _isAlreadyLoaded = true;
    }
  }

  @override
  void onAttach() {
    if (buildContext != null) {
      _playerData = Provider.of<PlayerData>(buildContext!, listen: false);
      player.setSpaceshipType(_playerData.spaceshipType);
    }
    // Call Player's onAttach metod to initalize PlayerData variable inside it.
    player.onAttach();
    _audioPlayerComponent
        .playBacgroundMusic(AudioPlayerComponent.audioNameBackgroundMusic);
    super.onAttach();
  }

  @override
  void onDetach() {
    _audioPlayerComponent.stopBackgroundMusic();
    super.onDetach();
  }

  @override
  void prepare(Component parent) {
    super.prepare(parent);
    if (parent is KnowsGameSize) {
      parent.onResize(this.size);
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    this.children.whereType<KnowsGameSize>().forEach((component) {
      component.onResize(this.size);
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    _commandList.forEach((command) {
      children.forEach((component) {
        command.run(component);
      });
    });
    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();

    _playerScore.text = 'Score: ${_player.score}';
    _playerHealthHud.setHealth('Player', _player.health);
    _earthHealthHud.setHealth('Earth', _earth.health);

    checkIfGameOver();
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (this.player.health > 0) {
          this.pauseEngine();
          this.overlays.remove(PauseButton.ID);
          this.overlays.add(PauseMenu.ID);
        }
        break;
    }
    super.lifecycleStateChange(state);
  }

  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  // Check if game is over.
  void checkIfGameOver() {
    // Show game over
    if ((player.health <= 0 || _earth.health <= 0) && !camera.shaking) {
      // Check if score is highScore.
      _playerData.saveHighscore();
      this.pauseEngine();
      this.overlays.add(GameOverMenu.ID);
      this.overlays.remove(PauseButton.ID);
    }
  }

  // Pauses game
  void pauseGame() {
    pauseEngine();
    // Check if score is highScore.
    _playerData.saveHighscore();
  }

  void reset() {
    _player.reset();
    _enemyManager.reset();
    _powerUpManager.reset();
    _hudMathGenerator.resetMathEquation();
    _earth.reset();
    removeAll(children.whereType<Bullet>());
    removeAll(children.whereType<Enemy>());
    removeAll(children.whereType<PowerUp>());
    _isAlreadyLoaded = false;
  }

  // Set player initial data
  void setPlayer() {
    final spaceshipType = SpaceshipType.Canary;
    final spaceShip = Spaceship.getSpaceshipType(spaceshipType);
    _player = Player(
      spaceshipType: spaceshipType,
      sprite: spriteSheet.getSpriteById(spaceShip.spriteId),
      size: Vector2(64, 64),
      position: canvasSize / 2,
    );
    _player.anchor = Anchor.center;
    add(_player);
  }

  // Set earth initial data.
  void setEarth() {
    _earth = Earth(
      sprite: Sprite(images.fromCache(Earth.EARHT_IMAGE)),
      size: Vector2.all(256),
      position: Vector2(this.size.x / 2, this.size.y + 24),
    );
    _earth.anchor = Anchor.center;
    _earth.add(RotateEffect.by(
        2 * pi, EffectController(duration: 20, infinite: true)));
    _earth.positionType = PositionType.viewport;
    add(_earth);
  }

  // Sets game hud components
  void setHudComponents() {
    // Set joysctick
    joystickMovement = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('joystick_knob.png'),
        ),
        size: Vector2.all(64),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('joystick_bg.png'),
        ),
        size: Vector2.all(128),
      ),
      position: Vector2(96, size.y - 96),
    );
    joystickMovement.positionType = PositionType.viewport;
    add(joystickMovement);

    // Set shoot button sprite
    Sprite btnShootSprite = Sprite(images.fromCache('btn_shoot.png'));
    btnShoot = CustomButton(
      sprite: btnShootSprite,
      position: Vector2(size.x - 96, size.y - 128),
      size: Vector2(64, 64),
      myOnTapDown: (info) {
        player.shoot();
      },
    );
    btnShoot.positionType = PositionType.viewport;
    add(btnShoot);

    // Set Hud playerScore
    _playerScore = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 10),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: MyFonts.bungeeInline,
        ),
      ),
    );
    // To avoid shake effect on text, we make it hud element.
    _playerScore.positionType = PositionType.viewport;
    add(_playerScore);

    // Set Hud playerHealth
    _playerHealthHud = HudHealthComponent(
      maxHealth: Player.MAX_HEALTH,
      position: Vector2(size.x - 110, 5),
    );
    // To avoid shake effect on text, we make it hud element.
    _playerHealthHud.positionType = PositionType.viewport;
    add(_playerHealthHud);

    // Set Hud earthHealth
    _earthHealthHud = HudHealthComponent(
      maxHealth: Earth.MAX_HEALTH,
      position: Vector2(size.x - 110, 35),
    );
    _earthHealthHud.positionType = PositionType.viewport;
    add(_earthHealthHud);

    // Set math generator hud
    _hudMathGenerator = HudMathGenerator(
      position: Vector2((size.x / 2), 64),
    );
    _hudMathGenerator.positionType = PositionType.viewport;
    _hudMathGenerator.anchor = Anchor.center;
    add(_hudMathGenerator);
  }
}
