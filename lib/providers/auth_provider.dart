import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  String? get errorMessage => _errorMessage;

  // Demo users — replace with Firebase Auth later
  static final List<UserModel> _demoUsers = [
    const UserModel(
      id: 'admin1',
      email: 'admin@hastane.gov.tr',
      displayName: 'Admin Kullanıcı',
      role: UserRole.admin,
    ),
    const UserModel(
      id: 'user1',
      email: 'kullanici@hastane.gov.tr',
      displayName: 'Personel Kullanıcı',
      role: UserRole.user,
    ),
  ];

  AuthProvider() {
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
      final user = _demoUsers.firstWhere(
        (u) => u.email == savedEmail,
        orElse: () => _demoUsers.last,
      );
      _currentUser = user;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Demo login logic — replace with Firebase Auth
    final user = _demoUsers.where((u) => u.email == email).firstOrNull;

    if (user == null || password != '1234') {
      _errorMessage = 'E-posta veya şifre hatalı.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _currentUser = user;
    _isLoading = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
