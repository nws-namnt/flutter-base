import '../../services/ai_service.dart';

/// State for [AiSupportCubit].
///
/// Uses a sealed class so the page can handle every case exhaustively
/// with a `switch` expression.
sealed class AiSupportState {
  const AiSupportState();
}

/// Initial state — no messages yet, AI not initialized.
class AiSupportInitial extends AiSupportState {
  const AiSupportInitial();
}

/// The conversation is active.
///
/// - [messages] — full conversation history, oldest first.
/// - [isStreaming] — true while the AI is generating a response.
/// - [errorMessage] — set when the last request failed; does not wipe messages.
class AiSupportReady extends AiSupportState {
  final List<AiChatMessage> messages;
  final bool isStreaming;
  final String? errorMessage;

  const AiSupportReady({
    required this.messages,
    this.isStreaming = false,
    this.errorMessage,
  });

  AiSupportReady copyWith({
    List<AiChatMessage>? messages,
    bool? isStreaming,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiSupportReady(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Initialization failed (e.g. missing API key).
class AiSupportError extends AiSupportState {
  final String message;
  const AiSupportError(this.message);
}
