import 'package:flutter/foundation.dart';
import 'package:koutonou/models/product_model.dart';
import 'package:koutonou/models/category_model.dart';
import 'package:koutonou/services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _bestSellers = [];
  List<CategoryModel> _categories = [];
  ProductModel? _selectedProduct;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  int _currentOffset = 0;
  final int _limit = 20;

  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get bestSellers => _bestSellers;
  List<CategoryModel> get categories => _categories;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  /// Chargement initial ou rechargement avec reset
  Future<void> loadProducts({
    String? category,
    String? search,
    bool reset = true,
  }) async {
    if (reset) {
      _setLoading(true);
      _products.clear();
      _currentOffset = 0;
      _hasMore = true;
    } else {
      if (_isLoadingMore || !_hasMore) return;
      _setLoadingMore(true);
    }

    try {
      final fetchedProducts = await _apiService.getProducts(
        limit: _limit,
        offset: _currentOffset,
        category: category,
        search: search,
      );

      if (reset) {
        _products = fetchedProducts;
      } else {
        _products.addAll(fetchedProducts);
      }

      _currentOffset += fetchedProducts.length;
      _hasMore = fetchedProducts.length == _limit;

      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      if (reset) {
        _setLoading(false);
      } else {
        _setLoadingMore(false);
      }
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
    await loadProducts(search: query, reset: true);
  }

  Future<void> loadProductsByCategory(String categoryId) async {
    await loadProducts(category: categoryId, reset: true);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMore(bool loadingMore) {
    _isLoadingMore = loadingMore;
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

  /// Permet le chargement de la page suivante lors d'un scroll infini
  Future<void> loadMoreProducts({
    String? category,
    String? search,
  }) async {
    await loadProducts(category: category, search: search, reset: false);
  }
}
