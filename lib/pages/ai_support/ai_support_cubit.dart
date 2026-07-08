import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../services/ai_service.dart';
import '../../utils/app_logger.dart' as logger;
import 'ai_support_state.dart';

/// Cubit for [AiSupportPage].
///
/// Manages:
/// - Service initialization (lazy, on first use).
/// - Sending user messages and streaming AI responses chunk by chunk.
/// - Conversation history passed to [AiService] on each turn.
class AiSupportCubit extends Cubit<AiSupportState> {
  /// Creates [AiSupportCubit] with the default [AiSupportInitial] state.
  AiSupportCubit({required this.screenName}) : super(const AiSupportInitial());

  /// The screen the user navigated from — injected into the AI system prompt.
  final String screenName;

  String _appName = 'App';
  String _appVersion = '1.0.0';

  // ── Public API ────────────────────────────────────────────────────────────

  /// Initializes the AI service and reads package info.
  ///
  /// Must be called once (e.g. in [State.initState]).
  Future<void> initialize() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appName = info.appName;
      _appVersion = '${info.version}+${info.buildNumber}';

      aiService.initialize();
      emit(const AiSupportReady(messages: []));
    } catch (e) {
      logger.err('AiSupportCubit: initialize failed', e);
      emit(AiSupportError(e.toString()));
    }
  }

  /// Adds [text] as a user message and streams the AI response.
  ///
  /// While streaming, each chunk is appended to the last AI message in place
  /// so the UI shows a live typing effect.
  Future<void> sendMessage(String text) async {
    final currentState = state;
    if (currentState is! AiSupportReady) return;
    if (text.trim().isEmpty) return;
    if (currentState.isStreaming) return;

    final userMsg = AiChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      content: text.trim(),
      isUser: true,
      createdAt: DateTime.now(),
    );

    final historyWithUser = [...currentState.messages, userMsg];

    // Add user message immediately + placeholder for AI reply
    final aiPlaceholder = AiChatMessage(
      id: '${userMsg.id}_ai',
      content: '',
      isUser: false,
      createdAt: DateTime.now(),
    );

    emit(currentState.copyWith(
      messages: [...historyWithUser, aiPlaceholder],
      isStreaming: true,
      clearError: true,
    ));

    // Stream AI response, updating the placeholder chunk by chunk
    try {
      String accumulated = '';

      await for (final chunk in aiService.streamResponse(
        userMessage: userMsg.content,
        history: currentState.messages, // history before this turn
        screenName: screenName,
        appName: _appName,
        appVersion: _appVersion,
      )) {
        accumulated += chunk;

        // Replace the last message (AI placeholder) with accumulated content
        final readyState = state as AiSupportReady;
        final updated = List<AiChatMessage>.from(readyState.messages);
        updated[updated.length - 1] = aiPlaceholder.copyWith(content: accumulated);

        emit(readyState.copyWith(messages: updated));
      }

      // Mark streaming done
      emit((state as AiSupportReady).copyWith(isStreaming: false));
    } catch (e) {
      logger.err('AiSupportCubit: sendMessage failed', e);
      final readyState = state as AiSupportReady;

      // Remove empty placeholder, surface error inline
      final updated = List<AiChatMessage>.from(readyState.messages)
        ..removeLast();

      emit(readyState.copyWith(
        messages: updated,
        isStreaming: false,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }
}
