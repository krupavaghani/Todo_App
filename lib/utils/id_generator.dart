import 'dart:math';

final _random = Random();

String generateId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  final randomPart = List.generate(
    6,
    (_) => _random.nextInt(36).toRadixString(36),
  ).join();
  return '$timestamp-$randomPart';
}

