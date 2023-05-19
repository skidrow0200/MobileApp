import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? _email;
  String? _token;
  bool _isAuthenticated = false;

  String? get email => _email;
  String? get token => _token;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  void setIsAuthenticated(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    notifyListeners();
  }

  bool get isAuthenticated => _isAuthenticated;
}
