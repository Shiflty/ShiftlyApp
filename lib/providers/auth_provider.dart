import 'package:flutter/material.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/services/google_drive_service.dart';
import 'package:shiftly/services/persistence_service.dart';

enum AuthType { guest, byos, shiftlyAccount }

class AuthProvider with ChangeNotifier {
  final PersistenceService _persistence;
  final ApiService _apiService = ApiService();
  final GoogleDriveService _driveService = GoogleDriveService();

  AuthProvider(this._persistence) {
    _loadAuthState();
  }

  bool _isLoggedIn = false;
  AuthType _authType = AuthType.guest;
  String? _userName;
  String? _userEmail;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;

  AuthType get authType => _authType;

  String? get userName => _userName;

  String? get userEmail => _userEmail;

  String? get token => _token;

  void _loadAuthState() {
    final box = _persistence.settingsBox;
    _isLoggedIn = box.get('isLoggedIn', defaultValue: false);
    _authType = AuthType
        .values[box.get('authType', defaultValue: AuthType.guest.index)];
    _userName = box.get('userName');
    _userEmail = box.get('userEmail');
    _token = box.get('token');
    notifyListeners();
  }

  Future<void> connectBYOS() async {
    try {
      final account = await _driveService.signIn();
      if (account != null) {
        _isLoggedIn = true;
        _authType = AuthType.byos;
        _userEmail = account.email;
        _userName = null; // Anonymous on home screen

        final box = _persistence.settingsBox;
        await box.put('isLoggedIn', true);
        await box.put('authType', _authType.index);
        await box.put('userEmail', _userEmail);
        await box.delete('userName');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('BYOS connection failed: $e');
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    final data = await _apiService.login(email, password);
    _isLoggedIn = true;
    _authType = AuthType.shiftlyAccount;
    _userEmail = data['user']['email'];
    _userName = data['user']['name'];
    _token = data['token'];
    await _saveToPersistence();
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    final data = await _apiService.register(name, email, password);
    _isLoggedIn = true;
    _authType = AuthType.shiftlyAccount;
    _userName = data['user']['name'];
    _userEmail = data['user']['email'];
    _token = data['token'];
    await _saveToPersistence();
    notifyListeners();
  }

  Future<void> _saveToPersistence() async {
    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', true);
    await box.put('authType', _authType.index);
    await box.put('userEmail', _userEmail);
    await box.put('userName', _userName);
    await box.put('token', _token);
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
    if (_authType == AuthType.byos) await _driveService.signOut();
    _isLoggedIn = false;
    _authType = AuthType.guest;
    _userName = null;
    _userEmail = null;
    _token = null;
    final box = _persistence.settingsBox;
    await box.put('isLoggedIn', false);
    await box.put('authType', _authType.index);
    await box.delete('userEmail');
    await box.delete('userName');
    await box.delete('token');
    notifyListeners();
  }
}
