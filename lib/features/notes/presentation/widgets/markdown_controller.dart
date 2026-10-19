import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formatter that automatically continues lists on Enter,
/// and terminates empty list items gracefully.
class SmartMarkdownTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only process text insertions
    if (newValue.text.length <= oldValue.text.length) {
      return newValue;
    }

    // Check if the change ended in a newline '\n'
    final insertOffset = newValue.selection.baseOffset;
    if (insertOffset <= 0 || newValue.text[insertOffset - 1] != '\n') {
      return newValue;
    }

    final newlinePos = insertOffset - 1;

    // Find the start of the previous line (before newlinePos)
    int lineStart = newlinePos - 1;
    while (lineStart >= 0 && newValue.text[lineStart] != '\n') {
      lineStart--;
    }
    lineStart++; // Start index of the previous line

    final prevLine = newValue.text.substring(lineStart, newlinePos);

    // 1. Check if previous line was an EMPTY list or todo item
    // e.g. "- ", "* ", "+ ", "1. ", "- [ ] ", "- [x] "
    final emptyBulletRegex = RegExp(r'^(\s*)([-*•+]|\d+\.|-\s*\[[ xX]?\])\s*$');
    if (emptyBulletRegex.hasMatch(prevLine)) {
      // User pressed Enter on an empty bullet line -> terminate the list
      final before = newValue.text.substring(0, lineStart);
      final after = newValue.text.substring(newlinePos); // starts with '\n'
      final newText = before + after;
      final newCursor = lineStart + 1; // cursor placed on the new blank line
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );
    }

    // 2. Check if previous line was a checkbox/todo item: "- [ ] item" or "- [x] item"
    final todoMatch = RegExp(r'^(\s*)-\s*\[[ xX]?\]\s+(.+)$').firstMatch(prevLine);
    if (todoMatch != null) {
      final indent = todoMatch.group(1) ?? '';
      final todoPrefix = '$indent- [ ] ';
      final newText = newValue.text.substring(0, newlinePos + 1) +
          todoPrefix +
          newValue.text.substring(newlinePos + 1);
      final newCursor = newlinePos + 1 + todoPrefix.length;
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );
    }

    // 3. Check if previous line was a numbered list item: "1. item", "99. item"
    final numberMatch = RegExp(r'^(\s*)(\d+)\.\s+(.+)$').firstMatch(prevLine);
    if (numberMatch != null) {
      final indent = numberMatch.group(1) ?? '';
      final currentNum = int.tryParse(numberMatch.group(2) ?? '1') ?? 1;
      final nextPrefix = '$indent${currentNum + 1}. ';
      final newText = newValue.text.substring(0, newlinePos + 1) +
          nextPrefix +
          newValue.text.substring(newlinePos + 1);
      final newCursor = newlinePos + 1 + nextPrefix.length;
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );
    }

    // 4. Check if previous line was an unordered bullet list item: "- item", "* item", "+ item"
    final bulletMatch = RegExp(r'^(\s*)([-*•+])\s+(.+)$').firstMatch(prevLine);
    if (bulletMatch != null) {
      final indent = bulletMatch.group(1) ?? '';
      final symbol = bulletMatch.group(2) ?? '-';
      final bulletPrefix = '$indent$symbol ';
      final newText = newValue.text.substring(0, newlinePos + 1) +
          bulletPrefix +
          newValue.text.substring(newlinePos + 1);
      final newCursor = newlinePos + 1 + bulletPrefix.length;
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursor),
      );
    }

    return newValue;
  }
}

/// Rich real-time WYSIWYG Markdown controller that renders headings without persisting
/// visible "#" characters, renders authentic bullet dots, checkboxes, and inline styles.
class MarkdownSyntaxTextEditingController extends TextEditingController {
  bool isDark;

  MarkdownSyntaxTextEditingController({super.text, this.isDark = true});

  void updateTheme(bool dark) {
    if (isDark != dark) {
      isDark = dark;
      notifyListeners();
    }
  }

