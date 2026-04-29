import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<User> login(String username, String password) async {
    final res = await http
        .post(
          Uri.parse(ApiConstants.authLogin),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final user = User.fromJson(data['user']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.id);
      await prefs.setString('username', user.username);
      return user;
    }
    final err = jsonDecode(res.body)['error'] ?? 'Login gagal';
    throw Exception(err);
  }

  static Future<void> logout() async {
    await http
        .post(Uri.parse(ApiConstants.authLogout))
        .timeout(const Duration(seconds: 10));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id       = prefs.getInt('user_id');
    final username = prefs.getString('username');
    if (id != null && username != null) {
      return User(id: id, username: username);
    }
    return null;
  }
}
