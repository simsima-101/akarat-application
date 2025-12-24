// lib/widgets/read_more_text.dart
import 'package:flutter/material.dart';

enum TrimMode { line }

class ReadMoreText extends StatefulWidget {
  final String data;
  final TrimMode trimMode;
  final int trimLines;
  final String trimCollapsedText;
  final String trimExpandedText;
  final TextStyle? style;
  final TextStyle? moreStyle;
  final TextStyle? lessStyle;

  const ReadMoreText(
      this.data, {
        super.key,
        this.trimMode = TrimMode.line,
        this.trimLines = 2,
        this.trimCollapsedText = ' Read more',
        this.trimExpandedText = ' Read less',
        this.style,
        this.moreStyle,
        this.lessStyle,
      });

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText>
    with TickerProviderStateMixin {
  bool _expanded = false;
  bool _overflow = false;

  @override
  Widget build(BuildContext context) {
    // Measure whether text overflows the requested number of lines
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.data, style: widget.style);
        final tp = TextPainter(
          text: span,
          textDirection: TextDirection.ltr,
          maxLines: widget.trimMode == TrimMode.line ? widget.trimLines : null,
          ellipsis: '…',
        )..layout(maxWidth: constraints.maxWidth);

        _overflow = tp.didExceedMaxLines;

        final linkText = _expanded
            ? widget.trimExpandedText
            : (_overflow ? widget.trimCollapsedText : '');

        final linkStyle = _expanded
            ? (widget.lessStyle ??
            TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ))
            : (widget.moreStyle ??
            TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ));

        final text = Text(
          widget.data,
          style: widget.style,
          maxLines:
          !_expanded && widget.trimMode == TrimMode.line ? widget.trimLines : null,
          overflow: !_expanded ? TextOverflow.fade : TextOverflow.visible,
        );

        if (!_overflow && !_expanded) {
          // No need to show a link at all
          return text;
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topLeft,
          curve: Curves.easeInOut,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text,
              if (linkText.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(linkText, style: linkStyle),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
