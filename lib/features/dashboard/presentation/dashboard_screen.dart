import 'package:dog_friend_manager/core/utils/date_utils.dart';
import 'package:dog_friend_manager/data/models/dog_profile.dart';
import 'package:dog_friend_manager/features/dogs/presentation/dog_detail_screen.dart';
import 'package:dog_friend_manager/features/dogs/viewmodels/dogs_controller.dart';
import 'package:dog_friend_manager/shared/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dogsAsync = ref.watch(dogsControllerProvider);
    final myDog = ref.watch(myDogProvider);

    return dogsAsync.when(
      data: (dogs) {
        final birthdayDogs = dogs
            .where(
              (dog) =>
                  dog.birthday?.month == DateTime.now().month &&
                  dog.birthday?.day == DateTime.now().day,
            )
            .toList();

        final recentMet = [...dogs]
          ..sort((a, b) => b.lastMetDate.compareTo(a.lastMetDate));

        final recentAdded = [...dogs]
          ..sort((a, b) => b.metDate.compareTo(a.metDate));

        return ListView(
          key: const ValueKey('dashboard'),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TitlePawBadge(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.22),
                ),
                const SizedBox(width: 12),
                Text(
                  'わんコレ',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: 12),
                _TitlePawBadge(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '写真を眺めながら、出会いの記録とうちの子プロフィールをやさしく残せるアプリ。',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            if (myDog != null) ...[
              _MyDogCard(dog: myDog),
              const SizedBox(height: 18),
            ],
            const _HeroSummaryCard(),
            const SizedBox(height: 24),
            SectionHeader(
              '今日のお誕生日',
              action: Text('${birthdayDogs.length}件'),
            ),
            const SizedBox(height: 12),
            _HorizontalDogList(dogs: birthdayDogs),
            const SizedBox(height: 24),
            const SectionHeader('最近会った犬'),
            const SizedBox(height: 12),
            _HorizontalDogList(dogs: recentMet.take(5).toList()),
            const SizedBox(height: 24),
            const SectionHeader('最近追加した犬'),
            const SizedBox(height: 12),
            _HorizontalDogList(dogs: recentAdded.take(5).toList()),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('読み込みエラー: $error')),
    );
  }
}

class _MyDogCard extends StatelessWidget {
  const _MyDogCard({required this.dog});

  final DogProfile dog;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DogDetailScreen(dogId: dog.id)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFE5D6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'マイワンコ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              const Icon(Icons.pets_rounded),
            ],
          ),
          const SizedBox(height: 14),
          Text(dog.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${dog.breed}  •  ${dog.age}歳  •  ${dog.region}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: '誕生日',
                  value: AppDateUtils.formatDate(dog.birthday),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: '体重',
                  value: dog.weightKg != null ? '${dog.weightKg}kg' : '未設定',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: '次の予定',
                  value: dog.eventName.isEmpty ? '未設定' : dog.eventName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _HeroSummaryCard extends ConsumerWidget {
  const _HeroSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dogs = ref.watch(dogsControllerProvider).valueOrNull ?? [];
    final favorites = dogs.where((dog) => dog.isFavorite).length;
    final myDogCount = dogs.where((dog) => dog.isMyDog).length;
    final upcoming = dogs.where((dog) {
      final lastMet = dog.lastMetDate;
      return DateTime.now().difference(lastMet).inDays > 180;
    }).length;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                child: Icon(Icons.pets_rounded),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日のしっぽニュース',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '誕生日通知、再会リマインド、イベント前の準備をまとめて確認。',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatPill(label: '登録数', value: '${dogs.length}'),
              const SizedBox(width: 12),
              _StatPill(label: 'マイワンコ', value: '$myDogCount'),
              const SizedBox(width: 12),
              _StatPill(label: 'お気に入り', value: '$favorites'),
              const SizedBox(width: 12),
              _StatPill(label: '半年会ってない', value: '$upcoming'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TitlePawBadge extends StatelessWidget {
  const _TitlePawBadge({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.pets_rounded),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _HorizontalDogList extends StatelessWidget {
  const _HorizontalDogList({required this.dogs});

  final List<DogProfile> dogs;

  @override
  Widget build(BuildContext context) {
    if (dogs.isEmpty) {
      return const GlassCard(
        child: Text('まだデータがありません。登録してアルバムを育てましょう。'),
      );
    }

    return SizedBox(
      height: 214,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dogs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final dog = dogs[index];
          return SizedBox(
            width: 188,
            child: GlassCard(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DogDetailScreen(dogId: dog.id),
                  ),
                );
              },
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF7E7C0), Color(0xFFBCDCCC)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              dog.name.substring(0, 1),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          if (dog.isMyDog)
                            const Positioned(
                              top: 10,
                              right: 10,
                              child: Icon(Icons.home_rounded),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(dog.name, style: Theme.of(context).textTheme.titleMedium),
                  Text(dog.breed),
                  const SizedBox(height: 4),
                  Text('最後に会った日: ${AppDateUtils.formatDate(dog.lastMetDate)}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
