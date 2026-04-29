import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _userCtrl   = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool  _obscure    = true;

  late AnimationController _anim;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _anim  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade  = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().login(
      _userCtrl.text.trim(), _passCtrl.text,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<AuthProvider>().error ?? 'Login gagal'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? [const Color(0xFF0D0D1A), const Color(0xFF1A1A2E)]
                : [const Color(0xFFF7F0E6), const Color(0xFFFFF3E0)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Logo ────────────────────────────────────
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.4),
                            blurRadius: 20, offset: const Offset(0, 8),
                          )],
                        ),
                        child: const Icon(Icons.directions_walk_rounded,
                            color: Colors.white, size: 46),
                      ),
                      const SizedBox(height: 20),
                      Text('Sole AI',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Shoe Advisor Powered by AI',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 36),

                      // ── Form Card ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF1A1A2E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24, offset: const Offset(0, 8),
                          )],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Masuk ke Akun',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 4),
                              Text('Hanya akun yang terdaftar dapat menggunakan fitur AI.',
                                  style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 20),

                              TextFormField(
                                controller: _userCtrl,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                                validator: (v) =>
                                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                              ),
                              const SizedBox(height: 14),

                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Wajib diisi' : null,
                              ),
                              const SizedBox(height: 24),

                              Consumer<AuthProvider>(
                                builder: (_, auth, __) => SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : _submit,
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            height: 20, width: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white))
                                        : const Text('Masuk'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Info akun ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.accent.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.info_outline,
                                  color: AppTheme.accent, size: 15),
                              const SizedBox(width: 8),
                              Text('Akun Pengujian',
                                  style: TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ]),
                            const SizedBox(height: 8),
                            _credRow('admin', 'sepatu2026'),
                            const SizedBox(height: 4),
                            _credRow('dosen', 'praktikum9'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _credRow(String u, String p) => Row(children: [
        const Icon(Icons.circle, size: 5, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$u / $p',
            style: const TextStyle(
                fontSize: 12, fontFamily: 'monospace', color: Colors.grey)),
      ]);
}
