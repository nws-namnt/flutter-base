import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Text widget with an optional inline/below "Read more / Read less" toggle.
///
/// ```dart
/// CollapsibleTextWidget(
///   'Lorem ipsum...',
///   maxLines: 3,
///   readMoreText: 'Show more',
///   readLessText: 'Show less',
/// )
/// ```
class CollapsibleTextWidget extends StatefulWidget {
  const CollapsibleTextWidget(
      this.text, {
        super.key,
        this.maxLines = 3,
        this.readMoreText = 'Read more',
        this.readLessText = 'Read less',
        this.textStyle,
        this.buttonTextStyle,
        this.isSuffixButton = true,
        this.allowCollapse = true,
        this.expandOnTextTap = true,
        this.animationCurve = Curves.easeOutBack,
        this.animationDuration = const Duration(milliseconds: 300),
      })  : assert(maxLines > 1, 'maxLines must be greater than 1'),
        assert(text.length > 0, 'text cannot be empty'),
        assert(readMoreText.length > 0, 'readMoreText cannot be empty'),
        assert(readLessText.length > 0, 'readLessText cannot be empty');

  final String text;
  final int maxLines;
  final String readMoreText;
  final String readLessText;
  final TextStyle? textStyle;
  final TextStyle? buttonTextStyle;

  /// Show the toggle inline as a suffix; if false it renders below the text.
  final bool isSuffixButton;

  /// Allow collapsing back after expanding.
  final bool allowCollapse;

  /// Toggle by tapping the text itself.
  final bool expandOnTextTap;
  final Curve animationCurve;
  final Duration animationDuration;

  @override
  State<CollapsibleTextWidget> createState() => _CollapsibleTextWidgetState();
}

class _CollapsibleTextWidgetState extends State<CollapsibleTextWidget> {
  final _expandedNotifier = ValueNotifier<bool>(false);

  void _toggle() => _expandedNotifier.value = !_expandedNotifier.value;

  bool get _canToggle => widget.allowCollapse || !_expandedNotifier.value;

  @override
  void dispose() {
    _expandedNotifier.dispose();
    super.dispose();
  }

  /// Builds a text span, optionally appending the inline toggle label.
  Widget _buildSpan(String text, String label, bool showButton) {
    return Text.rich(
      TextSpan(
        text: text,
        style: widget.textStyle,
        children: [
          if (widget.isSuffixButton && showButton)
            TextSpan(
              text: ' $label',
              style: widget.buttonTextStyle ??
                  const TextStyle(fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()..onTap = _toggle,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _expandedNotifier,
      builder: (context, isExpanded, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            assert(constraints.hasBoundedWidth,
            'The parent widget must provide bounded width constraints');

            final style = widget.textStyle ?? DefaultTextStyle.of(context).style;
            final fontSize = style.fontSize ?? DefaultTextStyle.of(context).style.fontSize!;

            // Measure whether the text overflows the allowed line count.
            final painter = TextPainter(
              text: TextSpan(text: widget.text, style: style),
              maxLines: widget.maxLines,
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: constraints.maxWidth);

            final showButton = painter.didExceedMaxLines && _canToggle;

            // Truncate to the last visible character when collapsed.
            final end = painter
                .getPositionForOffset(
              Offset(constraints.maxWidth, fontSize * widget.maxLines),
            )
                .offset;
            final truncated =
            isExpanded ? widget.text : widget.text.substring(0, end);

            return GestureDetector(
              onTap: () {
                if (widget.expandOnTextTap && _canToggle) _toggle();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedCrossFade(
                    firstChild:
                    _buildSpan(truncated, widget.readMoreText, showButton),
                    secondChild:
                    _buildSpan(widget.text, widget.readLessText, showButton),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: widget.animationDuration,
                    sizeCurve: widget.animationCurve,
                  ),
                  if (!widget.isSuffixButton && showButton)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: TextButton(
                          onPressed: _toggle,
                          child: Text(isExpanded
                              ? widget.readLessText
                              : widget.readMoreText),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }
    );
  }
}