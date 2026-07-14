import 'package:dog_friend_manager/core/theme/app_theme.dart';
import 'package:dog_friend_manager/features/dashboard/presentation/dashboard_screen.dart';
import 'package:dog_friend_manager/features/dogs/presentation/dog_form_screen.dart';
import 'package:dog_friend_manager/features/dogs/presentation/dog_list_screen.dart';
import 'package:dog_friend_manager/features/events/presentation/events_screen.dart';
import 'package:dog_friend_manager/features/settings/presentation/settings_screen.dart';
import 'package:dog_friend_manager/features/settings/presentation/statistics_screen.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  late final List<Widget> _screens = const [
    DashboardScreen(),
    DogListScreen(),
    EventsScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.ivory,
              Color(0xFFF6F1E8),
              Color(0xFFE8F4EE),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            child: _screens[_index],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DogFormScreen()),
          );
        },
        icon: const Icon(Icons.pets_rounded),
        label: const Text('登録'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_agenda_rounded),
            label: '犬友',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_rounded),
            label: 'イベント',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: '統計',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
