import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shiba/core/constants.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;
  Future<Database>? _databaseFuture;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _databaseFuture ??= _initDatabase().then((db) {
      _database = db;
      return db;
    }).catchError((error) {
      _databaseFuture = null;
      throw error;
    });
    return _databaseFuture!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        model_id TEXT NOT NULL,
        model_name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        system_prompt TEXT NOT NULL DEFAULT '',
        temperature REAL NOT NULL DEFAULT 0.7,
        top_k INTEGER NOT NULL DEFAULT 40,
        top_p REAL NOT NULL DEFAULT 0.9,
        max_tokens INTEGER NOT NULL DEFAULT 1024,
        history_rounds INTEGER NOT NULL DEFAULT 6
      )
    ''');
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        image_path TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE local_models (
        id TEXT PRIMARY KEY,
        repo_id TEXT NOT NULL,
        filename TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        downloaded_size INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending',
        download_url TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_messages_conversation ON messages(conversation_id)');
    await db.execute(
        'CREATE INDEX idx_conversations_updated ON conversations(updated_at DESC)');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await _safeAddColumn(db, 'conversations', 'system_prompt',
          "TEXT NOT NULL DEFAULT ''");
      await _safeAddColumn(
          db, 'conversations', 'temperature', 'REAL NOT NULL DEFAULT 0.7');
      await _safeAddColumn(
          db, 'conversations', 'top_k', 'INTEGER NOT NULL DEFAULT 40');
      await _safeAddColumn(
          db, 'conversations', 'top_p', 'REAL NOT NULL DEFAULT 0.9');
      await _safeAddColumn(
          db, 'conversations', 'max_tokens', 'INTEGER NOT NULL DEFAULT 1024');
    }
    if (oldVersion < 4) {
      await _safeAddColumn(db, 'messages', 'image_path', 'TEXT');
    }
    if (oldVersion < 5) {
      await _safeAddColumn(db, 'conversations', 'history_rounds',
          'INTEGER NOT NULL DEFAULT 6');
    }
  }

  /// Safely add a column, ignoring "duplicate column" errors.
  Future<void> _safeAddColumn(
      Database db, String table, String column, String type) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    } catch (e) {
      // Column likely already exists — safe to ignore
      if (!e.toString().toLowerCase().contains('duplicate column')) {
        rethrow;
      }
    }
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
