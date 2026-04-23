import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:syntic_calculator/settings/app_settings_controller.dart';
import 'package:vibration/vibration.dart';

/// App interactions ke liye optional haptics aur audio feedback chalata hai.
class AppInteractionFeedback {
  AppInteractionFeedback._();

  static final AudioPlayer _player = AudioPlayer(playerId: 'tap-feedback');
  static Future<void>? _playerSetup;
  static final Uint8List _tapToneBytes = _buildTapToneBytes();

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
    try {
      await _ensurePlayerReady();
      await _player.stop();
      await _player.play(
        BytesSource(_tapToneBytes, mimeType: 'audio/wav'),
        volume: 0.88,
      );
      return;
    } catch (_) {
      // Audio player fail ho to system click fallback use karo.
    }

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {
      // Unsupported platform par silent fail acceptable hai.
    }
  }

  static Uint8List _buildTapToneBytes() {
    const sampleRate = 16000;
    const durationMs = 42;
    const frequency = 920.0;

    final sampleCount = (sampleRate * durationMs / 1000).round();
    final dataLength = sampleCount * 2;
    final totalLength = 44 + dataLength;
    final bytes = ByteData(totalLength);

    void writeAscii(int offset, String value) {
      for (var index = 0; index < value.length; index++) {
        bytes.setUint8(offset + index, value.codeUnitAt(index));
      }
    }

    writeAscii(0, 'RIFF');
    bytes.setUint32(4, 36 + dataLength, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    writeAscii(36, 'data');
    bytes.setUint32(40, dataLength, Endian.little);

    for (var index = 0; index < sampleCount; index++) {
      final progress = index / sampleCount;
      final envelope = (1 - progress) * 0.9;
      final sample =
          (math.sin(2 * math.pi * frequency * index / sampleRate) *
                  envelope *
                  32767)
              .round();
      bytes.setInt16(44 + (index * 2), sample, Endian.little);
    }

    return bytes.buffer.asUint8List();
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
}
