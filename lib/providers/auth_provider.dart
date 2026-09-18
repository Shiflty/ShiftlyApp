import 'package:flutter/material.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/services/persistence_service.dart';

class AuthProvider with ChangeNotifier {
  final PersistenceService _persistence;
  final ApiService _apiService = ApiService();

  AuthProvider(this._persistence) {
    _loadAuthState();
  }

  bool _isLoggedIn = false;
  String? _userName;
  String? _userEmail;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;

  String? get userName => _userName;

  String? get userEmail => _userEmail;

  String? get token => _token;

  void _loadAuthState() {
    final box = _persistence.settingsBox;
    _isLoggedIn = box.get('isLoggedIn', defaultValue: false);
    _userName = box.get('userName');
    _userEmail = box.get('userEmail');
    _token = box.get('token');
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final data = await _apiService.login(email, password);

    _isLoggedIn = true;
    _userEmail = data['user']['email'];
    _userName = data['user']['name'];
    _token = data['token'];

    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', true);
    await box.put('userEmail', _userEmail);
    await box.put('userName', _userName);
    await box.put('token', _token);

    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    final data = await _apiService.register(name, email, password);

    _isLoggedIn = true;
    _userName = data['user']['name'];
    _userEmail = data['user']['email'];
    _token = data['token'];

    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', true);
    await box.put('userEmail', _userEmail);
    await box.put('userName', _userName);
    await box.put('token', _token);

    notifyListeners();
  }

  Future<void> updateProfile(String name, String email) async {
    if (_token == null) return;
    final data = await _apiService.updateProfile(_token!, name, email);
    
    _userName = data['name'];
    _userEmail = data['email'];

    final box = _persistence.settingsBox;
    await box.put('userName', _userName);
    await box.put('userEmail', _userEmail);
    
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = null;
    _userEmail = null;
    _token = null;

    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', false);
    await box.delete('userEmail');
    await box.delete('userName');
    await box.delete('token');

    notifyListeners();
  }
}
