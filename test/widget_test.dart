import 'package:dog_friend_manager/app/dog_friend_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app renders shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DogFriendApp()));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
