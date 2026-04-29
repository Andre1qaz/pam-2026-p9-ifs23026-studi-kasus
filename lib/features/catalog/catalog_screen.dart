import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/shoe_provider.dart';
import '../../core/helpers/format_helper.dart';
import '../../core/theme/app_theme.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _scrollCtrl  = ScrollController();
  final _searchCtrl  = TextEditingController();
  String? _activeCategory;

  static const _categories = [
    null, 'running', 'casual', 'lifestyle', 'walking', 'boots',
  ];
  static const _categoryLabels = [
    'Semua', 'Running', 'Casual', 'Lifestyle', 'Walking', 'Boots',
  ];

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<ShoeProvider>().fetchShoes();
    }
  }

  void _applyFilter([String? category]) {
    _activeCategory = category;
    context.read<ShoeProvider>().setFilter(
          category: category,
          search: _searchCtrl.text,
        );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoeProvider>();

    return Column(
      children: [
        // ── Search bar ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Cari sepatu atau brand...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchCtrl.clear();
                        _applyFilter(_activeCategory);
                      })
                  : null,
            ),
            onSubmitted: (_) => _applyFilter(_activeCategory),
            onChanged: (v) {
              if (v.isEmpty) _applyFilter(_activeCategory);
              setState(() {});
            },
          ),
        ),

        // ── Filter kategori (chip horizontal) ────────────────────
        SizedBox(
          height: 52,
          child: ListView.separated(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final active = _activeCategory == _categories[i];
              return GestureDetector(
                onTap: () {
                  setState(() => _activeCategory = _categories[i]);
                  _applyFilter(_categories[i]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          active ? AppTheme.accent : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    _categoryLabels[i],
                    style: TextStyle(
                      color: active ? Colors.white : Colors.grey,
                      fontWeight: active
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── List sepatu ──────────────────────────────────────────
        Expanded(
          child: _buildList(provider),
        ),
      ],
    );
  }

  Widget _buildList(ShoeProvider provider) {
    if (provider.isLoading && provider.shoes.isEmpty) {
      return _buildShimmer();
    }
    if (provider.error != null && provider.shoes.isEmpty) {
      return _buildError(provider);
    }
    if (!provider.isLoading && provider.shoes.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ShoeProvider>().setFilter(
              category: _activeCategory,
              search: _searchCtrl.text,
            );
      },
      color: AppTheme.accent,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: provider.shoes.length + 1,
        itemBuilder: (_, i) {
          if (i < provider.shoes.length) {
            return _ShoeCard(shoe: provider.shoes[i]);
          }
          if (provider.isLoading) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: CircularProgressIndicator(color: AppTheme.accent)),
            );
          }
          if (!provider.hasMore) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '— ${provider.shoes.length} sepatu ditampilkan —',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildShimmer() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Shimmer.fromColors(
          baseColor:
              dark ? const Color(0xFF1E1E2E) : const Color(0xFFE2E8F0),
          highlightColor:
              dark ? const Color(0xFF2A2A3E) : const Color(0xFFF8FAFC),
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(ShoeProvider p) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 64, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(p.error ?? 'Terjadi kesalahan',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<ShoeProvider>().fetchShoes(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('Sepatu tidak ditemukan',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
}

// ── Kartu sepatu ─────────────────────────────────────────────────────────────
class _ShoeCard extends StatelessWidget {
  final shoe;
  const _ShoeCard({required this.shoe});

  static const _categoryColors = {
    'running':   [Color(0xFFE94560), Color(0xFFFF6B6B)],
    'casual':    [Color(0xFF0F3460), Color(0xFF16213E)],
    'lifestyle': [Color(0xFF6C63FF), Color(0xFF3F3D56)],
    'walking':   [Color(0xFF11998E), Color(0xFF38EF7D)],
    'boots':     [Color(0xFF8B4513), Color(0xFFD2691E)],
  };

  @override
  Widget build(BuildContext context) {
    final colors = _categoryColors[shoe.category] ??
        [const Color(0xFF1A1A2E), const Color(0xFF16213E)];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // ── Badge warna kategori ─────────────────────────────
          Container(
            width: 8,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft:    Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
          ),
          // ── Ikon sepatu ─────────────────────────────────────
          Container(
            width: 72, height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors[0].withValues(alpha: 0.1),
                  colors[1].withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Center(
              child: Text(
                _shoeEmoji(shoe.category),
                style: const TextStyle(fontSize: 34),
              ),
            ),
          ),
          // ── Info ─────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shoe.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shoe.brand,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors[0].withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          shoe.category.toUpperCase(),
                          style: TextStyle(
                              color: colors[0],
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    FormatHelper.currency(shoe.price),
                    style: TextStyle(
                      color: colors[0],
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shoeEmoji(String category) {
    switch (category) {
      case 'running':   return '👟';
      case 'casual':    return '👠';
      case 'lifestyle': return '🥿';
      case 'walking':   return '🚶';
      case 'boots':     return '🥾';
      default:          return '👟';
    }
  }
}
