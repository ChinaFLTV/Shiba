import 'dart:io';
import 'package:shiba/data/database/database_helper.dart';
import 'package:shiba/data/models/local_model.dart';

class ModelRepository {
  Future<List<LocalModel>> getAllModels() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('local_models', orderBy: 'created_at DESC');
    return maps.map((m) => LocalModel.fromMap(m)).toList();
  }

  Future<List<LocalModel>> getCompletedModels() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('local_models',
        where: 'status = ?', whereArgs: ['completed']);
    return maps.map((m) => LocalModel.fromMap(m)).toList();
  }

  Future<LocalModel?> getModel(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps =
        await db.query('local_models', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return LocalModel.fromMap(maps.first);
  }

  Future<void> insertModel(LocalModel model) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('local_models', model.toMap());
  }

  Future<void> updateModel(LocalModel model) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('local_models', model.toMap(),
        where: 'id = ?', whereArgs: [model.id]);
  }

  Future<void> deleteModel(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps =
        await db.query('local_models', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      final model = LocalModel.fromMap(maps.first);
      final file = File(model.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await db.delete('local_models', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateDownloadProgress(
      String id, int downloadedSize, ModelStatus status) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'local_models',
      {'downloaded_size': downloadedSize, 'status': status.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
