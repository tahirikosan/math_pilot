import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings extends ChangeNotifier with HiveObjectMixin {
  static const String SETTINGS_B0X = "SettingsBox";
  static const String SETTINGS_KEY = "Settings";

  @HiveField(0)
  bool _sfx = false;
  bool get soundEffects => _sfx;
  set soundEffects(bool value) {
    _sfx = value;
    notifyListeners();
    save();
  }

  @HiveField(1)
  bool _bgm = false;
  bool get backgroundMusic => _bgm;
  set backgroundMusic(bool value) {
    _bgm = value;
    notifyListeners();
    save();
  }

  Settings({
    bool soundEffects = false,
    bool backgroundMusic = false,
  })  : this._sfx = soundEffects,
        this._bgm = backgroundMusic;
}
