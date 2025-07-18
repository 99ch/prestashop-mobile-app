import 'package:flutter/foundation.dart';
import 'package:koutonou/models/vendor_model.dart';
import 'package:koutonou/models/product_model.dart';
import 'package:koutonou/services/api_service.dart';

class VendorProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<VendorModel> _vendors = [];
  VendorModel? _selectedVendor;
  List<ProductModel> _vendorProducts = [];
  
  bool _isLoading = false;
  String? _error;

  List<VendorModel> get vendors => _vendors;
  VendorModel? get selectedVendor => _selectedVendor;
  List<ProductModel> get vendorProducts => _vendorProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVendors() async {
    _setLoading(true);
    try {
      _vendors = await _apiService.getVendors();
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadVendor(String id) async {
    _setLoading(true);
    try {
      _selectedVendor = await _apiService.getVendor(id);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadVendorProducts(String vendorId) async {
    _setLoading(true);
    try {
      _vendorProducts = await _apiService.getVendorProducts(vendorId);
      _clearError();
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
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}