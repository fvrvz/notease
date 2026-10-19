import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notease/features/notes/presentation/widgets/markdown_controller.dart';

void main() {
  group('SmartMarkdownTextInputFormatter Tests', () {
    final formatter = SmartMarkdownTextInputFormatter();

    test('Continues unordered bullet list with hyphen on Enter', () {
      const oldValue = TextEditingValue(
        text: '- Item one',
        selection: TextSelection.collapsed(offset: 10),
      );
      const newValue = TextEditingValue(
        text: '- Item one\n',
        selection: TextSelection.collapsed(offset: 11),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '- Item one\n- ');
      expect(result.selection.baseOffset, 13);
    });

    test('Continues unordered bullet list with asterisk on Enter', () {
      const oldValue = TextEditingValue(
        text: '* Asterisk item',
        selection: TextSelection.collapsed(offset: 15),
      );
      const newValue = TextEditingValue(
        text: '* Asterisk item\n',
        selection: TextSelection.collapsed(offset: 16),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '* Asterisk item\n* ');
      expect(result.selection.baseOffset, 18);
    });

    test('Continues numbered list sequentially on Enter', () {
      const oldValue = TextEditingValue(
        text: '1. First step',
        selection: TextSelection.collapsed(offset: 13),
      );
      const newValue = TextEditingValue(
        text: '1. First step\n',
        selection: TextSelection.collapsed(offset: 14),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '1. First step\n2. ');
      expect(result.selection.baseOffset, 17);
    });

    test('Continues checkbox/todo item on Enter', () {
      const oldValue = TextEditingValue(
        text: '- [ ] Buy groceries',
        selection: TextSelection.collapsed(offset: 19),
      );
      const newValue = TextEditingValue(
        text: '- [ ] Buy groceries\n',
        selection: TextSelection.collapsed(offset: 20),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '- [ ] Buy groceries\n- [ ] ');
      expect(result.selection.baseOffset, 26);
    });

    test('Clears empty bullet when user presses Enter on blank bullet line', () {
      const oldValue = TextEditingValue(
        text: '- Item one\n- ',
        selection: TextSelection.collapsed(offset: 13),
      );
      const newValue = TextEditingValue(
        text: '- Item one\n- \n',
        selection: TextSelection.collapsed(offset: 14),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '- Item one\n\n');
      expect(result.selection.baseOffset, 12);
    });

    test('Clears empty numbered item when user presses Enter on blank number line', () {
      const oldValue = TextEditingValue(
        text: '1. First\n2. ',
        selection: TextSelection.collapsed(offset: 12),
      );
      const newValue = TextEditingValue(
        text: '1. First\n2. \n',
        selection: TextSelection.collapsed(offset: 13),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '1. First\n\n');
      expect(result.selection.baseOffset, 10);
    });

    test('Preserves indentation on nested bullet points', () {
      const oldValue = TextEditingValue(
        text: '  - Nested item',
        selection: TextSelection.collapsed(offset: 15),
      );
      const newValue = TextEditingValue(
        text: '  - Nested item\n',
        selection: TextSelection.collapsed(offset: 16),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '  - Nested item\n  - ');
      expect(result.selection.baseOffset, 20);
    });
  });

  group('MarkdownSyntaxTextEditingController Tests', () {
    testWidgets('Builds text spans for headings, bullets, and inline formatting', (tester) async {
      final controller = MarkdownSyntaxTextEditingController(
        text: '# Heading 1\n## Heading 2\n### Heading 3\n- Bullet item\n1. Numbered\n**bold** and *italic*',
        isDark: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              controller: controller,
            ),
          ),
        ),
      );

      expect(controller.text.contains('# Heading 1'), isTrue);
      expect(controller.text.contains('- Bullet item'), isTrue);
    });
  });
}
