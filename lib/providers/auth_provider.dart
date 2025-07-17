import 'package:flutter/foundation.dart';
import 'package:marketnest/models/customer_model.dart';
import 'package:marketnest/services/auth_service.dart';
import 'package:marketnest/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String? _error;

  AuthProvider() : _authService = AuthService(ApiService());

  bool get isLoading => _isLoading;
  String? get error => _error;
  CustomerModel? get currentCustomer => _authService.currentCustomer;
  bool get isAuthenticated => _authService.isAuthenticated;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _authService.loadStoredCustomer();
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final success = await _authService.login(email, password);
      if (success) {
        _clearError();
        notifyListeners();
        return true;
      } else {
        _setError('Invalid credentials');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signup(String firstName, String lastName, String email, String password) async {
    _setLoading(true);
    try {
      final success = await _authService.signup(firstName, lastName, email, password);
      if (success) {
        _clearError();
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}