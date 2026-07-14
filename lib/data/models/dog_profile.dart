import 'dart:convert';

import 'package:dog_friend_manager/core/utils/dog_age_calculator.dart';

enum DogGender { male, female, unknown }

extension DogGenderX on DogGender {
  String get label => switch (this) {
        DogGender.male => '男の子',
        DogGender.female => '女の子',
        DogGender.unknown => '未設定',
      };

  static DogGender fromName(String? value) {
    return DogGender.values.firstWhere(
      (gender) => gender.name == value,
      orElse: () => DogGender.unknown,
    );
  }
}

class EncounterLog {
  const EncounterLog({
    required this.date,
    required this.eventName,
    required this.placeName,
    required this.address,
    this.memo = '',
  });

  final DateTime date;
  final String eventName;
  final String placeName;
  final String address;
  final String memo;

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'eventName': eventName,
      'placeName': placeName,
      'address': address,
      'memo': memo,
    };
  }

  factory EncounterLog.fromMap(Map<String, dynamic> map) {
    return EncounterLog(
      date: DateTime.parse(map['date'] as String),
      eventName: map['eventName'] as String? ?? '',
      placeName: map['placeName'] as String? ?? '',
      address: map['address'] as String? ?? '',
      memo: map['memo'] as String? ?? '',
    );
  }
}

