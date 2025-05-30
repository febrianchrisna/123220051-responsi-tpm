import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'movies.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movieId TEXT,
        title TEXT,
        genre TEXT,
        releaseDate TEXT,
        rating REAL,
        image TEXT,
        description TEXT,
        language TEXT,
        duration TEXT,
        director TEXT,
        cast TEXT,
        username TEXT
      )
    ''');
  }

  Future<bool> registerUser(String username, String password) async {
    final db = await database;
    try {
      await db.insert('users', {
        'username': username,
        'password': password,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  Future<void> addToFavorites(Movie movie, String username) async {
    final db = await database;

    // Check if already exists to avoid duplicates
    final existing = await db.query(
      'favorites',
      where: 'movieId = ? AND username = ?',
      whereArgs: [movie.id, username],
    );

    if (existing.isEmpty) {
      await db.insert('favorites', {
        'movieId': movie.id,
        'title': movie.title,
        'genre': movie.genre,
        'releaseDate': movie.releaseDate,
        'rating': movie.rating,
        'image': movie.image,
        'description': movie.description,
        'language': movie.language,
        'duration': movie.duration,
        'director': movie.director,
        'cast': movie.cast.join(','), // Convert List to comma-separated string
        'username': username,
      });
    }
  }

  Future<void> removeFromFavorites(String movieId, String username) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'movieId = ? AND username = ?',
      whereArgs: [movieId, username],
    );
  }

  Future<List<Movie>> getFavorites(String username) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.map((map) {
      // Safely handle cast conversion from database string to List<String>
      String castString = map['cast']?.toString() ?? '';
      List<String> castList = [];
      if (castString.isNotEmpty) {
        castList = castString
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      return Movie(
        id: map['movieId']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        genre: map['genre']?.toString() ?? '',
        releaseDate: map['releaseDate']?.toString() ?? '',
        rating: _parseDouble(map['rating']),
        image: map['image']?.toString() ?? '',
        language: map['language']?.toString() ?? '',
        duration: map['duration']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        director: map['director']?.toString() ?? '',
        cast: castList,
      );
    }).toList();
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Future<bool> isFavorite(String movieId, String username) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'movieId = ? AND username = ?',
      whereArgs: [movieId, username],
    );
    return result.isNotEmpty;
  }
}
