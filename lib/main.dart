import 'package:flutter/material.dart';
import 'vibration_service.dart';
import 'sensor_service.dart';
import 'microphone_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2, // Number of tabs
        child: Scaffold(
          appBar: AppBar(
            title: const Text('FBD Logger'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Vibration'),
                Tab(text: 'Sound'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              HomeScreen(), // Content of the HomeScreen tab
              SecondScreen(), // Content of the SecondScreen tab
            ],
          ),
        ),
      ),
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
  void initState() async {
    super.initState();
    _amplitudeController.text = '255';
    _durationController.text = '900';
    _silenceDurationController.text = '100';
    _repeatTimeController.text = '5';
    _samplingPeriodController.text = '5';
    _nameController.text = 'test_vibration';
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const InputDecoration(labelText: 'Vibration Duration (ms)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _silenceDurationController,
              decoration:
                  const InputDecoration(labelText: 'Silence Duration (ms)'),
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
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                int? amplitude = int.tryParse(_amplitudeController.text);
                int? durationInMsec = int.tryParse(_durationController.text);
                int? silenceDurationInMsec =
                    int.tryParse(_silenceDurationController.text);
                int? repeatTime = int.tryParse(_repeatTimeController.text);
                String fileName =
                    '${_nameController.text}_${DateTime.now().toIso8601String()}';
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

                await Future.delayed(const Duration(seconds: 1));
                VibrationService(context).startVibration(
                  amplitude: amplitude,
                  durationInMsec: durationInMsec,
                  silenceDurationInMsec: silenceDurationInMsec,
                  repeatTime: repeatTime,
                );

                final sensorService = SensorService(context);
                final microphoneService = MicrophoneService(context, fileName);
                sensorService.startListening(samplingPeriod: samplingPeriod);
                microphoneService.startListening();
                await Future.delayed(Duration(
                    milliseconds:
                        (durationInMsec + silenceDurationInMsec) * repeatTime));
                sensorService.stopListening(
                    fileName: fileName, batchSize: 1000);
                microphoneService.stopListening();
              },
              child: const Text('Start Vibration'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final _frequencyController = TextEditingController();
  final _endFrequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _repeatTimeController = TextEditingController();
  final _nameController = TextEditingController();
  final _samplingPeriodController = TextEditingController();
  String _selectedItem = 'Fixed';

  @override
  void initState() {
    super.initState();
    _frequencyController.text = '500';
    _endFrequencyController.text = '1000';
    _durationController.text = '1000';
    _repeatTimeController.text = '5';
    _samplingPeriodController.text = '5';
    _nameController.text = 'test_sound';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: _selectedItem,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItem = newValue!;
                });
              },
              items: <String>['Fixed', 'Chirp']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _frequencyController,
              decoration: const InputDecoration(
                  labelText: 'Frequency / Start Frequency (Hz)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _endFrequencyController,
              decoration: const InputDecoration(
                  labelText: 'End Frequency (Hz, only for Chirp)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (ms)'),
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
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {},
              child: const Text('Start Playing Sound'),
            ),
          ],
        ),
      ),
    );
  }
}
