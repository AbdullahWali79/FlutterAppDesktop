import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AudioService extends GetxService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool _isSoundEnabled = true.obs;
  final RxBool _isMusicEnabled = true.obs;

  bool get isSoundEnabled => _isSoundEnabled.value;
  bool get isMusicEnabled => _isMusicEnabled.value;

  Future<AudioService> init() async {
    await _loadSettings();
    return this;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundEnabled.value = prefs.getBool(AppConstants.soundEnabledKey) ?? true;
    _isMusicEnabled.value = prefs.getBool(AppConstants.musicEnabledKey) ?? true;
  }

  Future<void> toggleSound() async {
    _isSoundEnabled.value = !_isSoundEnabled.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.soundEnabledKey, _isSoundEnabled.value);
  }

  Future<void> toggleMusic() async {
    _isMusicEnabled.value = !_isMusicEnabled.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.musicEnabledKey, _isMusicEnabled.value);
  }

  Future<void> playSound(String soundPath) async {
    if (!_isSoundEnabled.value) return;
    
    try {
      await _audioPlayer.setAsset(soundPath);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> playClickSound() async {
    await playSound(AppConstants.clickSound);
  }

  Future<void> playCorrectAnswerSound() async {
    await playSound(AppConstants.correctAnswerSound);
  }

  Future<void> playWrongAnswerSound() async {
    await playSound(AppConstants.wrongAnswerSound);
  }

  Future<void> playLevelCompleteSound() async {
    await playSound(AppConstants.levelCompleteSound);
  }

  Future<void> playGameCompleteSound() async {
    await playSound(AppConstants.gameCompleteSound);
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
} 