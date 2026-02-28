String formatDuration(int seconds) {
  final totalSeconds = seconds < 0 ? 0 : seconds;
  final minutes = totalSeconds ~/ 60;
  final secs = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
