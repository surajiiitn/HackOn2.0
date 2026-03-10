import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suraksha_ai/app.dart';

void main() {
  testWidgets('renders auth screen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SurakshaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Suraksha AI'), findsOneWidget);
    expect(find.text('Secure Login'), findsOneWidget);
  });
}
