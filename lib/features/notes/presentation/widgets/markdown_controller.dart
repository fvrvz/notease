import 'package:flutter/material.dart';

class MarkdownSyntaxTextEditingController extends TextEditingController {
  final bool isDark;

  MarkdownSyntaxTextEditingController({super.text, required this.isDark});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final defaultStyle = style ??
        TextStyle(
          fontSize: 14,
          height: 1.6,
          color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328),
        );

    final text = this.text;
    if (text.isEmpty) {
      return TextSpan(style: defaultStyle, text: '');
    }

    final spans = <TextSpan>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineEnd = (i == lines.length - 1) ? '' : '\n';

      if (line.startsWith('# ')) {
        spans.add(TextSpan(
          text: line + lineEnd,
          style: defaultStyle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328),
          ),
        ));
      } else if (line.startsWith('## ')) {
        spans.add(TextSpan(
          text: line + lineEnd,
          style: defaultStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328),
          ),
        ));
      } else if (line.startsWith('### ')) {
        spans.add(TextSpan(
          text: line + lineEnd,
          style: defaultStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328),
          ),
        ));
      } else if (line.trim().startsWith('> ')) {
        spans.add(TextSpan(
          text: line + lineEnd,
          style: defaultStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: isDark ? const Color(0xFF8D96A0) : const Color(0xFF656D76),
          ),
        ));
      } else if (line.trim().startsWith('- [ ] ')) {
        spans.add(TextSpan(
          text: line + lineEnd,
          style: defaultStyle.copyWith(
            color: isDark ? const Color(0xFF2F81F7) : const Color(0xFF0969DA),
            fontWeight: FontWeight.w500,
          ),
        ));
      } else if (line.trim().startsWith('- [x] ') || line.trim().startsWith('- [X] ')) {
        spans.add(TextSpan(
          text: line + lineEnd,
          style: defaultStyle.copyWith(
            decoration: TextDecoration.lineThrough,
            color: isDark ? const Color(0xFF6E7681) : const Color(0xFF8C959F),
          ),
        ));
      } else {
        // Parse inline formatting: `code`, **bold**, *italic*
        _parseInlineSpans(line + lineEnd, defaultStyle, spans);
      }
    }

    return TextSpan(style: defaultStyle, children: spans);
  }

  void _parseInlineSpans(
    String line,
    TextStyle baseStyle,
    List<TextSpan> spans,
  ) {
    // Regex matching inline markdown: code `...`, bold **...**, italic *...*
    final regex = RegExp(r'(`[^`]+`|\*\*[^*]+\*\*|\*[^*]+\*)');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(line)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: line.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchedText = match.group(0)!;
      if (matchedText.startsWith('`') && matchedText.endsWith('`')) {
        spans.add(TextSpan(
          text: matchedText,
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            fontSize: baseStyle.fontSize != null ? baseStyle.fontSize! * 0.95 : null,
            color: isDark ? const Color(0xFF2F81F7) : const Color(0xFF0969DA),
            backgroundColor: isDark ? const Color(0xFF161B22) : const Color(0xFFF0F2F5),
          ),
        ));
      } else if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchedText,
          style: baseStyle.copyWith(fontWeight: FontWeight.w700),
        ));
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*')) {
        spans.add(TextSpan(
          text: matchedText,
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else {
        spans.add(TextSpan(text: matchedText, style: baseStyle));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < line.length) {
      spans.add(TextSpan(
        text: line.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }
  }
}
