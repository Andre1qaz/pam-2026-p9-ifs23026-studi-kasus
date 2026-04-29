import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User?   _user;
  bool    _isLoading = false;
  String? _error;

  User?   get user      => _user;
  bool    get isLoggedIn => _user != null;
  bool    get isLoading  => _isLoading;
  String? get error      => _error;

  Future<void> checkSession() async {
    _user = await AuthService.getSavedUser();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error     = null;
    notifyListeners();

    try {
      _user = await AuthService.login(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error     = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}
