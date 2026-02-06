import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:whatstat/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: WhatStatApp(),
      ),
    );

    // Verify that the import page is shown
    expect(find.text('WhatStat'), findsOneWidget);
  });
}
