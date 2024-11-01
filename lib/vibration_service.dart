import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class VibrationService {
  final BuildContext context;

  VibrationService(this.context);

  void startVibration(
      {int amplitude = 255,
      int durationInMsec = 900,
      int silenceDurationInMsec = 100,
      int repeatTime = 5}) {
    if (Vibration.hasVibrator() == false) {
      _showSnackBar('This device has no viberator!');
      return;
    }
    if (Vibration.hasAmplitudeControl() == false ||
        Vibration.hasCustomVibrationsSupport() == false) {
      _showSnackBar(
          'Vibration has started but parameters of this vibrator can\'t be adjusted!');
    } else {
      _showSnackBar('Vibration has started!');
    }

    List<int> vibrationPattern = [];
    for (int i = 0; i < repeatTime; i++) {
      vibrationPattern.add(silenceDurationInMsec);
      vibrationPattern.add(durationInMsec);
    }

    Vibration.vibrate(pattern: vibrationPattern, amplitude: amplitude);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }
}
