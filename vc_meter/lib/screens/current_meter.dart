import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CurrentPage extends StatelessWidget {
  final double value;
  final bool hasFault;

  const CurrentPage({Key? key, required this.value, required this.hasFault}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.6, // Adjust width according to screen size
            height: MediaQuery.of(context).size.width * 0.6, // Maintain aspect ratio
            child: SfRadialGauge(
              title: const GaugeTitle(
                text: 'Current Meter',
                textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold
                        ,fontFamily: 'Nunito'
                ),
              ),
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 50,
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 20,
                      color: Colors.green,
                      startWidth: 10,
                      endWidth: 10,
                    ),
                    GaugeRange(
                      startValue: 20,
                      endValue: 40,
                      color: Colors.orange,
                      startWidth: 10,
                      endWidth: 10,
                    ),
                    GaugeRange(
                      startValue: 40,
                      endValue: 50,
                      color: Colors.red,
                      startWidth: 10,
                      endWidth: 10,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: value,
                      needleLength: 0.8,
                      needleColor: hasFault ? Colors.red : Colors.blue, // Change needle color if there's a fault
                      enableAnimation: true,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Container(
                        child: Text(
                          value.toString(),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold
                        ,fontFamily: 'Nunito'
                          ),
                        ),
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        
        ],
      ),
    );
  }
}