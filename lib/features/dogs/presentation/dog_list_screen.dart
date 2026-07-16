import 'package:dog_friend_manager/core/utils/date_utils.dart';
import 'package:dog_friend_manager/data/models/dog_profile.dart';
import 'package:dog_friend_manager/features/dogs/presentation/dog_detail_screen.dart';
import 'package:dog_friend_manager/features/dogs/presentation/dog_form_screen.dart';
import 'package:dog_friend_manager/features/dogs/viewmodels/dogs_controller.dart';
import 'package:dog_friend_manager/shared/widgets/dog_photo.dart';
import 'package:dog_friend_manager/shared/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DogListScreen extends ConsumerWidget {
  const DogListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dogs = ref.watch(filteredDogsProvider);
    final filter = ref.watch(dogFilterProvider);
    final dogsAsync = ref.watch(dogsControllerProvider);

    return dogsAsync.when(
      data: (_) => ListView(
        key: const ValueKey('dogs'),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        children: [
          Text(
            'わんコレ！',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '出会ったわんこの思い出を、写真つきでかわいく整理できます。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: '名前・犬種・メモ・タグで検索',
            ),
            onChanged: (value) {
              ref.read(dogFilterProvider.notifier).state =
                  filter.copyWith(query: value);
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'マイワンコ',
                selected: filter.onlyMyDog,
                onTap: () {
                  ref.read(dogFilterProvider.notifier).state = filter.copyWith(
                        onlyMyDog: !filter.onlyMyDog,
                      );
                },
              ),
              _FilterChip(
                label: '仲良し度4以上',
                selected: filter.minFriendliness == 4,
                onTap: () {
                  ref.read(dogFilterProvider.notifier).state = filter.copyWith(
                        minFriendliness: filter.minFriendliness == 4 ? null : 4,
                      );
                },
              ),
              _FilterChip(
                label: '女の子',
                selected: filter.gender == DogGender.female,
                onTap: () {
                  ref.read(dogFilterProvider.notifier).state = filter.copyWith(
                        gender: filter.gender == DogGender.female
                            ? null
                            : DogGender.female,
                      );
                },
              ),
              _FilterChip(
                label: '東京',
                selected: filter.region == '東京',
                onTap: () {
                  ref.read(dogFilterProvider.notifier).state = filter.copyWith(
                        region: filter.region == '東京' ? null : '東京',
                      );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (dogs.isEmpty)
            const GlassCard(
              child: Text('まだ登録がありません。右下の追加ボタンから最初のわんこを登録してください。'),
            ),
          ...dogs.map(
            (dog) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DogCard(dog: dog),
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('読み込みエラー: $error'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _DogCard extends ConsumerWidget {
  const _DogCard({required this.dog});

  final DogProfile dog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroPhoto =
        dog.favoritePhotoPath ?? (dog.photoPaths.isEmpty ? null : dog.photoPaths.first);

    return GlassCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                height: 112,
                child: DogPhoto(
                  photoPath: heroPhoto,
                  borderRadius: 24,
                  cacheWidth: 240,
                  cacheHeight: 280,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dog.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text('${dog.breed} ・ ${dog.age}歳'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            if (dog.isMyDog)
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBFE5D6),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'マイワンコ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            IconButton(
                              onPressed: () => _confirmDelete(context, ref),
                              tooltip: 'カードを削除',
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('住んでいる地域: ${dog.region}'),
                    const SizedBox(height: 6),
                    Text('最後に会った日: ${AppDateUtils.formatDate(dog.lastMetDate)}'),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < dog.friendliness
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 18,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DogDetailScreen(dogId: dog.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('詳細を見る'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DogFormScreen(initialDog: dog),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('編集する'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カードを削除'),
        content: Text('「${dog.name}」のカードを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除する'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await ref.read(dogsControllerProvider.notifier).removeDog(dog.id);
    }
  }
}
