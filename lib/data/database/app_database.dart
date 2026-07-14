import 'package:dog_friend_manager/data/models/dog_profile.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'dog_friend_manager.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 写真や履歴は JSON 文字列として保存し、ローカル実装を単純化する。
        await db.execute('''
          CREATE TABLE dogs(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            breed TEXT NOT NULL,
            gender TEXT NOT NULL,
            birthday TEXT,
            weightKg REAL,
            coatColor TEXT,
            photoPaths TEXT NOT NULL,
            ownerName TEXT NOT NULL,
            instagram TEXT,
            lineId TEXT,
            phoneNumber TEXT,
            metDate TEXT NOT NULL,
            metPlace TEXT NOT NULL,
            eventName TEXT,
            address TEXT,
            currentArea TEXT,
            region TEXT NOT NULL,
            friendliness INTEGER NOT NULL,
            personality TEXT,
            favoriteSnack TEXT,
            favoriteToy TEXT,
            favoritePlay TEXT,
            dislikes TEXT,
            note TEXT,
            encounterHistory TEXT NOT NULL,
            tags TEXT NOT NULL,
            isFavorite INTEGER NOT NULL,
            isMyDog INTEGER NOT NULL,
            favoritePhotoPath TEXT,
            latitude REAL,
            longitude REAL
          )
        ''');
      },
    );
  }

  Future<void> seedIfEmpty(List<DogProfile> dogs) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM dogs'),
    );

    // 初回起動時だけサンプルデータを入れて、UI確認をすぐできるようにする。
    if ((count ?? 0) > 0) {
      return;
    }

    final batch = db.batch();
    for (final dog in dogs) {
      batch.insert('dogs', dog.toMap());
    }
    await batch.commit(noResult: true);
  }
}
