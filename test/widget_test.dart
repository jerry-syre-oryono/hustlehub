import 'package:flutter_test/flutter_test.dart';
import 'package:hustlehub/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HustleHubApp());

    // Verify that our app starts.
    expect(find.byType(HustleHubApp), findsOneWidget);
  });
}
