import 'package:amaravati_bar_association/features/dashboard/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppSidebar toggle does not cause overflow', (WidgetTester tester) async {
    // Build the sidebar in a wide enough container to start expanded
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                AppSidebar(
                  selectedIndex: 0,
                  onDestinationSelected: (_) {},
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );

    // Initial state: Sidebar should be expanded (width ~260)
    // The toggle button is the menu icon
    final toggleButton = find.byIcon(Icons.menu);
    expect(toggleButton, findsOneWidget);

    // Initial pump to settle
    await tester.pumpAndSettle();

    // Tap to collapse
    await tester.tap(toggleButton);
    await tester.pumpAndSettle(); // Allow animation to complete and UI to redraw

    // If there is an overflow, tester.pumpAndSettle() or the frame rendering will throw an exception.
    // We can also explicitly check for overflow exceptions if we want, but standard flutter test does it.

    // Tap to expand again
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();
  });
}
