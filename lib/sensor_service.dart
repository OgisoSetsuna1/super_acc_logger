import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path_provider/path_provider.dart';

class SensorService {
  final BuildContext context;

  SensorService(this.context);

  List<List<String>> data = [];
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

  void stopListening({String fileName = '', int batchSize = 1000}) {
    _subscription?.cancel();
    _writeToFile(fileName, batchSize);
  }

  Future<void> _writeToFile(String fileName, int batchSize) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      _showSnackBar('Failed when saving accelerometer data!');
      return;
    }
    final filePath = '${directory.path}/$fileName.csv';
    final file = File(filePath);
    final List<String> header = ['timestamp', 'X', 'Y', 'Z'];
    var batch = <List<dynamic>>[];

    await file.writeAsString('${header.join(',')}\n',
        mode: FileMode.writeOnlyAppend);

    for (var row in data) {
      batch.add(row);
      if (batch.length == batchSize) {
        await file.writeAsString(
          '${batch.map((row) => row.join(',')).join('\n')}\n',
          mode: FileMode.writeOnlyAppend,
        );
        batch.clear();
      }
    }

    if (batch.isNotEmpty) {
      await file.writeAsString(
        '${batch.map((row) => row.join(',')).join('\n')}\n',
        mode: FileMode.writeOnlyAppend,
      );
    }

    _showSnackBar('Accelerometer data has been saved to: $filePath');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }
}
