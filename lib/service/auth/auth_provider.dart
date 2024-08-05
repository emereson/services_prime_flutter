import 'package:flutter/material.dart';
import 'package:tecnyapp_flutter/service/auth/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;

  bool get isAuthenticated => _token != null;

  Future<void> loadToken() async {
    final token = await AuthService.getToken();
    _token = token;
    notifyListeners();
  }

  Future<void> setToken(String token) async {
    await AuthService.saveToken(token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.removeToken();
    _token = null;
    notifyListeners();
  }
}
