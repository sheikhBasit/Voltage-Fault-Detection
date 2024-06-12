import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:vc_meter/screens/fault_alert.dart';


class FaultData extends StatefulWidget {
  @override
  _FaultDataState createState() => _FaultDataState();
}

class _FaultDataState extends State<FaultData> {
  late SharedPreferences prefs;
  Fault? lastFault;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  // Initialize SharedPreferences
  void initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    loadLastFaultFromSharedPreferences();
  }

  // Load last saved fault from SharedPreferences
  void loadLastFaultFromSharedPreferences() {
    // Load last fault occurrence
    final int? faultTimestampMillis = prefs.getInt('last_fault_timestamp');
    if (faultTimestampMillis != null) {
      final FaultType type = FaultType.values[prefs.getInt('last_fault_type') ?? 0];
      final FaultCategory category = FaultCategory.values[prefs.getInt('last_fault_category') ?? 0];
      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(faultTimestampMillis);
      setState(() {
        lastFault = Fault(type: type, category: category, timestamp: timestamp);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fault Data Recorder', style: TextStyle(fontFamily: 'Nunito'
),
            ),      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),

            const Text(
              'Last Fault:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20
                        ,fontFamily: 'Nunito'
              ),
            ),
            const SizedBox(height: 8),
            if (lastFault != null)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type: ${lastFault!.type}',
                        style: const TextStyle(fontSize: 16
                        ,fontFamily: 'Nunito'
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Category: ${lastFault!.category}',
                        style: const TextStyle(fontSize: 16
                        ,fontFamily: 'Nunito'
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(lastFault!.timestamp)}',
                        style: const TextStyle(fontSize: 16
                        ,fontFamily: 'Nunito'
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
