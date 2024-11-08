import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioService {
  final BuildContext context;
  final int sampleRate = 44100;
  final FlutterSoundPlayer player = FlutterSoundPlayer();

  AudioService(this.context);

  Future<String?> generateAudio(String type, int startFrequency,
      int endFrequency, int duration, int repeatTime) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      _showSnackBar('Failed when saving microphone data!');
      return null;
    }
    final Directory audioDir = Directory('${directory.path}/tmp');
    if (!await audioDir.exists()) {
      await audioDir.create();
    }

    if (type == 'Fixed') {
      final String filePath =
          '${directory.path}/tmp/fixed_${startFrequency}_${duration * repeatTime}.pcm';
      final File file = File(filePath);

      if (!await file.exists()) {
        final int numSamples =
            (sampleRate * duration * repeatTime / 1000).round();
        final double sampleIncrement = startFrequency * 2 * pi / sampleRate;
        final Uint8List pcmData = Uint8List(numSamples * 2); // 16-bit PCM

        for (int i = 0, idx = 0; i < numSamples; ++i, idx += 2) {
          final double sample = sin(i * sampleIncrement);
          final int sampleInt = (sample * 32767).round(); // 16-bit PCM range
          pcmData[idx] = sampleInt.toUnsigned(8);
          pcmData[idx + 1] = (sampleInt >> 8).toUnsigned(8);
        }
        file.writeAsBytesSync(pcmData);
      }

      return filePath;
    } else if (type == 'Chirp') {
      final String filePath =
          '${directory.path}/tmp/chirp_${startFrequency}_${endFrequency}_${duration}_$repeatTime.pcm';
      final File file = File(filePath);

      if (!await file.exists()) {
        final int numSamples = (sampleRate * duration / 1000).round();
        final Uint8List pcmData = Uint8List(numSamples * 2);

        for (int i = 0, idx = 0; i < numSamples; ++i, idx += 2) {
          final double frequency =
              startFrequency + (endFrequency - startFrequency) * i / numSamples;
          final double sample = sin(2 * pi * frequency * i / sampleRate);
          final int sampleInt = (sample * 32767).round();
          pcmData[idx] = sampleInt.toUnsigned(8);
          pcmData[idx + 1] = (sampleInt >> 8).toUnsigned(8);
        }

        final Uint8List repeatedPcmData =
            Uint8List(numSamples * 2 * repeatTime);
        for (int i = 0; i < repeatTime; ++i) {
          repeatedPcmData.setRange(
              i * numSamples * 2, (i + 1) * numSamples * 2, pcmData);
        }
        file.writeAsBytesSync(repeatedPcmData);
      }
      return filePath;
    } else {
      _showSnackBar('Error audio type!');
      return null;
    }
  }

  void playAudio(String audioFilePath) async {
    await player.openPlayer();
    await player.startPlayer(
        fromURI: audioFilePath,
        codec: Codec.pcm16,
        numChannels: 1,
        sampleRate: sampleRate);
  }

  void stopPlayingAudio() async {
    await player.stopPlayer();
    await player.closePlayer();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }
}
