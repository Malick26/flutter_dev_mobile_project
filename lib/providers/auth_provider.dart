import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email, password);

    _isLoading = false;
    if (result['success']) {
      _user = result['user'];
      _token = result['token'];
      notifyListeners();
      return true;
    } else {
      print('Erreur de connexion : ${result['message']}');
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<void> loadUser() async {
    _user = await _authService.getUser();
    _token = await _authService.getToken();
    notifyListeners();
  }

  Future<bool> register(Map<String, dynamic> userData) async {
  _isLoading = true;
  notifyListeners();

  final result = await _authService.register(userData);

  _isLoading = false;
  if (result['success']) {
    _user = result['user'];
    _token = result['token'];
    notifyListeners();
    return true;
  } else {
    print('Erreur d’inscription : ${result['message']}');
    return false;
  }
}

}
