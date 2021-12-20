import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:math_pilot/models/spaceship_details.dart';

part 'player_data.g.dart';

@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  static const String PLAYER_DATA_BOX = "PlayerDataBox";
  static const String PLAYER_DATA_KEY = "PlayerData";

  @HiveField(0)
  SpaceshipType spaceshipType;
  @HiveField(1)
  final List<SpaceshipType> ownedSpaceships;
  @HiveField(2)
  int highScore;
  @HiveField(3)
  int money;
  int currentScore = 0;

  PlayerData({
    required this.spaceshipType,
    required this.ownedSpaceships,
    required this.highScore,
    required this.money,
  });

  PlayerData.fromMap(Map<String, dynamic> map)
      : this.spaceshipType = map["currentSpaceshipType"],
        this.ownedSpaceships = map["ownedSpaceshipTypes"]
            .map((e) => e as SpaceshipType)
            .cast<SpaceshipType>()
            .toList(),
        this.highScore = map["highScore"],
        this.money = map["money"];

  static Map<String, dynamic> defaultData = {
    "currentSpaceshipType": SpaceshipType.Canary,
    "ownedSpaceshipTypes": [],
    "highScore": 0,
    "money": 500,
  };

  bool isOwned(SpaceshipType spaceshipType) {
    return this.ownedSpaceships.contains(spaceshipType);
  }

  bool canBuy(SpaceshipType spaceshipType) {
    return (this.money >= Spaceship.getSpaceshipType(spaceshipType).cost);
  }

  bool isEquipped(SpaceshipType spaceshipType) {
    return this.spaceshipType == spaceshipType;
  }

  void buy(SpaceshipType spaceshipType) {
    if (canBuy(spaceshipType) && !isOwned(spaceshipType)) {
      this.money -= Spaceship.getSpaceshipType(spaceshipType).cost;
      ownedSpaceships.add(spaceshipType);
      notifyListeners();
      this.save();
    }
  }

  void equip(SpaceshipType spaceshipType) {
    this.spaceshipType = spaceshipType;
    notifyListeners();
    this.save();
  }

  //Check current score and set highscore or not.
  void saveHighscore() {
    if (currentScore > highScore) {
      highScore = currentScore;
      notifyListeners();
      this.save();
    }
  }
}
