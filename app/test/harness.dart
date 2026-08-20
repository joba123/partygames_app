import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_party/models/player.dart';
import 'package:imposter_party/state/app_state.dart';
import 'package:imposter_party/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Mounts a single screen with the providers and theme it expects, so game
/// screens can be tested without walking through splash and hub every time.
Widget harness(Widget child, {AppState? state}) {
  return ChangeNotifierProvider<AppState>.value(
    value: state ?? AppState(),
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: child,
    ),
  );
}

List<Player> testPlayers(int count) =>
    List.generate(count, (i) => Player(id: 'p$i', name: 'Spieler${i + 1}'));

/// Taps a label that may be below the fold in the 800x600 test viewport.
Future<void> tapText(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

/// Route transitions without pumpAndSettle — several game screens run an
/// endless pulse animation that never settles by design.
Future<void> settleRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
