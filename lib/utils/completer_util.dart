import 'dart:async';

// SAFE COMPLETER

/// A safe wrapper around [Completer] for the common async patterns.
///
/// It avoids the most frequent `Bad state: Future already completed` crash by
/// no-oping (instead of throwing) when [complete] or [completeError] is called
/// more than once. It also supports an optional [withTimeout] and can be
/// reused via [reset].
///
/// Use `SafeCompleter<void>` as a one-shot signal: `complete()` to fire and
/// [future] to await.
///
/// ```dart
/// // Bridge a callback API into a Future, immune to double completion.
/// Future<int> readValue() {
///   final result = SafeCompleter<int>()..withTimeout(const Duration(seconds: 5));
///   sdk.onSuccess = result.complete;      // safe even if called twice
///   sdk.onError = result.completeError;
///   return result.future;
/// }
/// ```
class SafeCompleter<T> {
  Completer<T> _completer = Completer<T>();
  Timer? _timeoutTimer;

  /// The future callers await. Stays valid across [reset].
  Future<T> get future => _completer.future;

  /// Whether the underlying completer has already finished.
  bool get isCompleted => _completer.isCompleted;

  /// Completes with [value] only if not completed yet.
  ///
  /// Returns `true` if this call completed the future, `false` if it was
  /// already done.
  bool complete([FutureOr<T>? value]) {
    if (_completer.isCompleted) return false;
    _cancelTimeout();
    _completer.complete(value);
    return true;
  }

  /// Completes with an error only if not completed yet.
  ///
  /// Returns `true` if this call completed the future, `false` if it was
  /// already done.
  bool completeError(Object error, [StackTrace? stackTrace]) {
    if (_completer.isCompleted) return false;
    _cancelTimeout();
    _completer.completeError(error, stackTrace);
    return true;
  }

  /// Fails the future with [onTimeout] (or a [TimeoutException]) if it is not
  /// completed within [duration]. Cancelled automatically once completed.
  void withTimeout(Duration duration, {Object? onTimeout}) {
    _cancelTimeout();
    _timeoutTimer = Timer(duration, () {
      completeError(
        onTimeout ?? TimeoutException('SafeCompleter timed out', duration),
      );
    });
  }

  /// Recreates the internal completer so this instance can be awaited again.
  void reset() {
    _cancelTimeout();
    _completer = Completer<T>();
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }
}
