import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:math_pilot/models/math_equation_data.dart';
import 'package:math_pilot/models/player_data.dart';
import 'package:math_pilot/models/settings.dart';
import 'package:math_pilot/models/spaceship_details.dart';
import 'package:math_pilot/screens/main_menu.dart';
import 'package:math_pilot/screens/splash_screen.dart';
import 'package:math_pilot/util/fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Opens the app in full screen mode.
  await Flame.device.fullScreen();

  //Initialize firebase
  await Firebase.initializeApp();

  // First initialize hive
  await initHive();

  runApp(MultiProvider(
    providers: [
      FutureProvider<PlayerData>(
        create: (BuildContext context) => getPlayerData(),
        initialData: PlayerData.fromMap(PlayerData.defaultData),
      ),
      FutureProvider<Settings>(
        create: (BuildContext context) => getSettings(),
        initialData: Settings(soundEffects: false, backgroundMusic: false),
      )
    ],
    builder: (context, child) {
      // We use .value constructor because the required PlayerData object is already created by upstream FutureProvider
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<PlayerData>.value(
            value: Provider.of<PlayerData>(context),
            child: child,
          ),
          ChangeNotifierProvider<Settings>.value(
            value: Provider.of<Settings>(context),
            child: child,
          ),
          ChangeNotifierProvider<MathEquationData>(
            create: (context) => MathEquationData.defaultData(),
            child: child,
          ),
          StreamProvider.value(
            value: FirebaseAuth.instance.authStateChanges(),
            initialData: null,
          )
        ],
        child: child,
      );
    },
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      // Dark mode because we are too cool for white theme ;)
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: MyFonts.bungeeInline,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MainMenu(),
    ),
  ));
}

Future<void> initHive() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  Hive.registerAdapter(PlayerDataAdapter());
  Hive.registerAdapter(SpaceshipTypeAdapter());
  Hive.registerAdapter(SettingsAdapter());
}

Future<PlayerData> getPlayerData() async {
  final box = await Hive.openBox<PlayerData>(PlayerData.PLAYER_DATA_BOX);
  final playerData = box.get(PlayerData.PLAYER_DATA_KEY);
  if (playerData == null) {
    box.put(
        PlayerData.PLAYER_DATA_KEY, PlayerData.fromMap(PlayerData.defaultData));
  }
  return box.get(PlayerData.PLAYER_DATA_KEY)!;
}

Future<Settings> getSettings() async {
  final box = await Hive.openBox<Settings>(Settings.SETTINGS_B0X);
  final playerData = box.get(Settings.SETTINGS_KEY);

  if (playerData == null) {
    box.put(Settings.SETTINGS_KEY,
        Settings(soundEffects: true, backgroundMusic: true));
  }

  return box.get(Settings.SETTINGS_KEY)!;
}
