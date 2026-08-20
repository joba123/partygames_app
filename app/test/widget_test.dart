import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/main.dart';
import 'package:imposter_party/screens/hub_screen.dart';

import 'harness.dart';

void main() {
  setUp(useFakePreferences);

  testWidgets('App boots through the loading screen into the hub', (WidgetTester tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pump();

    expect(find.text('Imposter'), findsOneWidget);

    // The loading screen reads preferences, then holds for its minimum beat
    // before cross-fading into the hub.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(HubScreen), findsOneWidget);
    expect(find.text('Was zocken wir?'), findsOneWidget);
  });
}
