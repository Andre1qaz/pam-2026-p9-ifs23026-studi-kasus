class ChatMessage {
  final int? id;
  final String role;     // 'user' | 'assistant'
  final String message;
  final String? createdAt;

  ChatMessage({
    this.id,
    required this.role,
    required this.message,
    this.createdAt,
  });

  bool get isUser => role == 'user';

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id:        j['id'] as int?,
        role:      j['role'] as String,
        message:   j['message'] as String,
        createdAt: j['created_at'] as String?,
      );

  // Helper untuk pesan sementara (optimistic UI)
  factory ChatMessage.user(String text) =>
      ChatMessage(role: 'user', message: text);
  factory ChatMessage.thinking() =>
      ChatMessage(role: 'assistant', message: '__thinking__');
}
