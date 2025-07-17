import 'package:flutter/foundation.dart';
import 'package:marketnest/models/product_model.dart';
import 'package:marketnest/models/category_model.dart';
import 'package:marketnest/services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _bestSellers = [];
  List<CategoryModel> _categories = [];
  ProductModel? _selectedProduct;
  
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get bestSellers => _bestSellers;
  List<CategoryModel> get categories => _categories;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts({
    int limit = 20,
    int offset = 0,
    String? category,
    String? search,
  }) async {
    _setLoading(true);
    try {
      _products = await _apiService.getProducts(
        limit: limit,
        offset: offset,
        category: category,
        search: search,
      );
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFeaturedProducts() async {
    try {
      _featuredProducts = await _apiService.getProducts(limit: 10);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadBestSellers() async {
    try {
      _bestSellers = await _apiService.getProducts(limit: 10);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _apiService.getCategories();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadProduct(String id) async {
    _setLoading(true);
    try {
      _selectedProduct = await _apiService.getProduct(id);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchProducts(String query) async {
    _setLoading(true);
    try {
      _products = await _apiService.getProducts(search: query);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProductsByCategory(String categoryId) async {
    _setLoading(true);
    try {
      _products = await _apiService.getProducts(category: categoryId);
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