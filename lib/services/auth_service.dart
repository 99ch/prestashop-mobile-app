import 'package:shared_preferences/shared_preferences.dart';
import 'package:koutonou/models/customer_model.dart';
import 'package:koutonou/services/api_service.dart';

class AuthService {
  static const String _customerKey = 'customer_data';
  static const String _tokenKey = 'auth_token';
  
  final ApiService _apiService;
  CustomerModel? _currentCustomer;

  AuthService(this._apiService);

  CustomerModel? get currentCustomer => _currentCustomer;
  
  bool get isAuthenticated => _currentCustomer != null;

  Future<void> loadStoredCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    final customerData = prefs.getString(_customerKey);
    
    if (customerData != null) {
      try {
        final json = customerData.split(',');
        _currentCustomer = CustomerModel(
          id: json[0],
          firstName: json[1],
          lastName: json[2],
          email: json[3],
          active: json[4] == 'true',
        );
      } catch (e) {
        await logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      
      if (response['success'] == true && response['customer'] != null) {
        _currentCustomer = CustomerModel.fromJson(response['customer']);
        await _storeCustomerData(_currentCustomer!);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signup(String firstName, String lastName, String email, String password) async {
    try {
      final customer = CustomerModel(
        id: '',
        firstName: firstName,
        lastName: lastName,
        email: email,
        active: true,
      );
      
      final response = await _apiService.signup(customer, password);
      
      if (response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentCustomer = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_customerKey);
    await prefs.remove(_tokenKey);
  }

  Future<void> _storeCustomerData(CustomerModel customer) async {
    final prefs = await SharedPreferences.getInstance();
    final customerData = '${customer.id},${customer.firstName},${customer.lastName},${customer.email},${customer.active}';
    await prefs.setString(_customerKey, customerData);
  }
}