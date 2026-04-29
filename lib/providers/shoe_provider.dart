import 'package:flutter/material.dart';
import '../data/models/shoe_model.dart';
import '../data/services/shoe_service.dart';

class ShoeProvider extends ChangeNotifier {
  List<Shoe> _shoes   = [];
  int    _page        = 1;
  bool   _isLoading   = false;
  bool   _hasMore     = true;
  String? _error;
  String? _category;
  String  _search     = '';

  List<Shoe> get shoes     => _shoes;
  bool       get isLoading => _isLoading;
  bool       get hasMore   => _hasMore;
  String?    get error     => _error;
  String?    get category  => _category;

  Future<void> fetchShoes() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    _error     = null;
    notifyListeners();

    try {
      final result = await ShoeService.getShoes(
        page:     _page,
        perPage:  10,
        category: _category,
        search:   _search.isNotEmpty ? _search : null,
      );
      final List data = result['data'] as List;
      if (data.isEmpty) {
        _hasMore = false;
      } else {
        _shoes.addAll(data.map((e) => Shoe.fromJson(e)));
        _page++;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter({String? category, String search = ''}) {
    _category = category;
    _search   = search;
    _shoes.clear();
    _page    = 1;
    _hasMore = true;
    notifyListeners();
    fetchShoes();
  }

  void reset() {
    _shoes.clear();
    _page    = 1;
    _hasMore = true;
    _category = null;
    _search   = '';
    _error    = null;
    notifyListeners();
  }
}
