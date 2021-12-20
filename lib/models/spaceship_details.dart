import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'spaceship_details.g.dart';

class Spaceship {
  final String name;
  final int cost;
  final double speed;
  final int spriteId;
  final String assetPath;
  final int level;
  final Color color;

  const Spaceship({
    required this.name,
    required this.cost,
    required this.speed,
    required this.spriteId,
    required this.assetPath,
    required this.level,
    required this.color,
  });

  static const Map<SpaceshipType, Spaceship> spaceships = {
    SpaceshipType.Canary: Spaceship(
      name: 'Canary',
      cost: 0,
      speed: 3,
      spriteId: 0,
      assetPath: 'assets/images/ship_A.png',
      level: 1,
      color: Colors.amber,
    ),
    SpaceshipType.Dusky: Spaceship(
      name: 'Dusky',
      cost: 100,
      speed: 4,
      spriteId: 1,
      assetPath: 'assets/images/ship_B.png',
      level: 2,
      color: Colors.blue,
    ),
    SpaceshipType.Condor: Spaceship(
      name: 'Condor',
      cost: 200,
      speed: 4,
      spriteId: 2,
      assetPath: 'assets/images/ship_C.png',
      level: 2,
      color: Colors.cyan,
    ),
    SpaceshipType.CXC: Spaceship(
      name: 'CXC',
      cost: 400,
      speed: 5,
      spriteId: 3,
      assetPath: 'assets/images/ship_D.png',
      level: 3,
      color: Colors.deepOrange,
    ),
    SpaceshipType.Raptor: Spaceship(
      name: 'Raptor',
      cost: 550,
      speed: 6,
      spriteId: 4,
      assetPath: 'assets/images/ship_E.png',
      level: 3,
      color: Colors.deepPurple,
    ),
    SpaceshipType.RaptorX: Spaceship(
      name: 'Raptor-X',
      cost: 700,
      speed: 6,
      spriteId: 5,
      assetPath: 'assets/images/ship_F.png',
      level: 3,
      color: Colors.green,
    ),
    SpaceshipType.Albatross: Spaceship(
      name: 'Albatross',
      cost: 1800,
      speed: 7,
      spriteId: 6,
      assetPath: 'assets/images/ship_G.png',
      level: 4,
      color: Colors.indigo,
    ),
    SpaceshipType.DK809: Spaceship(
      name: 'DK-809',
      cost: 3000,
      speed: 8,
      spriteId: 7,
      assetPath: 'assets/images/ship_H.png',
      level: 4,
      color: Colors.yellow,
    ),
  };

  static Spaceship getSpaceshipType(SpaceshipType spaceshipType) {
    return spaceships[spaceshipType] ?? spaceships.entries.first.value;
  }
}

@HiveType(typeId: 1)
enum SpaceshipType {
  @HiveField(0)
  Canary,
  @HiveField(1)
  Dusky,
  @HiveField(2)
  Condor,
  @HiveField(3)
  CXC,
  @HiveField(4)
  Raptor,
  @HiveField(5)
  RaptorX,
  @HiveField(6)
  Albatross,
  @HiveField(7)
  DK809,
}
