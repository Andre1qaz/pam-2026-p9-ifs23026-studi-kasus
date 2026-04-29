import 'package:flutter/material.dart';
import '../data/models/chat_message_model.dart';
import '../data/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final String sessionId;

  ChatProvider({required this.sessionId});

  List<ChatMessage> _messages  = [];
  bool              _isSending = false;
  bool              _isLoading = false;
  String?           _error;

  List<ChatMessage> get messages  => _messages;
  bool              get isSending => _isSending;
  bool              get isLoading => _isLoading;
  String?           get error     => _error;

  // Muat riwayat dari server saat chat dibuka
  Future<void> loadHistory() async {
    _isLoading = true;
    _error     = null;
    notifyListeners();

    try {
      _messages = await ChatService.getHistory(sessionId);
    } catch (_) {
      _messages = []; // mulai fresh jika gagal ambil history
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kirim pesan user ke AI
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    _isSending = true;
    _error     = null;

    // Optimistic UI: tampilkan pesan user + bubble "thinking" langsung
    _messages.add(ChatMessage.user(text));
    _messages.add(ChatMessage.thinking());
    notifyListeners();

    try {
      final reply = await ChatService.sendMessage(sessionId, text);

      // Hapus bubble thinking, ganti dengan balasan AI
      _messages.removeLast();
      _messages.add(reply);
    } catch (e) {
      _messages.removeLast();
      _error = e.toString().replaceFirst('Exception: ', '');
      _messages.add(ChatMessage(
        role:    'assistant',
        message: 'Maaf, terjadi kesalahan. Coba lagi.',
      ));
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    await ChatService.clearHistory(sessionId);
    _messages.clear();
    notifyListeners();
  }
}
