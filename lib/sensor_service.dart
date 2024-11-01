import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';

class SensorService {
  final BuildContext context;

  SensorService(this.context);

  List<List<String>> data = [];
  final startTime = DateTime.now().toIso8601String();
  StreamSubscription<UserAccelerometerEvent>? _subscription;

  void startListening({int samplingPeriod = 5}) {
    _subscription = userAccelerometerEventStream(
            samplingPeriod: SensorInterval.fastestInterval)
        .listen(
      (UserAccelerometerEvent event) {
        final timestamp = DateTime.now().toIso8601String();
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
    );
  }

  void stopListening({String fileName = ''}) {
    _subscription?.cancel();
    _writeToFile(fileName: fileName);
  }

  Future<void> _writeToFile({String fileName = ''}) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      _showSnackBar('Failed when saving accelerometer data!');
      return;
    }
    final filePath = '${directory.path}/${fileName}_$startTime.csv';
    final file = File(filePath);
    final sink = file.openWrite();
    sink.write('timestamp,X,Y,Z\n');
    for (var row in data) {
      sink.writeAll(row, ',');
      sink.write('\n');
    }
    await sink.close();

    _showSnackBar('Accelerometer data has been saved to: $filePath');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }
}
