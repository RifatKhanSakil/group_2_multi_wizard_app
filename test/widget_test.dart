import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_step_wizard_app/main.dart';

void main() {
  testWidgets('Form wizard loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MultiStepWizardApp());

    // Verify that the first step title ('Personal') is displayed.
    expect(find.text('Personal'), findsOneWidget);

    // Verify that the title in the AppBar is correct.
    expect(find.text('Multi-Step Form Wizard'), findsOneWidget);
  });
}
