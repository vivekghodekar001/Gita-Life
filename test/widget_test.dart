import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gita_life/widgets/error_retry.dart';

void main() {
  testWidgets('Error view displays the failure and invokes retry', (WidgetTester tester) async {
    var retries = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ErrorRetry(message: 'Unable to load verses', onRetry: () => retries++)),
    ));
    expect(find.text('Unable to load verses'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });
}
