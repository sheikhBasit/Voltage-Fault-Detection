import 'package:flutter/material.dart';
import 'package:vc_meter/screens/current_meter.dart';
import 'package:vc_meter/screens/fault_alert.dart';
import 'package:vc_meter/screens/voltage_meter.dart';

class Meters extends StatelessWidget {
  final double voltageValue;
  final double currentValue;
  final Fault? faultData;
  final String? source;

  const Meters({Key? key, required this.voltageValue, required this.currentValue, required this.faultData, required this.source}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.03,),
          Text('Source: $source',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 68, 230)
                          ,fontFamily: 'Nunito'
      
          ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height*0.03,),
      
          VoltagePage(value: voltageValue, hasFault: faultData != null),
          SizedBox(height: MediaQuery.of(context).size.height*0.03,),
      
          CurrentPage(value: currentValue, hasFault: faultData != null),
          if (faultData != null && !faultData!.isNone)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fault Detected:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red
                          ,fontFamily: 'Nunito'
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Type:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16
                          ,fontFamily: 'Nunito'
                            ),
                          ),
                          Text(
                            '${faultData!.getTypeName()}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.red),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tower',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16
                          ,fontFamily: 'Nunito'
                            ),
                          ),
                          Text(
                            '${faultData!.getCategoryName()}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (faultData == null || faultData!.isNone)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No Fault Detected',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green
                          ,fontFamily: 'Nunito'
                ),
              ),
            ),
        ],
      ),
    );
  }
}
