import 'package:dialogflow_flutter/dialogflowFlutter.dart';
import 'package:dialogflow_flutter/googleAuth.dart';
import 'package:dialogflow_flutter/language.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechProvider extends ChangeNotifier {
  PorcupineManager? _porcupineManager;
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  String _recognizedText = '';
  bool _isListening = false;
  double _soundLevel = 0;
  String _getIntent = '';

  String get recognizedText => _recognizedText;

  String get getIntent => _getIntent;

  double get soundLevel => _soundLevel;

  SpeechProvider() {
    _initSpeech();
  }

  void clearIntent() {
    _getIntent = '';
    notifyListeners(); // In case of error, try commenting it
  }

  Future<void> _initSpeech() async {
    await _initWakeWord();
    await _speechToText.initialize(onError: print, onStatus: _onStatus);
  }

  Future<void> _initWakeWord() async {
    bool check = await Permission.microphone.isGranted;
    if(!check){
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) return;
    }
    const accessKey =
        "kT6e7AoFQGKX0SxpntSrTkAr0/kfpbw8yQuPwIhf8uH4CgnFPSIiDQ=="; // Replace with your real access key
    const keywordPath = 'assets/voice/hey_park_easy.ppn';

    _porcupineManager = await PorcupineManager.fromKeywordPaths(
      accessKey,
      [keywordPath],
      _onWakeWordDetected,
      sensitivities: [0.7],
      errorCallback: (err) => debugPrint("Porcupine error: $err"),
    );

    await _porcupineManager?.start();
  }

  void _onWakeWordDetected(int index) async {
    debugPrint("Wake word detected!");
    await _porcupineManager?.stop();
    await Future.delayed(const Duration(milliseconds: 300));
    _capture();
  }

  void _onStatus(String status) async {
    if (status == 'done') {
      // for fast response, you can do it at status == 'notListening' but not both else it will be called 2 times
      _isListening = false;
      _speechToText.stop();
      notifyListeners();
      await _porcupineManager?.start();
      getIntentFromDialogflow(_recognizedText);
    }
  }

  void _capture() async {
    if (_isListening) return;

    if (!_speechToText.isAvailable) {
      bool available = await _speechToText.initialize();
      if (!available) return;
    }
    _isListening = true;
    _speechToText.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        notifyListeners();
      },
      onSoundLevelChange: (level) {
        _soundLevel = level;
        notifyListeners();
      },
    );
  }

  Future<void> getIntentFromDialogflow(String userInput) async {
    AuthGoogle authGoogle =
    await AuthGoogle(fileJson: "assets/voice/your_file.json").build();
    DialogFlow dialogFlow = DialogFlow(
      authGoogle: authGoogle,
      language: Language.english,
    );
    AIResponse response = await dialogFlow.detectIntent(userInput);

    debugPrint("Query Result: ${response.queryResult}");
    debugPrint("Detected Intent: ${response.queryResult?.intent?.displayName}");

    _getIntent = response.queryResult?.intent?.displayName ?? 'WOAH';
    notifyListeners();
  }

  @override
  void dispose() {
    _porcupineManager?.stop();
    _porcupineManager?.delete();
    super.dispose();
  }
}