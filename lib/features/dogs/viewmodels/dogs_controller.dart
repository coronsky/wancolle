import 'package:dog_friend_manager/data/models/dog_profile.dart';
import 'package:dog_friend_manager/data/repositories/dog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DogFilter {
  const DogFilter({
    this.query = '',
    this.breed,
    this.region,
    this.eventName,
    this.gender,
    this.minFriendliness,
    this.onlyMyDog = false,
  });

  final String query;
  final String? breed;
  final String? region;
  final String? eventName;
  final DogGender? gender;
  final int? minFriendliness;
  final bool onlyMyDog;

  DogFilter copyWith({
    String? query,
    String? breed,
    String? region,
    String? eventName,
    DogGender? gender,
    int? minFriendliness,
    bool? onlyMyDog,
  }) {
    return DogFilter(
      query: query ?? this.query,
      breed: breed ?? this.breed,
      region: region ?? this.region,
      eventName: eventName ?? this.eventName,
      gender: gender ?? this.gender,
      minFriendliness: minFriendliness ?? this.minFriendliness,
      onlyMyDog: onlyMyDog ?? this.onlyMyDog,
    );
  }
}

final dogFilterProvider = StateProvider<DogFilter>((ref) => const DogFilter());

final dogsControllerProvider =
    AsyncNotifierProvider<DogsController, List<DogProfile>>(DogsController.new);

final filteredDogsProvider = Provider<List<DogProfile>>((ref) {
  final asyncDogs = ref.watch(dogsControllerProvider);
  final filter = ref.watch(dogFilterProvider);
  final dogs = asyncDogs.valueOrNull ?? <DogProfile>[];
  final query = filter.query.trim().toLowerCase();

  return dogs.where((dog) {
    final matchesQuery = query.isEmpty ||
        dog.name.toLowerCase().contains(query) ||
        dog.breed.toLowerCase().contains(query) ||
        dog.note.toLowerCase().contains(query) ||
        dog.tags.any((tag) => tag.toLowerCase().contains(query));

    final matchesBreed = filter.breed == null || dog.breed == filter.breed;
    final matchesRegion = filter.region == null || dog.region == filter.region;
    final matchesEvent =
        filter.eventName == null || dog.eventName == filter.eventName;
    final matchesGender =
        filter.gender == null || dog.gender == filter.gender;
    final matchesFriendliness = filter.minFriendliness == null ||
        dog.friendliness >= filter.minFriendliness!;
    final matchesMyDog = !filter.onlyMyDog || dog.isMyDog;

    return matchesQuery &&
        matchesBreed &&
        matchesRegion &&
        matchesEvent &&
        matchesGender &&
        matchesFriendliness &&
        matchesMyDog;
  }).toList()
    ..sort((a, b) {
      if (a.isMyDog != b.isMyDog) {
        return a.isMyDog ? -1 : 1;
      }
      return b.lastMetDate.compareTo(a.lastMetDate);
    });
});

final myDogProvider = Provider<DogProfile?>((ref) {
  final dogs = ref.watch(dogsControllerProvider).valueOrNull ?? [];
  for (final dog in dogs) {
    if (dog.isMyDog) {
      return dog;
    }
  }
  return null;
});

class DogsController extends AsyncNotifier<List<DogProfile>> {
  @override
  Future<List<DogProfile>> build() async {
    final repository = ref.read(dogRepositoryProvider);
    await repository.seed(_sampleDogs);
    return repository.fetchDogs();
  }

  Future<void> saveDog(DogProfile dog) async {
    state = const AsyncLoading();
    final repository = ref.read(dogRepositoryProvider);

    if (dog.isMyDog) {
      final currentDogs = state.valueOrNull ?? await repository.fetchDogs();
      for (final entry in currentDogs.where((entry) => entry.isMyDog && entry.id != dog.id)) {
        await repository.upsertDog(entry.copyWith(isMyDog: false));
      }
    }

    await repository.upsertDog(dog);
    state = AsyncData(await repository.fetchDogs());
  }

  Future<void> removeDog(String id) async {
    state = const AsyncLoading();
    final repository = ref.read(dogRepositoryProvider);
    await repository.deleteDog(id);
    state = AsyncData(await repository.fetchDogs());
  }

  String createDogId() => ref.read(dogRepositoryProvider).createId();
}

