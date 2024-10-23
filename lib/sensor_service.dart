import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';

class SensorService {
  final BuildContext context;

  SensorService(this.context);

  List<List<String>> data = [];
  final startTime = DateTime.now().toUtc().toString();
  StreamSubscription<AccelerometerEvent>? _subscription;

  void startListening() {
    _subscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        final timestamp = DateTime.now().toUtc().toString();
        data.add([
          timestamp,
          event.x.toString(),
          event.y.toString(),
          event.z.toString()
        ]);
      },
      onError: (error) {
        _showSnackBar('Sensor error: $error');
        _subscription?.cancel();
      },
      onDone: () {
        _writeToFile();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
  }

  Future<void> _writeToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$startTime.csv';
    final file = File(filePath);
    final sink = file.openWrite();
    sink.write('timestamp,X,Y,Z\n');
    for (var data in data) {
      sink.writeAll(data, ',');
      sink.write('\n');
    }
    await sink.close();

    _showSnackBar('Accelerometer data has been saved to: $filePath');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }
}
