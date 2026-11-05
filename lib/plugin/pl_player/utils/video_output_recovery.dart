/// Detects missing video output while playback continues. One retry per source.
class VideoOutputRecovery {
  Duration? _missingSince;
  Duration? _lastPosition;
  bool _retried = false;

  void reset() {
    _missingSince = null;
    _lastPosition = null;
    _retried = false;
  }

  bool observe({
    required Duration now,
    required Duration position,
    required bool eligible,
    required bool hasOutput,
  }) {
    final previous = _lastPosition;
    _lastPosition = position;
    if (!eligible || hasOutput || previous == null || position <= previous ||
        position - previous > const Duration(seconds: 3)) {
      _missingSince = null;
      return false;
    }
    _missingSince ??= now;
    if (!_retried && now - _missingSince! >= const Duration(seconds: 6)) {
      _retried = true;
      return true;
    }
    return false;
  }
}
