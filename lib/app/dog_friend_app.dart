import 'package:dog_friend_manager/core/theme/app_theme.dart';
import 'package:dog_friend_manager/features/dashboard/presentation/app_shell.dart';
import 'package:flutter/material.dart';

class DogFriendApp extends StatelessWidget {
  const DogFriendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'わんコレ！',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}
