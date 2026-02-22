import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shiba/core/constants.dart';
import 'package:shiba/data/database/database_helper.dart';
import 'package:shiba/data/models/local_model.dart';

class ModelRepository {
  /// Resolve the current models directory and re-map filePath for each model.
  /// On iOS the sandbox UUID changes across reinstalls, so stored absolute
  /// paths may become stale. This ensures filePath always points to the
  /// current documents directory.
  Future<List<LocalModel>> _resolveModels(List<Map<String, dynamic>> maps) async {
    if (maps.isEmpty) return [];
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = p.join(appDir.path, AppConstants.modelsSubDir);
    return maps.map((m) {
      final model = LocalModel.fromMap(m);
      final resolvedPath = p.join(modelsDir, model.filename);
      if (resolvedPath == model.filePath) return model;
      return model.copyWith(filePath: resolvedPath);
    }).toList();
  }

  Future<List<LocalModel>> getAllModels() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('local_models', orderBy: 'created_at DESC');
    return _resolveModels(maps);
  }

  Future<List<LocalModel>> getCompletedModels() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('local_models',
        where: 'status = ?', whereArgs: ['completed']);
    return _resolveModels(maps);
  }

  Future<LocalModel?> getModel(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps =
        await db.query('local_models', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    final resolved = await _resolveModels(maps);
    return resolved.first;
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
      final resolved = await _resolveModels(maps);
      final model = resolved.first;
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
