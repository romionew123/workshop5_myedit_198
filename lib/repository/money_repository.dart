import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/money_entry.dart';

class MoneyRepository {
  static const dbName = 'money.database.db';
  static const tableName = 'entries';

  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            isIncome INTEGER NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  // แสดงผล: ใหม่สุดก่อน
  static Future<List<MoneyEntry>> getAll() async {
    final db = await database;
    final maps = await db.query(tableName, orderBy: 'date DESC, id DESC');
    return maps.map(MoneyEntry.fromMap).toList();
  }

  // บันทึก
  static Future<int> insert(MoneyEntry entry) async {
    final db = await database;
    return db.insert(tableName, entry.toMap());
  }

  // แก้ไข
  static Future<int> update(MoneyEntry entry) async {
    final db = await database;
    return db.update(
      tableName,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // ลบ
  static Future<int> delete(int id) async {
    final db = await database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
