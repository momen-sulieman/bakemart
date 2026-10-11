import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void testWidgetsIgnoringOverflow(
    String description,
    Future<void> Function(WidgetTester tester) callback,
    ) {
  testWidgets(description, (tester) async {
    final original = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      original?.call(details);
    };
    try {
      await callback(tester);
    } finally {
      FlutterError.onError = original;
    }
  });
}