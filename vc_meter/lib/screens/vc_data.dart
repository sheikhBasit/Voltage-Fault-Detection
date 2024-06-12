import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataPoint {
  final double voltage;
  final double current;
  final String source;
  final DateTime timestamp;

  DataPoint(this.source, {required this.current, required this.voltage, required this.timestamp});
}

class SavedData extends StatefulWidget {
  @override
  _SavedDataState createState() => _SavedDataState();
}

class _SavedDataState extends State<SavedData> {
  final List<DataPoint?> dataBuffer = List.filled(10, null);
  int currentIndex = 0;

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    generateData();
  }

  // Initialize SharedPreferences
  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    loadLastData();
  }

  // Load last saved data from SharedPreferences
  void loadLastData() {
    for (int i = 0; i < dataBuffer.length; i++) {
      final double? voltageValue = prefs.getDouble('voltage_$i');
      final double? currentValue = prefs.getDouble('current_$i');
      const sourceName = 'soruce';
      final int? timestampMillis = prefs.getInt('timestamp_$i');
      if (voltageValue != null && currentValue != null && timestampMillis != null) {
        final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
        dataBuffer[i] = DataPoint(sourceName,voltage: voltageValue, current: currentValue, timestamp: timestamp);
      }
    }
    setState(() {});
  }

  // Save data to SharedPreferences
  void saveData() {
    for (int i = 0; i < dataBuffer.length; i++) {
      final DataPoint? dataPoint = dataBuffer[i];
      if (dataPoint != null) {
        prefs.setDouble('voltage_$i', dataPoint.voltage);
        prefs.setDouble('current_$i', dataPoint.current);
        prefs.setInt('timestamp_$i', dataPoint.timestamp.millisecondsSinceEpoch);
      }
    }
  }

  void generateData() {
  Timer.periodic(const Duration(seconds: 10), (timer) {
    final newVoltage = generateRandomValue();
    final newCurrent = generateRandomValue();
    final newSource = 'source';
    final currentTime = DateTime.now();
    dataBuffer[currentIndex] = DataPoint(newSource, voltage: newVoltage, current: newCurrent, timestamp: currentTime);
    currentIndex = (currentIndex + 1) % 10;
    setState(() {});
    saveData(); // Save data after generating new value
  });
}

double generateRandomValue() {
  // Generate a random double value between 0 and 100
  final randomValue = Random().nextDouble() * 100;
  return randomValue;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Source: source',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            const Text(
              'Last 10 Minutes Data:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: dataBuffer.length,
                itemBuilder: (context, index) {
                  final dataPoint = dataBuffer[index];
                  if (dataPoint != null) {
                    return ListTile(
                      title: Text(
                        'Voltage: ${dataPoint.voltage.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16
                        ,fontFamily: 'Nunito'
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current: ${dataPoint.current.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14
                        ,fontFamily: 'Nunito'
                            ),
                            
                          ),
                          Text(
                            'Time: ${dataPoint.timestamp.hour}:${dataPoint.timestamp.minute}:${dataPoint.timestamp.second}',
                            style: const TextStyle(fontSize: 14
                        ,fontFamily: 'Nunito'
                            ),
                          ),
                        ],
                      ),
                      leading: const Icon(
                        Icons.data_usage,
                        color: Colors.blue,
                        size: 30,
                      ),
                      trailing: const Icon(
                        Icons.access_time,
                        color: Colors.blue,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      onTap: () {
                        // Handle onTap event if needed
                      },
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    saveData(); // Save data when the app is closed
  }
}
