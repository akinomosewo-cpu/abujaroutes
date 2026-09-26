import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/route_bloc.dart';
import 'presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
  } catch (_) {
    // Local storage is best-effort: the app stays fully usable (browsing,
    // searching and submitting routes) even if it can't be initialized.
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const AbujaRoutesApp());
}

class AbujaRoutesApp extends StatelessWidget {
  const AbujaRoutesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteBloc()..add(const RoutesStarted()),
      child: MaterialApp(
        title: 'Abuja Routes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const SplashPage(),
      ),
    );
  }
}
