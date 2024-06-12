import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:vc_meter/screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize local notifications plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  runApp(GaugeApp(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin));
}

class GaugeApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const GaugeApp({super.key, required this.flutterLocalNotificationsPlugin});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeMode>(
      future: _getThemeMode(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider<ThemeNotifier>(
            create: (_) => ThemeNotifier(snapshot.data ?? ThemeMode.light),
            child: Consumer<ThemeNotifier>(
              builder: (context, themeNotifier, _) {
                return MaterialApp(
                  
                  debugShowCheckedModeBanner: false,
                  title: 'Voltage & Current Display',
                  theme: ThemeData.light(),
                  darkTheme: ThemeData.dark(),
                  themeMode: themeNotifier.getThemeMode(),
                  home: AnimatedSplashScreen(
                    splash: Image(image: AssetImage('assets/logo/logo.png',
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.5,
                    ),
                    duration: 3000,
                    splashTransition: SplashTransition.fadeTransition,
                    backgroundColor: const Color.fromARGB(255, 36, 36, 36),
                    nextScreen: MyHomePage(
                      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<ThemeMode> _getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('isDarkMode') ?? false) ? ThemeMode.dark : ThemeMode.light;
  }
}

