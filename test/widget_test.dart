import 'package:cofino/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('le thème Café Maroc affiche une action principale',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
            body: Center(
                child: FilledButton(
                    onPressed: () {}, child: const Text('Se connecter'))))));
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
