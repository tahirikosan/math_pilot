import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:math_pilot/models/player_data.dart';
import 'package:math_pilot/models/spaceship_details.dart';
import 'package:math_pilot/screens/main_menu.dart';
import 'package:provider/provider.dart';

import 'game_play.dart';

class SelectSpaceship extends StatelessWidget {
  const SelectSpaceship({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: Text(
                "Select",
                style: TextStyle(color: Colors.black, fontSize: 50.0, shadows: [
                  Shadow(
                    blurRadius: 20.0,
                    color: Colors.blue,
                    offset: Offset(0, 0),
                  ),
                ]),
              ),
            ),

            Consumer<PlayerData>(builder: (context, playerData, child) {
              final spaceship =
                  Spaceship.getSpaceshipType(playerData.spaceshipType);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Ship: ${spaceship.name}"),
                  Text("Money: ${playerData.money}"),
                ],
              );
            }),

            // Ship selection Carousel
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: CarouselSlider.builder(
                itemCount: Spaceship.spaceships.length,
                slideBuilder: (index) {
                  final spaceship =
                      Spaceship.spaceships.entries.elementAt(index).value;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 18,
                              color: spaceship.color.withAlpha(200),
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Image.asset(spaceship.assetPath),
                      ),
                      Text("${spaceship.name}"),
                      Text("Speed: ${spaceship.speed}"),
                      Text("Level: ${spaceship.level}"),
                      Text("Cost: ${spaceship.cost}"),
                      Consumer<PlayerData>(
                        builder: (context, playerData, child) {
                          final type =
                              Spaceship.spaceships.entries.elementAt(index).key;
                          final isEquipped = playerData.isEquipped(type);
                          final isOwned = playerData.isOwned(type);
                          final canBuy = playerData.canBuy(type);
                          return ElevatedButton(
                            onPressed: isEquipped
                                ? null
                                : () {
                                    if (isOwned) {
                                      playerData.equip(type);
                                    } else {
                                      if (canBuy) {
                                        playerData.buy(type);
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.red,
                                                title: Text(
                                                  "Insufficient Balance",
                                                  textAlign: TextAlign.center,
                                                ),
                                                content: Text(
                                                  "Need ${spaceship.cost - playerData.money} more",
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            });
                                      }
                                    }
                                  },
                            child: Text(
                              isEquipped
                                  ? "Equipped"
                                  : isOwned
                                      ? "Select"
                                      : "Buy",
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // Start Button
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => GamePlay(),
                    ),
                  );
                },
                child: Text("Start"),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainMenu(),
                    ),
                  );
                },
                child: Icon(Icons.arrow_back_ios_new_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
