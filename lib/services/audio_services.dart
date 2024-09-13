import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // For accessing local paths

class AudioRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;

  String? _audioFilePath;
  bool get isRecording => _isRecording;
  AudioRecorder() {
    _audioRecorder = FlutterSoundRecorder();
  }

  // Initialize recorder and request permission
  Future<void> initializeRecorder() async {
    await requestPermission();
    await _audioRecorder!.openRecorder();
  }

  // Start recording audio
  Future<void> startRecording() async {
    if (!_isRecording) {
      final Directory tempDir = await getTemporaryDirectory();
      _audioFilePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder!.startRecorder(
        toFile: _audioFilePath,
        codec: Codec.aacADTS,  // AAC is a good choice for Android/iOS
      );
      _isRecording = true;
    }
  }

  // Stop recording audio
  Future<void> stopRecording() async {
    if (_isRecording) {
      await _audioRecorder!.stopRecorder();
      _isRecording = false;
    }
  }

  // Upload recorded file to Firebase Storage
  Future<String?> uploadAudioFile() async {
    if (_audioFilePath != null) {
      File audioFile = File(_audioFilePath!);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('audio_files/${DateTime.now().toIso8601String()}.aac');

      try {
        // Upload the file to Firebase Storage
        final uploadTask = storageRef.putFile(audioFile);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Return the download link
        return downloadUrl;
      } catch (e) {
        print('Failed to upload audio: $e');
        return null;
      }
    }
    return null;
  }

  // Dispose the recorder
  Future<void> disposeRecorder() async {
    await _audioRecorder!.closeRecorder();
  }
  Future<void> requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        throw Exception('Microphone permission not granted');
      }
    }
  }
}