  Color get _textColor => isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328);
  Color get _mutedColor => isDark ? const Color(0xFF8D96A0) : const Color(0xFF656D76);
  Color get _syntaxColor => (isDark ? const Color(0xFF6E7681) : const Color(0xFF8C959F)).withValues(alpha: 0.35);
  Color get _codeColor => isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA);
  Color get _codeBgColor => isDark ? const Color(0xFF161B22) : const Color(0xFFF0F2F5);
  Color get _accentColor => isDark ? const Color(0xFF7B6EF6) : const Color(0xFF5D51D6);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final defaultStyle = style ??
        TextStyle(
          fontSize: 14.5,
          height: 1.65,
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

      // 1. Heading check: #, ##, ###, ####, #####, ###### followed by space
      final headingMatch = RegExp(r'^(#{1,6})(\s+)(.*)$').firstMatch(line);
      if (headingMatch != null) {
        final hashSymbols = headingMatch.group(1)!;
        final whitespace = headingMatch.group(2)!;
        final headingText = headingMatch.group(3)!;
        final level = hashSymbols.length;

        TextStyle headingStyle;
        switch (level) {
          case 1:
            headingStyle = defaultStyle.copyWith(
              fontSize: 26.0,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.35,
              color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF0D1117),
            );
            break;
          case 2:
            headingStyle = defaultStyle.copyWith(
              fontSize: 21.0,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              height: 1.4,
              color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF1F2328),
            );
            break;
          case 3:
            headingStyle = defaultStyle.copyWith(
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              height: 1.45,
              color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF24292F),
            );
            break;
          default:
            headingStyle = defaultStyle.copyWith(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              height: 1.45,
              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF57606A),
            );
            break;
        }

        // HIDE the "# " symbols completely from the view!
        // Using fontSize: 0.001 and transparent color preserves exact character offsets
        // so Flutter cursor position and selection are 100% accurate.
        spans.add(TextSpan(
          text: hashSymbols + whitespace,
          style: const TextStyle(
            fontSize: 0.001,
            color: Colors.transparent,
            letterSpacing: -1.0,
          ),
        ));

        // Formatted heading content
        _parseInlineSpans(headingText + lineEnd, headingStyle, spans);
      } else if (RegExp(r'^(\s*)([-*•+])(\s+)(.*)$').hasMatch(line)) {
        // 2. Unordered Bullet List Item ("- ", "* ")
        final match = RegExp(r'^(\s*)([-*•+])(\s+)(.*)$').firstMatch(line)!;
        final indent = match.group(1)!;
        final symbol = match.group(2)!;
        final space = match.group(3)!;
        final content = match.group(4)!;

        if (indent.isNotEmpty) {
          spans.add(TextSpan(text: indent, style: defaultStyle));
        }

        // Render bullet with exact 2 characters: "• " (replaces "- " or "* ")
        // Character count matches 100% exactly (symbol length 1 + space length 1 = 2)
        final bulletText = (symbol.length + space.length == 2) ? '• ' : '•$space';
        spans.add(TextSpan(
          text: bulletText,
          style: defaultStyle.copyWith(
            color: _accentColor,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ));

        _parseInlineSpans(content + lineEnd, defaultStyle, spans);
      } else if (RegExp(r'^(\s*)(\d+\.)(\s+)(.*)$').hasMatch(line)) {
        // 3. Numbered List Item ("1. ", "2. ")
        final match = RegExp(r'^(\s*)(\d+\.)(\s+)(.*)$').firstMatch(line)!;
        final indent = match.group(1)!;
        final numPart = match.group(2)!;
        final space = match.group(3)!;
        final content = match.group(4)!;

        if (indent.isNotEmpty) {
          spans.add(TextSpan(text: indent, style: defaultStyle));
        }

        spans.add(TextSpan(
          text: numPart + space,
          style: defaultStyle.copyWith(
            color: _accentColor,
            fontWeight: FontWeight.w700,
          ),
        ));

        _parseInlineSpans(content + lineEnd, defaultStyle, spans);
      } else if (line.trim().startsWith('- [ ] ')) {
        // 4. Open Checkbox / Todo: "- [ ] " (6 chars)
        final idx = line.indexOf('- [ ] ');
        if (idx > 0) {
          spans.add(TextSpan(text: line.substring(0, idx), style: defaultStyle));
        }
        // 3 chars hidden "- ["
        spans.add(const TextSpan(
          text: '- [',
          style: TextStyle(fontSize: 0.001, color: Colors.transparent),
        ));
        // 1 char box "☐"
        spans.add(TextSpan(
          text: '☐',
          style: defaultStyle.copyWith(
            color: isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ));
        // 2 chars hidden "] "
        spans.add(const TextSpan(
          text: '] ',
          style: TextStyle(fontSize: 0.001, color: Colors.transparent),
        ));

        _parseInlineSpans(line.substring(idx + 6) + lineEnd, defaultStyle, spans);
      } else if (line.trim().startsWith('- [x] ') || line.trim().startsWith('- [X] ')) {
        // 5. Completed Checkbox / Todo: "- [x] " (6 chars)
        final idx = line.toLowerCase().indexOf('- [x] ');
        if (idx > 0) {
          spans.add(TextSpan(text: line.substring(0, idx), style: defaultStyle));
        }
        // 3 chars hidden "- ["
        spans.add(const TextSpan(
          text: '- [',
          style: TextStyle(fontSize: 0.001, color: Colors.transparent),
        ));
        // 1 char checked box "☑"
        spans.add(TextSpan(
          text: '☑',
          style: defaultStyle.copyWith(
            color: isDark ? const Color(0xFF3FB950) : const Color(0xFF1A7F37),
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ));
        // 2 chars hidden "] "
        spans.add(const TextSpan(
          text: '] ',
          style: TextStyle(fontSize: 0.001, color: Colors.transparent),
        ));

        _parseInlineSpans(
          line.substring(idx + 6) + lineEnd,
          defaultStyle.copyWith(
            decoration: TextDecoration.lineThrough,
            color: _mutedColor,
          ),
          spans,
        );
      } else if (line.trim().startsWith('>')) {
        // 6. Blockquote ("> text")
        final quoteMatch = RegExp(r'^(\s*)(>\s*)(.*)$').firstMatch(line);
        if (quoteMatch != null) {
          final indent = quoteMatch.group(1)!;
          final marker = quoteMatch.group(2)!;
          final content = quoteMatch.group(3)!;

          if (indent.isNotEmpty) {
            spans.add(TextSpan(text: indent, style: defaultStyle));
          }

          // Render border symbol matching length
          if (marker.length == 2) {
            spans.add(TextSpan(
              text: '▎ ',
              style: defaultStyle.copyWith(
                color: _accentColor,
                fontWeight: FontWeight.w900,
              ),
            ));
          } else {
            spans.add(TextSpan(
              text: marker,
              style: defaultStyle.copyWith(color: _syntaxColor, fontSize: 11),
            ));
          }

          _parseInlineSpans(
            content + lineEnd,
            defaultStyle.copyWith(fontStyle: FontStyle.italic, color: _mutedColor),
            spans,
          );
        } else {
          _parseInlineSpans(line + lineEnd, defaultStyle, spans);
        }
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
