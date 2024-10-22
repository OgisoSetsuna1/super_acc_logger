import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class VibrationService {
  final BuildContext context;

  VibrationService(this.context);

  void startVibration({
    int? amplitude = 255,
    int? duration_in_sec = 5,
  }) {
    if (Vibration.hasVibrator() == false) {
      _showSnackBar('This device has no viberator!');
      return;
    }
    if (amplitude == null ||
        duration_in_sec == null ||
        amplitude < 1 ||
        amplitude > 255 ||
        duration_in_sec < 1) {
      _showSnackBar('Wrong parameters!');
      return;
    }
    if (Vibration.hasAmplitudeControl() == false ||
        Vibration.hasCustomVibrationsSupport() == false) {
      _showSnackBar(
          'Vibration has started but parameters of this vibrator can\'t be adjusted!');
    } else {
      _showSnackBar('Vibration has started!');
    }

    Vibration.vibrate(duration: duration_in_sec * 1000, amplitude: amplitude);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }
}
