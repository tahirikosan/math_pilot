import 'package:flutter/material.dart';
import 'package:math_pilot/models/settings.dart';
import 'package:provider/provider.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({Key? key}) : super(key: key);

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
                "Settings",
                style: TextStyle(color: Colors.black, fontSize: 50.0, shadows: [
                  Shadow(
                    blurRadius: 20.0,
                    color: Colors.blue,
                    offset: Offset(0, 0),
                  ),
                ]),
              ),
            ),
            Selector<Settings, bool>(
                selector: (context, settings) => settings.soundEffects,
                builder: (context, value, child) {
                  return SwitchListTile(
                      title: Text("Sound Effects"),
                      value: value,
                      onChanged: (newValue) {
                        Provider.of<Settings>(context, listen: false)
                            .soundEffects = newValue;
                      });
                }),
            Selector<Settings, bool>(
                selector: (context, settings) => settings.backgroundMusic,
                builder: (context, value, child) {
                  return SwitchListTile(
                      title: Text("Background Music"),
                      value: value,
                      onChanged: (newValue) {
                        Provider.of<Settings>(context, listen: false)
                            .backgroundMusic = newValue;
                      });
                }),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
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
