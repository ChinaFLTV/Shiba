import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shiba/core/constants.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: 4,
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
        max_tokens INTEGER NOT NULL DEFAULT 1024
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
      await db.execute("ALTER TABLE conversations ADD COLUMN system_prompt TEXT NOT NULL DEFAULT ''");
      await db.execute('ALTER TABLE conversations ADD COLUMN temperature REAL NOT NULL DEFAULT 0.7');
      await db.execute('ALTER TABLE conversations ADD COLUMN top_k INTEGER NOT NULL DEFAULT 40');
      await db.execute('ALTER TABLE conversations ADD COLUMN top_p REAL NOT NULL DEFAULT 0.9');
      await db.execute('ALTER TABLE conversations ADD COLUMN max_tokens INTEGER NOT NULL DEFAULT 1024');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE messages ADD COLUMN image_path TEXT');
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
