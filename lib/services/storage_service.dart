import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/flower_card.dart';

class StorageService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'flower_cards.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE flower_cards (
        id TEXT PRIMARY KEY,
        imagePath TEXT NOT NULL,
        generatedText TEXT NOT NULL,
        emotion TEXT NOT NULL,
        style TEXT NOT NULL,
        theme INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> saveFlowerCard(FlowerCard card) async {
    final db = await database;
    await db.insert(
      'flower_cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FlowerCard>> getFlowerCards({
    String? searchQuery,
    bool? favoritesOnly,
    String? monthFilter,
    int? limit,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    List<String> conditions = [];
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      conditions.add('(generatedText LIKE ? OR emotion LIKE ?)');
      whereArgs.addAll(['%$searchQuery%', '%$searchQuery%']);
    }
    
    if (favoritesOnly == true) {
      conditions.add('isFavorite = ?');
      whereArgs.add(1);
    }
    
    if (monthFilter != null && monthFilter.isNotEmpty) {
      // Filter by month (format: YYYY-MM)
      final parts = monthFilter.split('-');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final startOfMonth = DateTime(year, month, 1).millisecondsSinceEpoch;
        final endOfMonth = DateTime(year, month + 1, 1).millisecondsSinceEpoch - 1;
        
        conditions.add('createdAt >= ? AND createdAt <= ?');
        whereArgs.addAll([startOfMonth, endOfMonth]);
      }
    }
    
    if (conditions.isNotEmpty) {
      whereClause = 'WHERE ${conditions.join(' AND ')}';
    }
    
    String limitClause = '';
    if (limit != null && limit > 0) {
      limitClause = 'LIMIT $limit';
    }
    
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM flower_cards $whereClause ORDER BY createdAt DESC $limitClause',
      whereArgs,
    );

    return List.generate(maps.length, (i) {
      return FlowerCard.fromMap(maps[i]);
    });
  }

  Future<void> updateFlowerCard(FlowerCard card) async {
    final db = await database;
    await db.update(
      'flower_cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteFlowerCard(String id) async {
    final db = await database;
    await db.delete(
      'flower_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getAvailableMonths() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT 
        strftime('%Y-%m', datetime(createdAt/1000, 'unixepoch')) as month
      FROM flower_cards 
      ORDER BY month DESC
    ''');

    return maps.map((map) => map['month'] as String).toList();
  }

  Future<int> getCardCount() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM flower_cards'
    );
    return result.first['count'] as int;
  }

  Future<int> getFavoriteCardCount() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM flower_cards WHERE isFavorite = 1'
    );
    return result.first['count'] as int;
  }
}