import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:open_settings/open_settings.dart';

import 'fault_alert.dart';
import 'fault_data.dart';
import 'meters.dart';
import 'vc_data.dart'; // Import FaultCategory enum

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  runApp(GaugeApp(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin));
}

class GaugeApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const GaugeApp({Key? key, required this.flutterLocalNotificationsPlugin}) : super(key: key);

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
                  home: MyHomePage(
                    flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
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

class MyHomePage extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const MyHomePage({Key? key, required this.flutterLocalNotificationsPlugin}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FlutterBlue flutterBlue;
  late BluetoothDevice targetDevice;
  StreamSubscription? valueSubscription;
  StreamSubscription? scanSubscription;
  bool _isMounted = false;

  int _selectedIndex = 0;
  double voltageValue = 120.0;
  double currentValue = 30.0;
  String source = 'Source: A';
  Fault faultData =
      Fault(type: FaultType.lineToLine, category: FaultCategory.category1, timestamp: DateTime.now());

  @override
  void initState() {
    super.initState();
    flutterBlue = FlutterBlue.instance;
    _isMounted = true;
    // Initialize local notifications plugin
    requestNotificationPermissions();
    _connectToDevice();
  }

  Future<void> requestNotificationPermissions() async {
    final PermissionStatus status = await Permission.notification.request();
    if (!status.isGranted) {
      // Handle permission denied scenario
      // You can display a dialog or a message to inform the user
    }
  }

  // Function to show local notification
  Future<void> showFaultNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'fault_channel_id', 
      'Fault Notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await widget.flutterLocalNotificationsPlugin.show(
      0,
      'Fault Detected',
      'A fault has occurred. Check the fault data for details.',
      platformChannelSpecifics,
      payload: 'Fault Notification',
    );
  }

  Future<void> _connectToDeviceAndReadData(BluetoothDevice device) async {
    try {
      await device.connect();
      List<BluetoothService> services = await device.discoverServices();
      // Handle discovered services and characteristics here
      // This is where you would find the characteristic to read data
    } catch (e) {
      print('Error connecting to device: $e');
      // Handle connection error
    }
  }

  Future<void> _connectToDevice() async {
    // Request Bluetooth permission
    final PermissionStatus bluetoothStatus = await Permission.bluetooth.request();
    if (!bluetoothStatus.isGranted) {
      // Handle permission denied scenario
      // You can display a dialog or a message to inform the user
      return;
    }

    final bool bluetoothEnabled = await flutterBlue.isOn;
    if (!bluetoothEnabled) {
      // Bluetooth is not turned on, prompt user to turn it on
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Bluetooth is turned off'),
            content: const Text('Please turn on Bluetooth to connect to the device.'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  // Open Bluetooth settings using open_settings package
                  OpenSettings.openBluetoothSetting();
                },
                child: const Text('Turn On'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Scan for devices
    scanSubscription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name == 'Device Name') {
        targetDevice = scanResult.device;
        scanSubscription?.cancel(); // Stop scanning
        _connectToDeviceAndReadData(targetDevice);
      }
    }, onError: (e) {
      print('Error scanning for devices: $e');
    });
  }

  @override
  void dispose() {
    scanSubscription?.cancel(); // Cancel scanning when the widget is disposed
    valueSubscription?.cancel();
    _isMounted = false;
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color _getAppBarColor(ThemeMode themeMode) {
    return themeMode == ThemeMode.light ? Colors.blue : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<ThemeNotifier>(context).getThemeMode();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _getAppBarColor(themeMode),
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Voltage & Current Display',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.color_lens, color: Colors.white),
              onPressed: () {
                Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
              },
              tooltip: 'Change Theme',
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Meters(voltageValue: voltageValue, currentValue: currentValue, faultData: faultData, source: source),
          SavedData(),
          FaultData(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt),
            label: 'Voltage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Save Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Fault Data',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  late ThemeMode _themeMode;

  ThemeNotifier(this._themeMode);

  ThemeMode getThemeMode() => _themeMode;

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }
}

