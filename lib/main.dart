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
  final _silenceDurationController = TextEditingController();
  final _repeatTimeController = TextEditingController();
  final _nameController = TextEditingController();
  final _samplingPeriodController = TextEditingController();

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
              decoration:
                  const InputDecoration(labelText: 'Vibration Duration (msec)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _silenceDurationController,
              decoration:
                  const InputDecoration(labelText: 'Silence Duration (msec)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _repeatTimeController,
              decoration: const InputDecoration(labelText: 'Repeat Time'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _samplingPeriodController,
              decoration:
                  const InputDecoration(labelText: 'Sampling Period (ms)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'File Name'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                int? amplitude = int.tryParse(_amplitudeController.text);
                int? durationInMsec = int.tryParse(_durationController.text);
                int? silenceDurationInMsec =
                    int.tryParse(_silenceDurationController.text);
                int? repeatTime = int.tryParse(_repeatTimeController.text);
                String fileName = _nameController.text;
                int? samplingPeriod =
                    int.tryParse(_samplingPeriodController.text);

                if (amplitude == null ||
                    durationInMsec == null ||
                    silenceDurationInMsec == null ||
                    repeatTime == null ||
                    samplingPeriod == null ||
                    amplitude < 1 ||
                    amplitude > 255 ||
                    durationInMsec < 1 ||
                    silenceDurationInMsec < 1 ||
                    repeatTime < 1 ||
                    samplingPeriod < 1) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Wrong parameters!'),
                    duration: Duration(seconds: 2),
                  ));
                  return;
                }

                await Future.delayed(Duration(seconds: 1));
                VibrationService(context).startVibration(
                  amplitude: amplitude,
                  durationInMsec: durationInMsec,
                  silenceDurationInMsec: silenceDurationInMsec,
                  repeatTime: repeatTime,
                );

                final sensorService = SensorService(context);
                sensorService.startListening(samplingPeriod: samplingPeriod);
                await Future.delayed(Duration(milliseconds: (durationInMsec + silenceDurationInMsec) * repeatTime));
                sensorService.stopListening(fileName: fileName);
              },
              child: const Text('Start Vibration'),
            ),
          ],
        ),
      ),
    );
  }
}
