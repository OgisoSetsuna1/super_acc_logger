import 'package:flutter/material.dart';
import 'vibration_service.dart';
import 'sensor_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _amplitudeController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Accelerometer Logger'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _amplitudeController,
              decoration: const InputDecoration(labelText: 'Amplitude [1-255]'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (sec)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                VibrationService(context).startVibration(
                  amplitude: int.tryParse(_amplitudeController.text),
                  durationInSec: int.tryParse(_durationController.text),
                );

                final sensorService = SensorService(context);
                sensorService.startListening();
                // TODO
              },
              child: const Text('Start Vibration'),
            ),
          ],
        ),
      ),
    );
  }
}
