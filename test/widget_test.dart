import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xscore/main.dart';
import 'package:xscore/presentation/providers/settings_provider.dart';

void main() {
  testWidgets('App builds and shows dashboard', (WidgetTester tester) async {
    final settings = SettingsProvider();
    await settings.init();

    await tester.pumpWidget(XScoreApp(settings: settings));
    await tester.pumpAndSettle();

    // Nav shell should render without error
    expect(find.byType(Scaffold), findsWidgets);
  });
}