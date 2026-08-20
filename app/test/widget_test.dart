import 'package:flutter_test/flutter_test.dart';

import 'package:imposter_party/main.dart';

void main() {
  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pump();

    expect(find.text('Imposter'), findsOneWidget);
  });
}
