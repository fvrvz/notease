import 'package:flutter/material.dart';

class MarkdownSyntaxTextEditingController extends TextEditingController {
  final bool isDark;

  MarkdownSyntaxTextEditingController({super.text, required this.isDark});

  Color get _syntaxColor => (isDark ? const Color(0xFF6E7681) : const Color(0xFF8C959F))
      .withValues(alpha: 0.35);

  Color get _textColor => isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328);

  Color get _mutedColor => isDark ? const Color(0xFF8D96A0) : const Color(0xFF656D76);

  Color get _codeColor => isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA);

  Color get _codeBgColor => isDark ? const Color(0xFF161B22) : const Color(0xFFF0F2F5);

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
          color: _textColor,
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

      // 1. Heading check: #, ##, ###, ####, #####, ###### (with or without space)
      final headingMatch = RegExp(r'^(#{1,6})(\s*)(.*)$').firstMatch(line);
      if (headingMatch != null && headingMatch.group(1)!.isNotEmpty) {
        final hashSymbols = headingMatch.group(1)!;
        final whitespace = headingMatch.group(2)!;
        final headingText = headingMatch.group(3)!;
        final level = hashSymbols.length;

        TextStyle headingStyle;
        switch (level) {
          case 1:
            headingStyle = defaultStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: _textColor,
            );
            break;
          case 2:
            headingStyle = defaultStyle.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: _textColor,
            );
            break;
          case 3:
            headingStyle = defaultStyle.copyWith(
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
              color: _textColor,
            );
            break;
          default:
            headingStyle = defaultStyle.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _mutedColor,
            );
            break;
        }

        // Faint, dimmed syntax marker for #/##/###
        spans.add(TextSpan(
          text: hashSymbols + whitespace,
          style: defaultStyle.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: _syntaxColor,
            letterSpacing: 0.5,
          ),
        ));

        // Formatted heading content
        _parseInlineSpans(headingText + lineEnd, headingStyle, spans);
      } else if (line.trim().startsWith('>')) {
        // Blockquote
        final quoteMatch = RegExp(r'^(\s*>\s*)(.*)$').firstMatch(line);
        if (quoteMatch != null) {
          spans.add(TextSpan(
            text: quoteMatch.group(1)!,
            style: defaultStyle.copyWith(fontSize: 11, color: _syntaxColor),
          ));
          _parseInlineSpans(
            quoteMatch.group(2)! + lineEnd,
            defaultStyle.copyWith(fontStyle: FontStyle.italic, color: _mutedColor),
            spans,
          );
        } else {
          _parseInlineSpans(line + lineEnd, defaultStyle, spans);
        }
      } else if (line.trim().startsWith('- [ ] ')) {
        // Open Todo
        final idx = line.indexOf('- [ ] ');
        if (idx > 0) {
          spans.add(TextSpan(text: line.substring(0, idx), style: defaultStyle));
        }
        spans.add(TextSpan(
          text: '☐ ',
          style: defaultStyle.copyWith(
            color: isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA),
            fontWeight: FontWeight.w600,
          ),
        ));
        _parseInlineSpans(line.substring(idx + 6) + lineEnd, defaultStyle, spans);
      } else if (line.trim().startsWith('- [x] ') || line.trim().startsWith('- [X] ')) {
        // Completed Todo
        final idx = line.toLowerCase().indexOf('- [x] ');
        if (idx > 0) {
          spans.add(TextSpan(text: line.substring(0, idx), style: defaultStyle));
        }
        spans.add(TextSpan(
          text: '☑ ',
          style: defaultStyle.copyWith(
            color: isDark ? const Color(0xFF3FB950) : const Color(0xFF1A7F37),
            fontWeight: FontWeight.w600,
          ),
        ));
        _parseInlineSpans(
          line.substring(idx + 6) + lineEnd,
          defaultStyle.copyWith(
            decoration: TextDecoration.lineThrough,
            color: _mutedColor,
          ),
          spans,
        );
      } else {
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
      if (matchedText.startsWith('`') && matchedText.endsWith('`') && matchedText.length > 1) {
        final inner = matchedText.substring(1, matchedText.length - 1);
        spans.add(TextSpan(text: '`', style: baseStyle.copyWith(fontSize: 10, color: _syntaxColor)));
        spans.add(TextSpan(
          text: inner,
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            fontSize: baseStyle.fontSize != null ? baseStyle.fontSize! * 0.92 : null,
            color: _codeColor,
            backgroundColor: _codeBgColor,
          ),
        ));
        spans.add(TextSpan(text: '`', style: baseStyle.copyWith(fontSize: 10, color: _syntaxColor)));
      } else if (matchedText.startsWith('**') && matchedText.endsWith('**') && matchedText.length > 3) {
        final inner = matchedText.substring(2, matchedText.length - 2);
        spans.add(TextSpan(text: '**', style: baseStyle.copyWith(fontSize: 10, color: _syntaxColor)));
        spans.add(TextSpan(
          text: inner,
          style: baseStyle.copyWith(fontWeight: FontWeight.w700),
        ));
        spans.add(TextSpan(text: '**', style: baseStyle.copyWith(fontSize: 10, color: _syntaxColor)));
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*') && matchedText.length > 1) {
        final inner = matchedText.substring(1, matchedText.length - 1);
        spans.add(TextSpan(text: '*', style: baseStyle.copyWith(fontSize: 10, color: _syntaxColor)));
        spans.add(TextSpan(
          text: inner,
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
        spans.add(TextSpan(text: '*', style: baseStyle.copyWith(fontSize: 10, color: _syntaxColor)));
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
