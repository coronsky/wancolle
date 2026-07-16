import 'package:dog_friend_manager/core/utils/date_utils.dart';
import 'package:dog_friend_manager/data/models/dog_profile.dart';
import 'package:dog_friend_manager/features/dogs/presentation/dog_form_screen.dart';
import 'package:dog_friend_manager/features/dogs/viewmodels/dogs_controller.dart';
import 'package:dog_friend_manager/shared/widgets/dog_photo.dart';
import 'package:dog_friend_manager/shared/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DogDetailScreen extends ConsumerWidget {
  const DogDetailScreen({required this.dogId, super.key});

  final String dogId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dogs = ref.watch(dogsControllerProvider).valueOrNull ?? [];
    DogProfile? dog;
    for (final entry in dogs) {
      if (entry.id == dogId) {
        dog = entry;
        break;
      }
    }

    if (dog == null) {
      return const Scaffold(
        body: Center(child: Text('対象のわんこが見つかりません。')),
      );
    }
    final resolvedDog = dog;

    return Scaffold(
      appBar: AppBar(
        title: Text(resolvedDog.name),
        actions: [
          IconButton(
            tooltip: '編集',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DogFormScreen(initialDog: resolvedDog),
                ),
              );
            },
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: '削除',
            onPressed: () => _confirmDelete(context, ref, resolvedDog),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          IconButton(
            tooltip: 'マイワンコ切り替え',
            onPressed: () async {
              await ref.read(dogsControllerProvider.notifier).saveDog(
                    resolvedDog.copyWith(isMyDog: !resolvedDog.isMyDog),
                  );
            },
            icon: Icon(
              resolvedDog.isMyDog ? Icons.home_rounded : Icons.home_outlined,
            ),
          ),
          IconButton(
            tooltip: 'お気に入り切り替え',
            onPressed: () async {
              await ref.read(dogsControllerProvider.notifier).saveDog(
                    resolvedDog.copyWith(isFavorite: !resolvedDog.isFavorite),
                  );
            },
            icon: Icon(
              resolvedDog.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _PhotoCarousel(dog: resolvedDog),
          const SizedBox(height: 18),
          if (resolvedDog.isMyDog) ...[
            const GlassCard(
              child: Row(
                children: [
                  CircleAvatar(child: Icon(Icons.home_rounded)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('このプロフィールはマイワンコとして登録されています。'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('基本情報', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _InfoLine('犬種', resolvedDog.breed),
                _InfoLine('性別', _genderLabel(resolvedDog.gender)),
                _InfoLine('年齢', '${resolvedDog.age}歳'),
                _InfoLine('誕生日', _formatOptionalDate(resolvedDog.birthday)),
                _InfoLine(
                  '体重',
                  resolvedDog.weightKg != null ? '${resolvedDog.weightKg}kg' : '',
                ),
                _InfoLine('毛色', resolvedDog.coatColor),
                _InfoLine('飼い主さん', resolvedDog.ownerName),
                _InfoLine('Instagram', resolvedDog.instagram),
                _InfoLine('LINE', resolvedDog.lineId),
                _InfoLine('電話番号', resolvedDog.phoneNumber),
                _InfoLine('出会った日', AppDateUtils.formatDate(resolvedDog.metDate)),
                _InfoLine('出会った場所', resolvedDog.metPlace),
                _InfoLine('イベント名', resolvedDog.eventName),
                _InfoLine('住所', resolvedDog.address),
                _InfoLine('現在住んでいる地域', resolvedDog.currentArea),
                _InfoLine('地域', resolvedDog.region),
                _InfoLine('タグ', resolvedDog.tags.join(' / ')),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('性格とメモ', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _InfoLine('仲良し度', '★' * resolvedDog.friendliness),
                _InfoLine('性格', resolvedDog.personality),
                _InfoLine('好きなおやつ', resolvedDog.favoriteSnack),
                _InfoLine('好きなおもちゃ', resolvedDog.favoriteToy),
                _InfoLine('好きな遊び', resolvedDog.favoritePlay),
                _InfoLine('苦手なこと', resolvedDog.dislikes),
                _InfoLine('備考', resolvedDog.note),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('過去に会った履歴', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...resolvedDog.encounterHistory.map(
                  (entry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.pets_rounded)),
                    title: Text(
                      entry.eventName.isEmpty ? 'おでかけ記録' : entry.eventName,
                    ),
                    subtitle: Text(
                      '${AppDateUtils.formatDate(entry.date)}  ${entry.placeName}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('出会った場所', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (resolvedDog.latitude != null && resolvedDog.longitude != null)
                  SizedBox(
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            resolvedDog.latitude!,
                            resolvedDog.longitude!,
                          ),
                          zoom: 13,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(resolvedDog.id),
                            position: LatLng(
                              resolvedDog.latitude!,
                              resolvedDog.longitude!,
                            ),
                            infoWindow: InfoWindow(title: resolvedDog.metPlace),
                          ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                  )
                else
                  const Text('地図情報はまだ登録されていません。'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DogProfile dog,
  ) async {
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
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  String _genderLabel(DogGender gender) {
    switch (gender) {
      case DogGender.male:
        return '男の子';
      case DogGender.female:
        return '女の子';
      case DogGender.unknown:
        return '未設定';
    }
  }

  String _formatOptionalDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    return AppDateUtils.formatDate(date);
  }
}

class _PhotoCarousel extends StatelessWidget {
  const _PhotoCarousel({required this.dog});

  final DogProfile dog;

  @override
  Widget build(BuildContext context) {
    final photos = dog.photoPaths.isEmpty ? const ['placeholder'] : dog.photoPaths;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        height: 260,
        child: PageView.builder(
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photoPath = photos[index];
            final isFavorite = dog.favoritePhotoPath == photoPath ||
                (dog.favoritePhotoPath == null && index == 0);

            return ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DogPhoto(
                      photoPath: photoPath,
                      borderRadius: 24,
                      cacheWidth: 720,
                      cacheHeight: 720,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(isFavorite ? 'お気に入り写真' : '写真 ${index + 1}'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? '未設定' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label)),
          Expanded(
            child: Text(
              displayValue,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
