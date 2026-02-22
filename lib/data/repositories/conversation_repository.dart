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
    await db.delete('messages',
        where: 'conversation_id = ?', whereArgs: [id]);
    await db.delete('conversations', where: 'id = ?', whereArgs: [id]);
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

  /// Delete a message and all messages after it in the same conversation.
  Future<void> deleteMessagesFrom(String conversationId, DateTime fromTime) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'messages',
      where: 'conversation_id = ? AND created_at >= ?',
      whereArgs: [conversationId, fromTime.millisecondsSinceEpoch],
    );
  }
}
