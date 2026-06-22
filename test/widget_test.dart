import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a basic material app', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Trading Journal'),
        ),
      ),
    );

    expect(find.text('Trading Journal'), findsOneWidget);
  });
}
