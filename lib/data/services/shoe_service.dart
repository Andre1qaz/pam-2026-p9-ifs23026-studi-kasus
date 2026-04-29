import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/shoe_model.dart';

class ShoeService {
  static Future<Map<String, dynamic>> getShoes({
    int page = 1,
    int perPage = 10,
    String? category,
    String? search,
  }) async {
    var uri = Uri.parse(ApiConstants.shoes).replace(queryParameters: {
      'page':     '$page',
      'per_page': '$perPage',
      if (category != null) 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
    });

    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Gagal memuat katalog sepatu');
  }

  static Future<Shoe> getShoeDetail(int id) async {
    final res = await http
        .get(Uri.parse(ApiConstants.shoeDetail(id)))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) return Shoe.fromJson(jsonDecode(res.body));
    throw Exception('Sepatu tidak ditemukan');
  }
}
