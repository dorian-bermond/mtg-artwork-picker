import 'dart:async';
import 'dart:math';

Future<T> retry<T>(
  Future<T> Function() action, {
  required int maxAttempts,
  Duration baseDelay = const Duration(milliseconds: 250),
  bool Function(Object e)? retryIf,
}) async {
  Object? lastError;
  final rand = Random();

  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await action();
    } catch (e) {
      lastError = e;

      final shouldRetry = retryIf?.call(e) ?? true;
      if (!shouldRetry || attempt == maxAttempts) break;

      final backoffMs = baseDelay.inMilliseconds * pow(2, attempt - 1);
      final jitter = rand.nextInt(200);
      await Future.delayed(Duration(milliseconds: backoffMs.toInt() + jitter));
    }
  }
  throw lastError ?? Exception('retry() failed');
}
