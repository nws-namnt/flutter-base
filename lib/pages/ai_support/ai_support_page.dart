import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'ai_support_cubit.dart';
import 'ai_support_state.dart';
import 'widgets/chat_bubble_widget.dart';
import 'widgets/chat_input_widget.dart';

/// Full-screen AI support chat page.
///
/// Accepts a [screenName] that is injected into the AI system prompt so the
/// assistant knows which part of the app the user is asking about.
///
/// Navigate to this page via:
/// ```dart
/// context.goNamed(
///   Routers.aiSupport.routerName,
///   extra: {'screenName': 'Home'},
/// );
/// ```
class AiSupportPage extends StatefulWidget {
  /// Creates an [AiSupportPage] for the given [screenName].
  const AiSupportPage({super.key, required this.screenName});

  /// The screen the user came from (e.g. 'Home', 'Settings').
  final String screenName;

  @override
  State<AiSupportPage> createState() => _AiSupportPageState();
}

class _AiSupportPageState extends State<AiSupportPage> {
  late final AiSupportCubit _cubit;
  final _scrollController = ScrollController();

  // Shared input controller + focus node so the Re-ask action can
  // pre-fill the text field from outside ChatInputWidget.
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _cubit = AiSupportCubit(screenName: widget.screenName);
    _cubit.initialize();
  }

  @override
  void dispose() {
    _cubit.close();
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Pre-fills the input field with [content] and requests focus.
  /// Triggered when the user picks "Re-ask" from a bubble's context menu.
  void _fillInput(String content) {
    _inputController.text = content;
    // Move cursor to end
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: content.length),
    );
    _inputFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: _AiSupportView(
        scrollController: _scrollController,
        inputController: _inputController,
        inputFocusNode: _inputFocusNode,
        onScrollToBottom: _scrollToBottom,
        onReAsk: _fillInput,
      ),
    );
  }
}

class _AiSupportView extends StatelessWidget {
  const _AiSupportView({
    required this.scrollController,
    required this.inputController,
    required this.inputFocusNode,
    required this.onScrollToBottom,
    required this.onReAsk,
  });

  final ScrollController scrollController;
  final TextEditingController inputController;
  final FocusNode inputFocusNode;
  final VoidCallback onScrollToBottom;
  final ValueChanged<String> onReAsk;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AiSupportCubit>();

    return Scaffold(
      appBar: AppBar(
        // Explicit back button — always visible regardless of navigation stack depth.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/setting');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Support'),
            Text(
              'Currently on: ${cubit.screenName}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Powered by Gemini',
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<AiSupportCubit, AiSupportState>(
        listener: (context, state) {
          if (state is AiSupportReady) onScrollToBottom();
        },
        builder: (context, state) => switch (state) {
          AiSupportInitial() => const _LoadingView(),
          AiSupportError(:final message) => _ErrorView(message: message),
          AiSupportReady() => _ChatView(
              state: state,
              scrollController: scrollController,
              inputController: inputController,
              inputFocusNode: inputFocusNode,
              onSend: cubit.sendMessage,
              onReAsk: onReAsk,
            ),
        },
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About AI Support'),
        content: const Text(
          'This assistant is powered by Google Gemini. '
          'Responses may not always be accurate. '
          'Never share passwords or sensitive information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// ── Sub-views ─────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Could not start AI support',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView({
    required this.state,
    required this.scrollController,
    required this.inputController,
    required this.inputFocusNode,
    required this.onSend,
    required this.onReAsk,
  });

  final AiSupportReady state;
  final ScrollController scrollController;
  final TextEditingController inputController;
  final FocusNode inputFocusNode;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onReAsk;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: state.messages.isEmpty
              ? const _EmptyHint()
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    final isLastAi =
                        !msg.isUser && index == state.messages.length - 1;
                    return ChatBubbleWidget(
                      message: msg,
                      isStreaming: isLastAi && state.isStreaming,
                      onReAsk: msg.isUser ? onReAsk : null,
                    );
                  },
                ),
        ),
        if (state.errorMessage != null)
          _InlineError(message: state.errorMessage!),
        ChatInputWidget(
          onSend: onSend,
          isStreaming: state.isStreaming,
          controller: inputController,
          focusNode: inputFocusNode,
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 56,
            color: colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'How can I help you?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask anything about the app.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: colorScheme.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
