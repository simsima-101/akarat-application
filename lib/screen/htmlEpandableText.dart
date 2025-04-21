import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlExpandableText extends StatefulWidget {
  final String htmlContent;
  final int cutoff;

  const HtmlExpandableText({
    super.key,
    required this.htmlContent,
    this.cutoff = 200, // Default cutoff length
  });

  @override
  State<HtmlExpandableText> createState() => _HtmlExpandableTextState();
}

class _HtmlExpandableTextState extends State<HtmlExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final plainText = widget.htmlContent.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
    final showToggle = plainText.length > widget.cutoff;

    final visibleHtml = _isExpanded
        ? widget.htmlContent
        : plainText.substring(0, widget.cutoff) + (showToggle ? '...' : '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Html(
          data: _isExpanded ? widget.htmlContent : visibleHtml,
          style: {
            "body": Style(
              fontSize: FontSize.medium,
              lineHeight: LineHeight.number(1.5),
              color: Colors.black87,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
          },
        ),
        if (showToggle)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Text(
                _isExpanded ? "Read less" : "Read more",
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            ),
          ),
      ],
    );
  }
}