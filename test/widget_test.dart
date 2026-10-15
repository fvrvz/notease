import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notease/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NoteEaseApp(),
      ),
    );
    // Pump frames without waiting for infinite repeat animation to settle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(NoteEaseApp), findsOneWidget);
  });
}
