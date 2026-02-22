enum MessageRole { user, assistant, system }

class Message {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final String? imagePath;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.imagePath,
    required this.createdAt,
  });

  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  Map<String, dynamic> toMap() => {
        'id': id,
        'conversation_id': conversationId,
        'role': role.name,
        'content': content,
        'image_path': imagePath,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory Message.fromMap(Map<String, dynamic> map) => Message(
        id: map['id'] as String,
        conversationId: map['conversation_id'] as String,
        role: MessageRole.values.byName(map['role'] as String),
        content: map['content'] as String,
        imagePath: map['image_path'] as String?,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );

  Message copyWith({String? content, String? imagePath}) => Message(
        id: id,
        conversationId: conversationId,
        role: role,
        content: content ?? this.content,
        imagePath: imagePath ?? this.imagePath,
        createdAt: createdAt,
      );
}
