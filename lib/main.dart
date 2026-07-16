import 'package:dog_friend_manager/app/dog_friend_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache
    ..maximumSize = 40
    ..maximumSizeBytes = 24 << 20;
  runApp(const ProviderScope(child: DogFriendApp()));
}
