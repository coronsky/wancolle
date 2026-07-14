import 'package:dog_friend_manager/features/dogs/viewmodels/dogs_controller.dart';
import 'package:dog_friend_manager/shared/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dogs = ref.watch(dogsControllerProvider).valueOrNull ?? [];
    final breedRanking = <String, int>{};
    final regionRanking = <String, int>{};
    final eventRanking = <String, int>{};

    for (final dog in dogs) {
      breedRanking.update(dog.breed, (value) => value + 1, ifAbsent: () => 1);
      regionRanking.update(dog.region, (value) => value + 1, ifAbsent: () => 1);
      for (final log in dog.encounterHistory) {
        eventRanking.update(log.eventName, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    return ListView(
      key: const ValueKey('stats'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Text('統計', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 18),
        GlassCard(child: _RankingSection(title: '犬種ランキング', ranking: breedRanking)),
        const SizedBox(height: 14),
        GlassCard(
          child: _RankingSection(
            title: '会った回数ランキング',
            ranking: {
              for (final dog in dogs) dog.name: dog.encounterCount,
            },
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(child: _RankingSection(title: '地域ランキング', ranking: regionRanking)),
        const SizedBox(height: 14),
        GlassCard(child: _RankingSection(title: 'イベントランキング', ranking: eventRanking)),
      ],
    );
  }
}

class _RankingSection extends StatelessWidget {
  const _RankingSection({required this.title, required this.ranking});

  final String title;
  final Map<String, int> ranking;

  @override
  Widget build(BuildContext context) {
    final entries = ranking.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...entries.take(5).toList().asMap().entries.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text('${entry.key + 1}')),
                title: Text(entry.value.key),
                trailing: Text('${entry.value.value}'),
              ),
            ),
      ],
    );
  }
}
