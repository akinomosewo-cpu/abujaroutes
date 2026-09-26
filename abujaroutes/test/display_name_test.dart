import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:abujaroutes/core/services/display_name_service.dart';
import 'package:abujaroutes/core/theme/app_theme.dart';
import 'package:abujaroutes/presentation/blocs/route_bloc.dart';
import 'package:abujaroutes/presentation/pages/home_page.dart';

/// Exercises the submit flow directly via [HomePage] (the shell shown
/// once a user is signed in), bypassing the splash/auth gate which is
/// covered separately by auth_repository_test.dart.
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
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('abujaroutes_test_hive');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    // Best-effort cleanup: under heavy parallel test load, closing Hive
    // can occasionally stall. Bound it so a slow teardown never hangs
    // the whole suite — the OS reclaims the temp dir either way.
    try {
      await Hive.close().timeout(const Duration(seconds: 5));
    } catch (_) {
      // Ignore — cleanup is best-effort.
    }
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {
      // Ignore — cleanup is best-effort.
    }
  });

  setUp(() async {
    // Pre-open the box so DisplayNameService.init() (called during the
    // widget interaction below) resolves synchronously instead of
    // racing pumpAndSettle with a real, unawaited file-system open.
    await DisplayNameService.init();
    if (Hive.isBoxOpen(DisplayNameService.boxName)) {
      final box = Hive.box(DisplayNameService.boxName);
      await box.clear();
    }
  });

  Future<void> useTallSurface(WidgetTester tester) async {
    // The submit form is a scrollable list; use a tall test surface so
    // every field is laid out without needing to simulate scrolling.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Submitting a route prompts once for an optional display name, and Skip still submits', (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('originField')), 'Berger Roundabout');
    await tester.enterText(find.byKey(const Key('destinationField')), 'Kubwa');
    await tester.enterText(find.byKey(const Key('fareMinField')), '200');

    await tester.tap(find.byKey(const Key('submitRouteButton')));
    await tester.pumpAndSettle();

    // The optional, skippable display-name prompt should appear.
    expect(find.byKey(const Key('displayNameField')), findsOneWidget);
    expect(find.byKey(const Key('displayNameSkip')), findsOneWidget);

    await tester.tap(find.byKey(const Key('displayNameSkip')));
    await tester.pumpAndSettle();

    // The route was still submitted anonymously, and no login was required.
    expect(DisplayNameService.hasDisplayName, isFalse);
    expect(find.text('Route submitted!'), findsNothing); // already auto-dismissed by pumpAndSettle
  });

  testWidgets('Saving a display name persists it locally and is not asked again', (tester) async {
    await useTallSurface(tester);
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('originField')), 'Area 1');
    await tester.enterText(find.byKey(const Key('destinationField')), 'Wuse Market');
    await tester.enterText(find.byKey(const Key('fareMinField')), '150');

    await tester.tap(find.byKey(const Key('submitRouteButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('displayNameField')), 'Ada R.');
    await tester.tap(find.byKey(const Key('displayNameSave')));
    await tester.pumpAndSettle();

    expect(DisplayNameService.getDisplayName(), 'Ada R.');

    // A second submission should no longer show the name prompt.
    await tester.enterText(find.byKey(const Key('originField')), 'Nyanya');
    await tester.enterText(find.byKey(const Key('destinationField')), 'Jabi');
    await tester.enterText(find.byKey(const Key('fareMinField')), '250');

    await tester.tap(find.byKey(const Key('submitRouteButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('displayNameField')), findsNothing);
  });
}
