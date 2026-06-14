// Smoke test for the app shell. Replaces the default `flutter create` test
// (which referenced a non-existent `MyApp`) with one that pumps the real app.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_game/app.dart';

void main() {
  testWidgets('main menu renders the title and start button', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: HiveApp()));
    await tester.pump();

    expect(find.text('HIVE'), findsOneWidget);
    expect(find.text('START NIGHT'), findsOneWidget);
  });
}
