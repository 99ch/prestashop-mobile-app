import 'package:flutter/foundation.dart';
import 'package:koutonou/models/cart_model.dart';
import 'package:koutonou/models/product_model.dart';
import 'package:koutonou/services/cart_service.dart';
import 'package:koutonou/services/api_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService;
  bool _isLoading = false;
  String? _error;

  CartProvider() : _cartService = CartService(ApiService());

  CartModel? get cart => _cartService.cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => cart?.itemCount ?? 0;
  double get total => cart?.total ?? 0.0;

  Future<void> loadCart(String customerId) async {
    _setLoading(true);
    try {
      await _cartService.loadCart(customerId);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    try {
      await _cartService.addToCart(product, quantity);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      await _cartService.removeFromCart(productId);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      await _cartService.updateQuantity(productId, quantity);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  int getProductQuantity(String productId) {
    return _cartService.getProductQuantity(productId);
  }

  bool isInCart(String productId) {
    return _cartService.isInCart(productId);
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