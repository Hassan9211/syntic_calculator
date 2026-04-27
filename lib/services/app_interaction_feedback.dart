import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:syntic_calculator/settings/app_settings_controller.dart';
import 'package:vibration/vibration.dart';

/// App interactions ke liye optional haptics aur audio feedback chalata hai.
class AppInteractionFeedback {
  AppInteractionFeedback._();

  static final AudioPlayer _player = AudioPlayer(playerId: 'tap-feedback');
  static Future<void>? _playerSetup;
  static final AssetSource _tapToneSource = AssetSource(
    'audio/tap.wav',
    mimeType: 'audio/wav',
  );

  static Future<void> playTap() async {
    final settings = AppSettingsController.instance;

    if (settings.hapticsEnabled) {
      unawaited(_playHaptic());
    }

    if (settings.interfaceAudioEnabled) {
      unawaited(_playTone());
    }
  }

  static Future<void> _playHaptic() async {
    try {
      if (await Vibration.hasVibrator()) {
        if (await Vibration.hasAmplitudeControl()) {
          await Vibration.vibrate(duration: 28, amplitude: 200);
        } else {
          await Vibration.vibrate(duration: 28);
        }
        return;
      }
    } catch (_) {
      // Plugin unsupported ya device specific issue ho to fallback try hota hai.
    }

    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Agar platform haptics support na kare to silently ignore karo.
    }
  }

  static Future<void> _playTone() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await SystemSound.play(SystemSoundType.click);
        return;
      } catch (_) {
        // Agar native click unavailable ho to asset-based fallback try hota hai.
      }
    }

    try {
      await _ensurePlayerReady();
      await _player.stop();
      await _player.play(
        _tapToneSource,
        volume: 1.0,
      );
      return;
    } catch (_) {
      // Audio player fail ho to system click fallback use karo.
    }

    try {
      await SystemSound.play(_fallbackSystemSoundType);
    } catch (_) {
      // Unsupported platform par silent fail acceptable hai.
    }
  }

  static Future<void> _ensurePlayerReady() {
    return _playerSetup ??= () async {
      await _player.setPlayerMode(PlayerMode.lowLatency);
      await _player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            audioMode: AndroidAudioMode.normal,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
      await _player.setReleaseMode(ReleaseMode.stop);
    }();
  }

  static SystemSoundType get _fallbackSystemSoundType {
    if (kIsWeb) {
      return SystemSoundType.click;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return SystemSoundType.click;
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return SystemSoundType.alert;
      case TargetPlatform.fuchsia:
        return SystemSoundType.click;
    }
  }
}
