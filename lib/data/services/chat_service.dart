import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/chat_message_model.dart';

class ChatService {
  static Future<ChatMessage> sendMessage(
      String sessionId, String message) async {
    final res = await http
        .post(
          Uri.parse(ApiConstants.chat),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'session_id': sessionId, 'message': message}),
        )
        .timeout(const Duration(seconds: 60));

    if (res.statusCode == 200) {
      return ChatMessage.fromJson(jsonDecode(res.body));
    }
    final err = jsonDecode(res.body)['error'] ?? 'AI gagal merespons';
    throw Exception(err);
  }

  static Future<List<ChatMessage>> getHistory(String sessionId) async {
    final res = await http
        .get(Uri.parse(ApiConstants.chatHistory(sessionId)))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ChatMessage.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat riwayat chat');
  }

  static Future<void> clearHistory(String sessionId) async {
    await http
        .delete(Uri.parse(ApiConstants.chatHistory(sessionId)))
        .timeout(const Duration(seconds: 15));
  }
}
