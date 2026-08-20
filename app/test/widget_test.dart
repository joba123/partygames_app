import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/main.dart';
import 'package:imposter_party/screens/hub_screen.dart';

void main() {
  testWidgets('App boots to splash and lands on the hub', (WidgetTester tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pump();

    expect(find.text('Imposter'), findsOneWidget);

    // Splash runs 1.2 s and cross-fades into the hub.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(HubScreen), findsOneWidget);
    expect(find.text('Was zocken wir?'), findsOneWidget);
  });
}
