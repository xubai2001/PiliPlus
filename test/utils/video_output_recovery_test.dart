import 'package:PiliPlus/plugin/pl_player/utils/video_output_recovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  bool sample(VideoOutputRecovery guard, int seconds,
      {bool eligible = true, bool output = false, int? position}) =>
      guard.observe(
        now: Duration(seconds: seconds),
        position: Duration(seconds: position ?? seconds),
        eligible: eligible,
        hasOutput: output,
      );

  test('healthy output never reloads', () {
    final guard = VideoOutputRecovery();
    for (var i = 0; i < 30; i++) {
      expect(sample(guard, i, output: true), isFalse);
    }
  });

  test('requires sustained playback and retries only once per source', () {
    final guard = VideoOutputRecovery();
    final retries = <int>[];
    for (var i = 0; i < 30; i++) {
      if (sample(guard, i)) retries.add(i);
    }
    expect(retries, [7]);
    guard.reset();
    for (var i = 0; i < 7; i++) {
      expect(sample(guard, i), isFalse);
    }
    expect(sample(guard, 7), isTrue);
  });

  test('pause, buffering, background and audio-only reset the grace period', () {
    final guard = VideoOutputRecovery();
    for (var i = 0; i < 6; i++) {
      expect(sample(guard, i), isFalse);
    }
    expect(sample(guard, 6, eligible: false), isFalse);
    for (var i = 7; i < 13; i++) {
      expect(sample(guard, i), isFalse);
    }
    expect(sample(guard, 13), isTrue);
  });

  test('stalled progress and seeks do not count as continuous playback', () {
    final guard = VideoOutputRecovery();
    for (var i = 0; i < 20; i++) {
      expect(sample(guard, i, position: 2), isFalse);
    }
    expect(sample(guard, 20, position: 100), isFalse);
    expect(sample(guard, 21, position: 101), isFalse);
  });

  test('video output becoming available cancels a pending retry', () {
    final guard = VideoOutputRecovery();
    for (var i = 0; i < 7; i++) {
      expect(sample(guard, i), isFalse);
    }
    expect(sample(guard, 7, output: true), isFalse);
    for (var i = 8; i < 14; i++) {
      expect(sample(guard, i), isFalse);
    }
    expect(sample(guard, 14), isTrue);
  });
}
