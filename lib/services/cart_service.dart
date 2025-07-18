import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:koutonou/models/cart_model.dart';
import 'package:koutonou/models/product_model.dart';
import 'package:koutonou/services/api_service.dart';

class CartService {
  static const String _cartKey = 'local_cart';
  final ApiService _apiService;
  CartModel? _cart;

  CartService(this._apiService);

  CartModel? get cart => _cart;

  Future<void> loadCart(String customerId) async {
    try {
      // Try to load from API first
      _cart = await _apiService.getCart(customerId);
    } catch (e) {
      // Fallback to local storage
      await _loadLocalCart(customerId);
    }
  }

  Future<void> _loadLocalCart(String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString(_cartKey);
    
    if (cartData != null) {
      try {
        final json = jsonDecode(cartData);
        _cart = CartModel.fromJson(json);
      } catch (e) {
        _cart = CartModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          customerId: customerId,
          items: [],
          dateAdd: DateTime.now(),
          dateUpd: DateTime.now(),
        );
      }
    } else {
      _cart = CartModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: customerId,
        items: [],
        dateAdd: DateTime.now(),
        dateUpd: DateTime.now(),
      );
    }
  }

  Future<void> addToCart(ProductModel product, int quantity) async {
    if (_cart == null) return;

    final existingItemIndex = _cart!.items.indexWhere((item) => item.product.id == product.id);
    
    if (existingItemIndex != -1) {
      _cart!.items[existingItemIndex].quantity += quantity;
    } else {
      final cartItem = CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        price: product.priceAsDouble,
      );
      _cart!.items.add(cartItem);
    }

    await _saveCart();
  }

  Future<void> removeFromCart(String productId) async {
    if (_cart == null) return;

    _cart!.items.removeWhere((item) => item.product.id == productId);
    await _saveCart();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (_cart == null) return;

    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final itemIndex = _cart!.items.indexWhere((item) => item.product.id == productId);
    if (itemIndex != -1) {
      _cart!.items[itemIndex].quantity = quantity;
      await _saveCart();
    }
  }

  Future<void> clearCart() async {
    if (_cart == null) return;

    _cart!.items.clear();
    await _saveCart();
  }

  Future<void> _saveCart() async {
    if (_cart == null) return;

    final prefs = await SharedPreferences.getInstance();
    final cartData = jsonEncode(_cart!.toJson());
    await prefs.setString(_cartKey, cartData);
  }

  int getProductQuantity(String productId) {
    if (_cart == null) return 0;
    
    final item = _cart!.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItemModel(
        id: '',
        product: ProductModel(
          id: '',
          name: '',
          description: '',
          price: '0',
          reference: '',
        ),
        quantity: 0,
        price: 0,
      ),
    );
    return item.quantity;
  }

  bool isInCart(String productId) {
    if (_cart == null) return false;
    return _cart!.items.any((item) => item.product.id == productId);
  }
}