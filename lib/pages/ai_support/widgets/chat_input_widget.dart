import 'package:flutter/material.dart';

/// Bottom input bar for the AI support chat.
///
/// Accepts an optional external [controller] and [focusNode] so the parent
/// page can pre-fill the field (e.g. when the user picks "Re-ask" on a bubble).
/// If not provided, internal instances are created and managed automatically.
class ChatInputWidget extends StatefulWidget {
  const ChatInputWidget({
    super.key,
    required this.onSend,
    this.isStreaming = false,
    this.controller,
    this.focusNode,
  });

  /// Called with the trimmed message text when the user taps Send.
  final ValueChanged<String> onSend;

  /// When true, input and send button are disabled.
  final bool isStreaming;

  /// Optional external controller — lets the parent pre-fill the field.
  final TextEditingController? controller;

  /// Optional external focus node — lets the parent request focus.
  final FocusNode? focusNode;

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  // Track ownership so we only dispose what we created.
  late final bool _ownsController;
  late final bool _ownsFocusNode;

  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();

    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isStreaming) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canSend = _hasText && !widget.isStreaming;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.isStreaming,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: widget.isStreaming
                      ? 'Waiting for response…'
                      : 'Ask anything…',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilledButton.icon(
                onPressed: canSend ? _submit : null,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Send'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
