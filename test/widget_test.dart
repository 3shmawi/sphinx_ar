// This is a basic Flutter widget test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sphinx_ar/main.dart';

void main() {
  testWidgets('Sphinx AR app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SphinxARApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
