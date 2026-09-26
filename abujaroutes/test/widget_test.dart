import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abujaroutes/core/theme/app_theme.dart';
import 'package:abujaroutes/presentation/blocs/route_bloc.dart';
import 'package:abujaroutes/presentation/pages/home_page.dart';

/// These tests exercise the main app shell (route list, search, tabs)
/// directly via [HomePage], the same way the app renders it once a user
/// is signed in — bypassing the splash/auth gate, which is covered by
/// its own tests (see auth_repository_test.dart).
Widget _testApp() {
  return BlocProvider(
    create: (_) => RouteBloc()..add(const RoutesStarted()),
    child: MaterialApp(
      theme: AppTheme.dark,
      home: const HomePage(),
    ),
  );
}

void main() {
  testWidgets('App launches and shows the route list with search', (WidgetTester tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('Abuja Routes'), findsOneWidget);
    expect(find.byKey(const Key('routeSearchField')), findsOneWidget);
    // Seeded sample routes should render.
    expect(find.textContaining('Berger Roundabout'), findsWidgets);
  });

  testWidgets('Searching filters the route list', (WidgetTester tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('routeSearchField')), 'kubwa');
    await tester.pumpAndSettle();

    expect(find.textContaining('Wuse Market'), findsWidgets);
    expect(find.textContaining('Berger Roundabout'), findsNothing);
  });

  testWidgets('Bottom navigation switches to Light Rail and Submit tabs', (WidgetTester tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Light Rail'));
    await tester.pumpAndSettle();
    expect(find.text('Abuja Light Rail'), findsOneWidget);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Add a route you know'), findsOneWidget);
  });
}