final _sampleDogs = <DogProfile>[
  DogProfile(
    id: 'sample-1',
    name: 'Moco',
    breed: 'トイプードル',
    gender: DogGender.female,
    birthday: DateTime(2022, 7, 12),
    weightKg: 3.4,
    coatColor: 'アプリコット',
    photoPaths: const ['favorite:moco'],
    ownerName: 'Yui',
    instagram: '@moco.days',
    lineId: 'moco_yui',
    metDate: DateTime(2026, 6, 20),
    metPlace: 'DOGFES',
    eventName: 'DOGFES',
    address: '埼玉県深谷市',
    currentArea: '埼玉県',
    region: '埼玉',
    friendliness: 5,
    personality: '人懐っこくて写真好き',
    favoriteSnack: 'さつまいもキューブ',
    favoriteToy: 'うさぎのぬいぐるみ',
    favoritePlay: '追いかけっこ',
    dislikes: '大きな音',
    note: 'うちの子プロフィールのサンプル。詳細画面からマイワンコ切替もできます。',
    tags: const ['イベント友達', '写真映え'],
    isFavorite: true,
    isMyDog: true,
    favoritePhotoPath: 'favorite:moco',
    latitude: 36.1979,
    longitude: 139.2817,
    encounterHistory: [
      EncounterLog(
        date: DateTime(2026, 6, 20),
        eventName: 'DOGFES',
        placeName: '深谷テラス',
        address: '埼玉県深谷市花園',
      ),
      EncounterLog(
        date: DateTime(2026, 7, 12),
        eventName: '軽井沢DOGイベント',
        placeName: '軽井沢アウトレット',
        address: '長野県北佐久郡軽井沢町',
      ),
    ],
  ),
  DogProfile(
    id: 'sample-2',
    name: 'Leo',
    breed: 'ミニチュアシュナウザー',
    gender: DogGender.male,
    birthday: DateTime(2021, 11, 2),
    weightKg: 6.1,
    coatColor: 'ソルト&ペッパー',
    photoPaths: const ['favorite:leo'],
    ownerName: 'Taichi',
    instagram: '@leo_walklog',
    lineId: 'leo_run',
    metDate: DateTime(2026, 5, 18),
    metPlace: '代々木公園ドッグラン',
    eventName: 'わんこマルシェ',
    address: '東京都渋谷区代々木神園町',
    currentArea: '東京都',
    region: '東京',
    friendliness: 4,
    personality: '走るのが大好きでマイペース',
    favoriteSnack: 'フリーズドライささみ',
    favoriteToy: 'ロープトイ',
    favoritePlay: 'ボール遊び',
    dislikes: '雨の日',
    note: 'LINE交換済み。次は秋イベントで会う予定。',
    tags: const ['ラン仲間', '東京'],
    favoritePhotoPath: 'favorite:leo',
    latitude: 35.6728,
    longitude: 139.6949,
    encounterHistory: [
      EncounterLog(
        date: DateTime(2026, 5, 18),
        eventName: 'わんこマルシェ',
        placeName: '代々木公園ドッグラン',
        address: '東京都渋谷区代々木神園町',
      ),
    ],
  ),
  DogProfile(
    id: 'sample-3',
    name: 'Sora',
    breed: '柴犬',
    gender: DogGender.female,
    birthday: DateTime(2020, 3, 15),
    weightKg: 8.5,
    coatColor: '赤',
    photoPaths: const ['favorite:sora'],
    ownerName: 'Mina',
    instagram: '@shiba_sora_trip',
    lineId: 'sora_trip',
    phoneNumber: '090-0000-1234',
    metDate: DateTime(2026, 4, 7),
    metPlace: '軽井沢アウトレット',
    eventName: '春の犬旅',
    address: '長野県北佐久郡軽井沢町',
    currentArea: '群馬県',
    region: '群馬',
    friendliness: 3,
    personality: '落ち着いていて優しい',
    favoriteSnack: '鹿肉ジャーキー',
    favoriteToy: '木製リング',
    favoritePlay: 'お散歩',
    dislikes: '混雑',
    note: '旅先で再会しやすいので旅行フォルダ向き。',
    tags: const ['旅行', '柴犬'],
    favoritePhotoPath: 'favorite:sora',
    latitude: 36.3484,
    longitude: 138.6345,
    encounterHistory: [
      EncounterLog(
        date: DateTime(2026, 4, 7),
        eventName: '春の犬旅',
        placeName: '軽井沢アウトレット',
        address: '長野県北佐久郡軽井沢町',
      ),
      EncounterLog(
        date: DateTime(2026, 8, 3),
        eventName: '深谷テラス',
        placeName: '深谷テラスパーク',
        address: '埼玉県深谷市黒田',
      ),
    ],
  ),
];
