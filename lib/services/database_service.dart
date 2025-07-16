import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/idea.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'ideas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ideas(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT
          )
        ''');
      },
    );
  }

  Future<List<Idea>> getIdeas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ideas', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) {
      return Idea.fromMap(maps[i]);
    });
  }

  Future<void> insertIdea(Idea idea) async {
    final db = await database;
    await db.insert(
      'ideas',
      idea.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateIdea(Idea idea) async {
    final db = await database;
    await db.update(
      'ideas',
      idea.toMap(),
      where: 'id = ?',
      whereArgs: [idea.id],
    );
  }

  Future<void> deleteIdea(String id) async {
    final db = await database;
    await db.delete(
      'ideas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}