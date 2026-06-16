import 'package:flutter_test/flutter_test.dart';

import 'package:goalsprint/main.dart';

void main() {
  testWidgets('adds a task from the add item screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GoalSprintApp());

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Today’s Sprint'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'Write MVP notes');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Write MVP notes'), findsOneWidget);
    expect(find.text('Medium priority'), findsWidgets);
  });

  testWidgets('settings screen shows app information', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GoalSprintApp());

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('GoalSprint'), findsOneWidget);
    expect(find.text('Version: 1.0.0'), findsOneWidget);
  });
}
