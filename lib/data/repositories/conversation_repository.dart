import 'package:shiba/data/database/database_helper.dart';
import 'package:shiba/data/models/conversation.dart';
import 'package:shiba/data/models/message.dart';

class ConversationRepository {
  Future<List<Conversation>> getAllConversations() async {
    final db = await DatabaseHelper.instance.database;
    final maps =
        await db.query('conversations', orderBy: 'updated_at DESC');
    return maps.map((m) => Conversation.fromMap(m)).toList();
  }

  Future<Conversation?> getConversation(String id) async {
    final db = await DatabaseHelper.instance.database;
    final maps =
        await db.query('conversations', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Conversation.fromMap(maps.first);
  }

  Future<void> insertConversation(Conversation conversation) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('conversations', conversation.toMap());
  }

  Future<void> updateConversation(Conversation conversation) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('conversations', conversation.toMap(),
        where: 'id = ?', whereArgs: [conversation.id]);
  }

  Future<void> deleteConversation(String id) async {
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    batch.delete('messages', where: 'conversation_id = ?', whereArgs: [id]);
    batch.delete('conversations', where: 'id = ?', whereArgs: [id]);
    await batch.commit(noResult: true);
  }

  Future<List<Message>> getMessages(String conversationId) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('messages',
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
        orderBy: 'created_at ASC');
    return maps.map((m) => Message.fromMap(m)).toList();
  }

  Future<void> insertMessage(Message message) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('messages', message.toMap());
  }

  Future<void> updateMessage(Message message) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('messages', message.toMap(),
        where: 'id = ?', whereArgs: [message.id]);
  }

  Future<void> deleteMessage(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete multiple messages by their IDs.
  Future<void> deleteMessagesByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await DatabaseHelper.instance.database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete(
      'messages',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  /// Delete a message and all messages created at or after it in the same
  /// conversation. Uses both created_at and rowid ordering to handle the
  /// edge case where two messages share the same millisecond timestamp.
  Future<void> deleteMessagesFrom(String conversationId, String messageId) async {
    final db = await DatabaseHelper.instance.database;
    // Look up the target message's timestamp to use as boundary
    final maps = await db.query('messages',
        columns: ['created_at', 'rowid'],
        where: 'id = ?',
        whereArgs: [messageId]);
    if (maps.isEmpty) return;
    final fromTime = maps.first['created_at'] as int;
    final fromRowid = maps.first['rowid'] as int;
    // Delete messages that are strictly newer, OR share the same timestamp
    // but were inserted at or after the target message (by rowid).
    await db.delete(
      'messages',
      where: 'conversation_id = ? AND (created_at > ? OR (created_at = ? AND rowid >= ?))',
      whereArgs: [conversationId, fromTime, fromTime, fromRowid],
    );
  }
}
