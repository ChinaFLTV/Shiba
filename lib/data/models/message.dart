enum MessageRole { user, assistant, system }

class Message {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'conversation_id': conversationId,
        'role': role.name,
        'content': content,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Message.fromMap(Map<String, dynamic> map) => Message(
        id: map['id'] as String,
        conversationId: map['conversation_id'] as String,
        role: MessageRole.values.byName(map['role'] as String),
        content: map['content'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );

  Message copyWith({String? content}) => Message(
        id: id,
        conversationId: conversationId,
        role: role,
        content: content ?? this.content,
        createdAt: createdAt,
      );
}
