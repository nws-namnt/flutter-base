import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';

import '../common/app_env.dart';
import '../utils/app_logger.dart' as logger;

/// Global read-only accessor for the [AiService] singleton.
///
/// Call [AiService.instance.initialize()] once before first use.
///
/// ```dart
/// // In main() or on first navigation to AI support:
/// aiService.initialize();
///
/// // Stream a response:
/// aiService.streamResponse(context: ctx).listen((chunk) { ... });
/// ```
AiService get aiService => AiService.instance;

/// Model identifier used for all AI calls.
const _kModel = 'gemini-2.5-flash';

/// Singleton service that wraps [Genkit] for AI-powered features.
///
/// Responsibilities:
/// - Lazy initialization of the [Genkit] instance with the Google AI plugin.
/// - Building the system prompt with app + screen context.
/// - Converting [AiChatMessage] history to genkit [Message] objects.
/// - Returning a [Stream<String>] of text chunks for streaming UI updates.
class AiService {
  AiService._internal();

  /// The global singleton instance.
  static final AiService instance = AiService._internal();

  Genkit? _ai;

  /// Whether the service has been initialized with a valid API key.
  bool get isReady => _ai != null;

  /// Initializes the Genkit instance with the Google AI plugin.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops if the
  /// instance is already initialized.
  ///
  /// Throws [StateError] if [AppEnv.geminiApiKey] is empty.
  void initialize() {
    if (_ai != null) return;

    final apiKey = AppEnv.geminiApiKey;
    if (apiKey.isEmpty) {
      throw StateError(
        '[AiService] GEMINI_API_KEY is not set in .env.${AppEnv.flavor}. '
        'Get a free key at https://aistudio.google.com/apikey',
      );
    }

    _ai = Genkit(plugins: [googleAI(apiKey: apiKey)]);
    logger.info('AiService: initialized with model $_kModel');
  }

  /// Streams AI response text chunks for a given conversation turn.
  ///
  /// - [userMessage] — the new message from the user.
  /// - [history] — previous conversation messages (oldest first).
  /// - [screenName] — name of the screen the user is currently on.
  /// - [appName] — display name of the app.
  /// - [appVersion] — current app version string.
  ///
  /// Each yielded [String] is an incremental text chunk. Concatenate them
  /// in order to get the full response.
  ///
  /// Throws if [initialize] has not been called.
  Stream<String> streamResponse({
    required String userMessage,
    required List<AiChatMessage> history,
    required String screenName,
    required String appName,
    required String appVersion,
  }) async* {
    assert(_ai != null, 'Call AiService.initialize() before streaming.');

    final systemPrompt = _buildSystemPrompt(
      screenName: screenName,
      appName: appName,
      appVersion: appVersion,
    );

    final messages = <Message>[
      Message(
        role: Role.system,
        content: [TextPart(text: systemPrompt)],
      ),
      ..._toGenkitMessages(history),
      Message(
        role: Role.user,
        content: [TextPart(text: userMessage)],
      ),
    ];

    // Retry up to 3 times on transient server errors (INTERNAL / UNAVAILABLE).
    // Once we start yielding chunks we stop retrying — can't unsend what's already emitted.
    const maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      bool hasYielded = false;
      try {
        final stream = _ai!.generateStream(
          model: googleAI.gemini(_kModel),
          messages: messages,
        );

        await for (final chunk in stream) {
          final text = chunk.text;
          if (text.isNotEmpty) {
            hasYielded = true;
            yield text;
          }
        }
        return; // success — exit the retry loop
      } catch (e, st) {
        if (hasYielded) {
          // Already streamed partial content — can't retry cleanly.
          logger.err('AiService: stream failed mid-way', e, st);
          rethrow;
        }

        final isTransient = _isTransientError(e);
        if (!isTransient || attempt >= maxAttempts - 1) {
          logger.err('AiService: streamResponse failed', e, st);
          rethrow;
        }

        attempt++;
        final delay = Duration(seconds: attempt * 2);
        logger.info('AiService: transient error, retry $attempt/$maxAttempts in ${delay.inSeconds}s');
        await Future.delayed(delay);
      }
    }
  }

  /// Returns true for transient Google AI server errors worth retrying.
  bool _isTransientError(Object e) {
    final msg = e.toString();
    return msg.contains('INTERNAL') ||
        msg.contains('UNAVAILABLE') ||
        msg.contains('high demand') ||
        msg.contains('Please retry');
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  String _buildSystemPrompt({
    required String screenName,
    required String appName,
    required String appVersion,
  }) {
    return '''
You are a friendly in-app support assistant for $appName (version $appVersion).
The user is currently on the "$screenName" screen.

Your role:
- Help users understand how to use the app.
- Answer questions about features, navigation, and common issues.
- Be concise and practical — avoid long paragraphs.
- Always respond in the same language the user writes in.
- If you don't know something, say so honestly instead of guessing.
- Never ask for personal data (passwords, payment info, etc.).
''';
  }

  List<Message> _toGenkitMessages(List<AiChatMessage> history) {
    return history.map((msg) {
      return Message(
        role: msg.isUser ? Role.user : Role.model,
        content: [TextPart(text: msg.content)],
      );
    }).toList();
  }
}

/// A single message in an AI support conversation.
///
/// Kept in this file to avoid a separate model file for such a small data class.
class AiChatMessage {
  /// Unique identifier for this message.
  final String id;

  /// The message text. Mutated via [copyWith] as streaming chunks arrive.
  final String content;

  /// Whether this message was authored by the user (`true`) or the AI model (`false`).
  final bool isUser;

  /// When this message was created.
  final DateTime createdAt;

  /// Creates an [AiChatMessage].
  const AiChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.createdAt,
  });

  /// Creates a copy with an updated [content] — used to append streaming chunks.
  AiChatMessage copyWith({String? content}) {
    return AiChatMessage(
      id: id,
      content: content ?? this.content,
      isUser: isUser,
      createdAt: createdAt,
    );
  }
}