class DogProfile {
  const DogProfile({
    required this.id,
    required this.name,
    required this.breed,
    required this.gender,
    required this.ownerName,
    required this.metDate,
    required this.metPlace,
    required this.region,
    required this.friendliness,
    required this.photoPaths,
    required this.encounterHistory,
    this.birthday,
    this.weightKg,
    this.coatColor = '',
    this.instagram = '',
    this.lineId = '',
    this.phoneNumber = '',
    this.eventName = '',
    this.address = '',
    this.currentArea = '',
    this.personality = '',
    this.favoriteSnack = '',
    this.favoriteToy = '',
    this.favoritePlay = '',
    this.dislikes = '',
    this.note = '',
    this.tags = const [],
    this.isFavorite = false,
    this.isMyDog = false,
    this.favoritePhotoPath,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String breed;
  final DogGender gender;
  final DateTime? birthday;
  final double? weightKg;
  final String coatColor;
  final List<String> photoPaths;
  final String ownerName;
  final String instagram;
  final String lineId;
  final String phoneNumber;
  final DateTime metDate;
  final String metPlace;
  final String eventName;
  final String address;
  final String currentArea;
  final String region;
  final int friendliness;
  final String personality;
  final String favoriteSnack;
  final String favoriteToy;
  final String favoritePlay;
  final String dislikes;
  final String note;
  final List<EncounterLog> encounterHistory;
  final List<String> tags;
  final bool isFavorite;
  final bool isMyDog;
  final String? favoritePhotoPath;
  final double? latitude;
  final double? longitude;

  int get age => DogAgeCalculator.ageFromBirthday(birthday);

  DateTime get lastMetDate {
    if (encounterHistory.isEmpty) {
      return metDate;
    }
    return encounterHistory
        .map((entry) => entry.date)
        .reduce((value, element) => value.isAfter(element) ? value : element);
  }

  int get encounterCount => encounterHistory.length;

  DogProfile copyWith({
    String? id,
    String? name,
    String? breed,
    DogGender? gender,
    DateTime? birthday,
    double? weightKg,
    String? coatColor,
    List<String>? photoPaths,
    String? ownerName,
    String? instagram,
    String? lineId,
    String? phoneNumber,
    DateTime? metDate,
    String? metPlace,
    String? eventName,
    String? address,
    String? currentArea,
    String? region,
    int? friendliness,
    String? personality,
    String? favoriteSnack,
    String? favoriteToy,
    String? favoritePlay,
    String? dislikes,
    String? note,
    List<EncounterLog>? encounterHistory,
    List<String>? tags,
    bool? isFavorite,
    bool? isMyDog,
    String? favoritePhotoPath,
    double? latitude,
    double? longitude,
  }) {
    return DogProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      weightKg: weightKg ?? this.weightKg,
      coatColor: coatColor ?? this.coatColor,
      photoPaths: photoPaths ?? this.photoPaths,
      ownerName: ownerName ?? this.ownerName,
      instagram: instagram ?? this.instagram,
      lineId: lineId ?? this.lineId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      metDate: metDate ?? this.metDate,
      metPlace: metPlace ?? this.metPlace,
      eventName: eventName ?? this.eventName,
      address: address ?? this.address,
      currentArea: currentArea ?? this.currentArea,
      region: region ?? this.region,
      friendliness: friendliness ?? this.friendliness,
      personality: personality ?? this.personality,
      favoriteSnack: favoriteSnack ?? this.favoriteSnack,
      favoriteToy: favoriteToy ?? this.favoriteToy,
      favoritePlay: favoritePlay ?? this.favoritePlay,
      dislikes: dislikes ?? this.dislikes,
      note: note ?? this.note,
      encounterHistory: encounterHistory ?? this.encounterHistory,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isMyDog: isMyDog ?? this.isMyDog,
      favoritePhotoPath: favoritePhotoPath ?? this.favoritePhotoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'gender': gender.name,
      'birthday': birthday?.toIso8601String(),
      'weightKg': weightKg,
      'coatColor': coatColor,
      'photoPaths': jsonEncode(photoPaths),
      'ownerName': ownerName,
      'instagram': instagram,
      'lineId': lineId,
      'phoneNumber': phoneNumber,
      'metDate': metDate.toIso8601String(),
      'metPlace': metPlace,
      'eventName': eventName,
      'address': address,
      'currentArea': currentArea,
      'region': region,
      'friendliness': friendliness,
      'personality': personality,
      'favoriteSnack': favoriteSnack,
      'favoriteToy': favoriteToy,
      'favoritePlay': favoritePlay,
      'dislikes': dislikes,
      'note': note,
      'encounterHistory':
          jsonEncode(encounterHistory.map((entry) => entry.toMap()).toList()),
      'tags': jsonEncode(tags),
      'isFavorite': isFavorite ? 1 : 0,
      'isMyDog': isMyDog ? 1 : 0,
      'favoritePhotoPath': favoritePhotoPath,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory DogProfile.fromMap(Map<String, dynamic> map) {
    final historyList = (jsonDecode(map['encounterHistory'] as String? ?? '[]')
            as List)
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();

    return DogProfile(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      breed: map['breed'] as String? ?? '',
      gender: DogGenderX.fromName(map['gender'] as String?),
      birthday: map['birthday'] != null
          ? DateTime.tryParse(map['birthday'] as String)
          : null,
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      coatColor: map['coatColor'] as String? ?? '',
      photoPaths: (jsonDecode(map['photoPaths'] as String? ?? '[]') as List)
          .map((path) => path.toString())
          .toList(),
      ownerName: map['ownerName'] as String? ?? '',
      instagram: map['instagram'] as String? ?? '',
      lineId: map['lineId'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      metDate: DateTime.parse(map['metDate'] as String),
      metPlace: map['metPlace'] as String? ?? '',
      eventName: map['eventName'] as String? ?? '',
      address: map['address'] as String? ?? '',
      currentArea: map['currentArea'] as String? ?? '',
      region: map['region'] as String? ?? '',
      friendliness: map['friendliness'] as int? ?? 1,
      personality: map['personality'] as String? ?? '',
      favoriteSnack: map['favoriteSnack'] as String? ?? '',
      favoriteToy: map['favoriteToy'] as String? ?? '',
      favoritePlay: map['favoritePlay'] as String? ?? '',
      dislikes: map['dislikes'] as String? ?? '',
      note: map['note'] as String? ?? '',
      encounterHistory:
          historyList.map(EncounterLog.fromMap).toList(growable: false),
      tags: (jsonDecode(map['tags'] as String? ?? '[]') as List)
          .map((tag) => tag.toString())
          .toList(),
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
      isMyDog: (map['isMyDog'] as int? ?? 0) == 1,
      favoritePhotoPath: map['favoritePhotoPath'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}
