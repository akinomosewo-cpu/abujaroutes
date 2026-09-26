import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/navigation/page_transitions.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/route_bloc.dart';
import 'light_rail_page.dart';
import 'login_page.dart';
import 'route_list_page.dart';
import 'submit_route_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  static const _pages = [
    RouteListPage(),
    LightRailPage(),
    SubmitRoutePage(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<RouteBloc>().add(const RoutesStarted());
  }

  Future<void> _logOut() async {
    await AuthRepository.instance.logOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      FadeSlidePageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    key: const Key('logoutButton'),
                    tooltip: 'Log out',
                    onPressed: _logOut,
                    icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(child: IndexedStack(index: _index, children: _pages)),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppColors.cardShadow,
        ),
        child: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route_rounded), label: 'Routes'),
          NavigationDestination(icon: Icon(Icons.train_outlined), selectedIcon: Icon(Icons.train_rounded), label: 'Light Rail'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline_rounded), selectedIcon: Icon(Icons.add_circle_rounded), label: 'Submit'),
        ],
        ),
      ),
    );
  }
}
