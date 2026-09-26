import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../blocs/route_bloc.dart';
import 'light_rail_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route_rounded), label: 'Routes'),
          NavigationDestination(icon: Icon(Icons.train_outlined), selectedIcon: Icon(Icons.train_rounded), label: 'Light Rail'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline_rounded), selectedIcon: Icon(Icons.add_circle_rounded), label: 'Submit'),
        ],
      ),
    );
  }
}
