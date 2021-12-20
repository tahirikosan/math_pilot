import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:math_pilot/game/space_game.dart';
import 'package:math_pilot/models/settings.dart';
import 'package:provider/provider.dart';

class AudioPlayerComponent extends Component with HasGameRef<SpaceGame> {
  static const String audioNameBackgroundMusic = 'backgroundMusic.wav';
  static const String audioNamePlayerLaser = 'laser.ogg';
  static const String audioNamePowerUp = 'powerUp.ogg';
  static const String audioNameEnemyDestroy = 'enemyDestroy.ogg';
  static const String audioNameEngineThruster = 'engineThruster.ogg';
  @override
  Future<void>? onLoad() async {
    FlameAudio.bgm.initialize();

    await FlameAudio.audioCache.loadAll([
      audioNamePlayerLaser,
      audioNamePowerUp,
      audioNameBackgroundMusic,
      audioNameEnemyDestroy,
    ]);
    return super.onLoad();
  }

  void playBacgroundMusic(String filename) {
    if (isSettingsBgmOn()) FlameAudio.bgm.play(filename);
  }

  void playSoundEffect(String filename, double volume) {
    if (isSettingsSfxOn()) FlameAudio.play(filename, volume: volume);
  }

  void stopBackgroundMusic() {
    FlameAudio.bgm.stop();
  }

  bool isSettingsBgmOn() {
    if (gameRef.buildContext != null) {
      if (Provider.of<Settings>(gameRef.buildContext!, listen: false)
          .backgroundMusic) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool isSettingsSfxOn() {
    if (gameRef.buildContext != null) {
      if (Provider.of<Settings>(gameRef.buildContext!, listen: false)
          .soundEffects) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
