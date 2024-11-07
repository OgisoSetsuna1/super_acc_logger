import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final BuildContext context;
  final int sampleRate = 44100;

  AudioService(this.context);

  Future<String?> generateAudio(String type, int startFrequency,
      int endFrequency, int duration, int repeatTime) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      _showSnackBar('Failed when saving microphone data!');
      return null;
    }
    final List<double> waveForm = [];

    if (type == 'fixed') {
      final int numSamples = (sampleRate * duration * repeatTime).toInt();
      for (int i = 0; i < numSamples; i++) {
        final double time = i / sampleRate;
        final double angle = 2 * pi * startFrequency * time;
        waveForm.add(sin(angle));
      }

      final Uint8List pcmData =
          Float32List.fromList(waveForm).buffer.asUint8List();

      final String filePath =
          '$directory/tmp/fixed_${startFrequency}_${duration * repeatTime}.pcm';
      final File file = File(filePath);
      file.writeAsBytesSync(pcmData);

      return filePath;
    } else if (type == 'chirp') {
      final List<double> singleWaveForm = [];
      final int numSamples = (sampleRate * duration).toInt();
      for (int i = 0; i < numSamples; i++) {
        final double time = i / sampleRate;
        final double frequency =
            startFrequency + (endFrequency - startFrequency) * time / duration;
        final double angle = 2 * pi * frequency * time;
        singleWaveForm.add(sin(angle));
      }

      for (int i = 0; i < 5; i++) {
        waveForm.addAll(singleWaveForm); // 添加后续4次chirp
      }

      final Uint8List pcmData =
          Float32List.fromList(waveForm).buffer.asUint8List();

      final String filePath =
          '$directory/tmp/chirp_${startFrequency}_${endFrequency}_${duration}_$repeatTime.pcm';
      final File file = File(filePath);
      file.writeAsBytesSync(pcmData);

      return filePath;
    }
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }
}
