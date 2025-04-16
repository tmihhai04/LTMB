import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../NoteModeL/note.dart'; // Đảm bảo đường dẫn đúng

class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Tạo bảng notes
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const nullableTextType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        title $textType,
        content $textType,
        priority $integerType,
        createdAt $integerType,
        modifiedAt $integerType,
        tags $nullableTextType,
        color $nullableTextType
      )
    ''');
  }

  // Thêm Note mới
  Future<Note> insertNote(Note note) async {
    final db = await instance.database;
    // Đảm bảo createdAt và modifiedAt được set trước khi insert
    final now = DateTime.now();
    final noteToInsert = note.copyWith(createdAt: now, modifiedAt: now);
    final id = await db.insert('notes', noteToInsert.toMap());
    return noteToInsert.copyWith(id: id); // Trả về note với ID đã được gán
  }

  // Lấy Note theo ID
  Future<Note?> getNoteById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'notes',
      columns: ['id', 'title', 'content', 'priority', 'createdAt', 'modifiedAt', 'tags', 'color'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    } else {
      return null; // Hoặc throw Exception('ID $id not found');
    }
  }

  // Lấy tất cả Notes (có thể thêm orderBy)
  Future<List<Note>> getAllNotes({String orderBy = 'modifiedAt DESC'}) async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: orderBy);
    return result.map((json) => Note.fromMap(json)).toList();
  }

  // Lấy notes theo priority
  Future<List<Note>> getNotesByPriority(int priority, {String orderBy = 'modifiedAt DESC'}) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'priority = ?',
      whereArgs: [priority],
      orderBy: orderBy,
    );
    return result.map((json) => Note.fromMap(json)).toList();
  }

  // Tìm kiếm notes
  Future<List<Note>> searchNotes(String query, {String orderBy = 'modifiedAt DESC'}) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: orderBy,
    );
    return result.map((json) => Note.fromMap(json)).toList();
  }


  // Cập nhật Note
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    // Cập nhật lại modifiedAt trước khi update
    final noteToUpdate = note.copyWith(modifiedAt: DateTime.now());
    return db.update(
      'notes',
      noteToUpdate.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Xóa Note
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Đóng DB (quan trọng)
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}