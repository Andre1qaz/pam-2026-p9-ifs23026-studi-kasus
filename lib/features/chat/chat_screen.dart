import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/chat_message_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();

  late ChatProvider _chatProvider;
  bool _initialized = false;

  // Session ID unik per install — gunakan SharedPreferences jika perlu persist
  static final String _sessionId = const Uuid().v4();

  static const _suggestions = [
    '👟 Rekomendasikan sepatu lari terbaik',
    '💰 Sepatu kasual di bawah Rp1 juta',
    '⚖️  Bandingkan Nike dan Adidas',
    '🌧️  Sepatu tahan hujan untuk outdoor',
    '🎓 Sepatu untuk mahasiswa aktif',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized   = true;
      _chatProvider  = ChatProvider(sessionId: _sessionId);
      _chatProvider.loadHistory();
    }
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? text]) async {
    final msg = text ?? _inputCtrl.text.trim();
    if (msg.isEmpty || _chatProvider.isSending) return;
    _inputCtrl.clear();
    await _chatProvider.sendMessage(msg);
    _scrollToBottom();
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Percakapan'),
        content:
            const Text('Semua riwayat chat akan dihapus. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _chatProvider.clearChat();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _chatProvider,
      child: Consumer<ChatProvider>(
        builder: (context, chat, _) {
          // Scroll ke bawah setiap kali ada pesan baru
          if (chat.messages.isNotEmpty) _scrollToBottom();

          return Column(
            children: [
              // ── Header info ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A1A2E)
                    : Colors.white,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.smart_toy_rounded,
                          color: AppTheme.accent, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sole AI',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        Row(children: [
                          Container(
                            width: 7, height: 7,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Text('Online — Ahli Sepatu',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ]),
                      ],
                    ),
                    const Spacer(),
                    if (chat.messages.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.grey, size: 20),
                        onPressed: _confirmClear,
                        tooltip: 'Hapus Percakapan',
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // ── Daftar pesan ─────────────────────────────────────
              Expanded(
                child: chat.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.accent))
                    : chat.messages.isEmpty
                        ? _buildWelcome()
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            itemCount: chat.messages.length,
                            itemBuilder: (_, i) =>
                                _ChatBubble(msg: chat.messages[i]),
                          ),
              ),

              // ── Quick suggestions (hanya saat kosong) ─────────
              if (chat.messages.isEmpty)
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _send(_suggestions[i]
                          .replaceAll(RegExp(r'^[^\s]+ '), '')),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                AppTheme.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _suggestions[i],
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.accent),
                        ),
                      ),
                    ),
                  ),
                ),

              if (chat.messages.isEmpty) const SizedBox(height: 8),

              // ── Input bar ─────────────────────────────────────────
              _buildInputBar(chat),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppTheme.accent, size: 52),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hai! Saya Sole AI 👋',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              'Saya siap membantu Anda menemukan sepatu yang tepat.\n'
              'Coba tanyakan rekomendasi, perbandingan, atau harga sepatu!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.6),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih pertanyaan cepat di bawah atau ketik sendiri.',
              style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ChatProvider chat) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1A2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                enabled: !chat.isSending,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: 'Tanya tentang sepatu...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: chat.isSending
                    ? Colors.grey
                    : AppTheme.accent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: chat.isSending
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white))
                    : const Icon(Icons.send_rounded,
                        color: Colors.white),
                onPressed: chat.isSending ? null : _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bubble percakapan ─────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final ChatMessage msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser    = msg.isUser;
    final thinking  = msg.message == '__thinking__';
    final dark      = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar AI
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: const BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 18),
            ),
          ],

          // Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.accent
                    : (dark
                        ? const Color(0xFF1E1E2E)
                        : const Color(0xFFF1F3F5)),
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: thinking
                  ? _ThinkingIndicator()
                  : Text(
                      msg.message,
                      style: TextStyle(
                        color: isUser ? Colors.white : null,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
            ),
          ),

          // Avatar user
          if (isUser) ...[
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(left: 8, bottom: 2),
              decoration: BoxDecoration(
                color: AppTheme.accent2,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

// Animasi titik-titik "thinking" 
class _ThinkingIndicator extends StatefulWidget {
  @override
  State<_ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<_ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: const Text(
        'Sole AI sedang berpikir...',
        style: TextStyle(
            color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
      ),
    );
  }
}
