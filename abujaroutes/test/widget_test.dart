import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abujaroutes/main.dart';

void main() {
  testWidgets('App launches and shows the route list with search', (WidgetTester tester) async {
    await tester.pumpWidget(const AbujaRoutesApp());
    await tester.pumpAndSettle();

    expect(find.text('Abuja Routes'), findsOneWidget);
    expect(find.byKey(const Key('routeSearchField')), findsOneWidget);
    // Seeded sample routes should render.
    expect(find.textContaining('Berger Roundabout'), findsWidgets);
  });

  testWidgets('Searching filters the route list', (WidgetTester tester) async {
    await tester.pumpWidget(const AbujaRoutesApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('routeSearchField')), 'kubwa');
    await tester.pumpAndSettle();

    expect(find.textContaining('Wuse Market'), findsWidgets);
    expect(find.textContaining('Berger Roundabout'), findsNothing);
  });

  testWidgets('Bottom navigation switches to Light Rail and Submit tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const AbujaRoutesApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Light Rail'));
    await tester.pumpAndSettle();
    expect(find.text('Abuja Light Rail'), findsOneWidget);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Add a route you know'), findsOneWidget);
  });
}
