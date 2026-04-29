import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_notifier.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shoe_provider.dart';
import '../catalog/catalog_screen.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _pages = [
    CatalogScreen(),
    ChatScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch katalog pertama kali
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShoeProvider>().fetchShoes();
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              context.read<ShoeProvider>().reset();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthProvider>();
    final theme = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_walk_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sole AI',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17)),
                Text('Halo, ${auth.user?.username ?? ""}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(theme.isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: theme.toggleTheme,
            tooltip: 'Ganti Tema',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _showLogoutDialog,
            tooltip: 'Keluar',
          ),
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) =>
            setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon:         Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label:        'Katalog',
          ),
          NavigationDestination(
            icon:         Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label:        'Sole AI Chat',
          ),
        ],
      ),
    );
  }
}
