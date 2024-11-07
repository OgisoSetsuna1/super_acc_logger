import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class MicrophoneService {
  final BuildContext context;
  final String fileName;
  FlutterSoundRecorder? _recorder;
  StreamSubscription? _recorderSubscription;
  bool _isRecording = false;

  MicrophoneService(this.context, this.fileName) {
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  void _initializeRecorder() async {
    await _recorder!.openRecorder();
    await _recorder!.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  void startListening() async {
    if (!_isRecording) {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        _showSnackBar('Failed when saving microphone data!');
        return;
      }
      String filePath = '${directory.path}/$fileName.aac';
      await _recorder!.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
        bitRate: 16000,
      );
      _isRecording = true;
      _recorderSubscription = _recorder!.onProgress!.listen((e) {
        // You can process the audio data here if needed
      });
    }
  }

  void stopListening() async {
    if (_isRecording) {
      await _recorder!.stopRecorder();
      _isRecording = false;
      _recorderSubscription?.cancel();
    }
  }

  void dispose() {
    _recorder!.closeRecorder();
    _recorder = null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }
}
