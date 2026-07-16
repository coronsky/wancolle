import 'dart:convert';

import 'package:dog_friend_manager/data/database/app_database.dart';
import 'package:dog_friend_manager/data/models/dog_profile.dart';
import 'package:dog_friend_manager/shared/services/photo_optimizer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

final dogRepositoryProvider = Provider<DogRepository>((ref) {
  return DogRepository(AppDatabase.instance);
});

class DogRepository {
  DogRepository(this._database);

  final AppDatabase _database;
  final Uuid _uuid = const Uuid();
  static final List<DogProfile> _webStore = [];
  static const String _webStorageKey = 'wancolle_dogs_v1';

  Future<List<DogProfile>> fetchDogs() async {
    if (kIsWeb) {
      await _loadWebStoreIfNeeded();
      return [..._webStore]
        ..sort((a, b) => b.metDate.compareTo(a.metDate));
    }

    final db = await _database.database;
    final rows = await db.query('dogs', orderBy: 'metDate DESC');
    return rows.map(DogProfile.fromMap).toList();
  }

  Future<void> seed(List<DogProfile> dogs) async {
    if (kIsWeb) {
      await _loadWebStoreIfNeeded();
      if (_webStore.isEmpty) {
        _webStore.addAll(dogs);
        await _persistWebStore();
      }
      return;
    }

    await _database.seedIfEmpty(dogs);
  }

  Future<void> upsertDog(DogProfile dog) async {
    if (kIsWeb) {
      await _loadWebStoreIfNeeded();
      final index = _webStore.indexWhere((entry) => entry.id == dog.id);
      if (index >= 0) {
        _webStore[index] = dog;
      } else {
        _webStore.add(dog);
      }
      await _persistWebStore();
      return;
    }

    final db = await _database.database;
    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDog(String id) async {
    if (kIsWeb) {
      await _loadWebStoreIfNeeded();
      _webStore.removeWhere((entry) => entry.id == id);
      await _persistWebStore();
      return;
    }

    final db = await _database.database;
    await db.delete('dogs', where: 'id = ?', whereArgs: [id]);
  }

  String createId() => _uuid.v4();

  Future<void> _loadWebStoreIfNeeded() async {
    if (_webStore.isNotEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_webStorageKey);
    if (raw == null || raw.isEmpty) {
      return;
    }

    final decoded = jsonDecode(raw) as List;
    var didOptimize = false;
    final loadedDogs = <DogProfile>[];
    for (final entry in decoded) {
      final dog = DogProfile.fromMap(Map<String, dynamic>.from(entry as Map));
      final optimizedDog = await _optimizeDogPhotos(dog);
      if (optimizedDog != dog) {
        didOptimize = true;
      }
      loadedDogs.add(optimizedDog);
    }

    _webStore
      ..clear()
      ..addAll(loadedDogs);

    if (didOptimize) {
      await _persistWebStore();
    }
  }

  Future<void> _persistWebStore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_webStore.map((dog) => dog.toMap()).toList());
    await prefs.setString(_webStorageKey, raw);
  }

  Future<DogProfile> _optimizeDogPhotos(DogProfile dog) async {
    var didChange = false;
    final optimizedPhotoPaths = <String>[];

    for (final photoPath in dog.photoPaths) {
      final optimized = await optimizeStoredPhoto(photoPath);
      if (optimized != photoPath) {
        didChange = true;
      }
      optimizedPhotoPaths.add(optimized);
    }

    String? optimizedFavoritePhotoPath;
    if (dog.favoritePhotoPath != null) {
      optimizedFavoritePhotoPath = await optimizeStoredPhoto(dog.favoritePhotoPath!);
      if (optimizedFavoritePhotoPath != dog.favoritePhotoPath) {
        didChange = true;
      }
    }

    if (!didChange) {
      return dog;
    }

    return dog.copyWith(
      photoPaths: optimizedPhotoPaths,
      favoritePhotoPath: optimizedFavoritePhotoPath,
    );
  }
}
