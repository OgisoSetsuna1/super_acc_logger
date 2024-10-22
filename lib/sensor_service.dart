import 'dart:async';
import 'dart:io';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:csv/csv.dart';

class SensorService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  void startListeningAndWriting(String filePath) {
    accelerometerEventStream(samplingPeriod: const Duration(milliseconds: 100))
        .listen(
      (AccelerometerEvent event) {
        _writeToCsv(event, filePath);
      },
    );
  }

  Future<void> _writeToCsv(AccelerometerEvent event, String filePath) async {
    final List<List<dynamic>> data = [
      [event.x, event.y, event.z]
    ];

    final String csv = const ListToCsvConverter().convert(data);

    final File file = File(filePath);
    await file.writeAsString(csv, mode: FileMode.append);
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }
}
