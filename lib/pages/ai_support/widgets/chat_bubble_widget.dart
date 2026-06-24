import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../services/ai_service.dart';

enum _BubbleAction { copy, reAsk }

/// A single chat bubble for an [AiChatMessage].
///
/// - User messages: right-aligned, primary color.
///   Long-pressing shows a context menu with Copy and Re-ask actions.
/// - AI messages: left-aligned, surfaceContainerHighest.
///   Renders Markdown (bold, lists, code blocks, etc.).
class ChatBubbleWidget extends StatelessWidget {
  const ChatBubbleWidget({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.onReAsk,
  });

  final AiChatMessage message;

  /// When true and this is an AI message, shows an animated typing indicator.
  final bool isStreaming;

  /// Called with the message content when the user picks "Re-ask".
  /// The page uses this to pre-fill the chat input.
  final ValueChanged<String>? onReAsk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUser = message.isUser;

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
      ),
      child: isUser
          ? Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
              ),
            )
          : _AiMessageContent(
              content: message.content,
              isStreaming: isStreaming,
              colorScheme: colorScheme,
            ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _AiAvatar(colorScheme: colorScheme),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: isUser
                ? _LongPressMenu(
                    content: message.content,
                    onReAsk: onReAsk,
                    child: bubble,
                  )
                : bubble,
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Long-press context menu (user bubbles only) ───────────────────────────────

class _LongPressMenu extends StatelessWidget {
  const _LongPressMenu({
    required this.content,
    required this.child,
    this.onReAsk,
  });

  final String content;
  final Widget child;
  final ValueChanged<String>? onReAsk;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) => _showMenu(context, details.globalPosition),
      child: child,
    );
  }

  Future<void> _showMenu(BuildContext context, Offset position) async {
    final screenSize = MediaQuery.sizeOf(context);

    final action = await showMenu<_BubbleAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        screenSize.width - position.dx,
        screenSize.height - position.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          value: _BubbleAction.copy,
          child: Row(
            children: [
              Icon(Icons.copy_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 12),
              const Text('Copy'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _BubbleAction.reAsk,
          child: Row(
            children: [
              Icon(Icons.replay_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 12),
              const Text('Re-ask'),
            ],
          ),
        ),
      ],
    );

    if (action == null || !context.mounted) return;

    switch (action) {
      case _BubbleAction.copy:
        await Clipboard.setData(ClipboardData(text: content));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Copied to clipboard'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      case _BubbleAction.reAsk:
        onReAsk?.call(content);
    }
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _AiAvatar extends StatelessWidget {
  const _AiAvatar({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: colorScheme.primaryContainer,
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 16,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class _AiMessageContent extends StatelessWidget {
  const _AiMessageContent({
    required this.content,
    required this.isStreaming,
    required this.colorScheme,
  });

  final String content;
  final bool isStreaming;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (content.isEmpty && isStreaming) {
      return _TypingIndicator(color: colorScheme.onSurfaceVariant);
    }

    return MarkdownBody(
      data: content,
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        code: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
          backgroundColor: colorScheme.surfaceContainer,
          color: colorScheme.onSurface,
        ),
        codeblockDecoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({required this.color});
  final Color color;

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final opacity =
                ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity < 0.5 ? opacity * 2 : (1 - opacity) * 2,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: widget.color,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
