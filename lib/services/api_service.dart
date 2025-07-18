import 'package:dio/dio.dart';
import 'package:koutonou/models/customer_model.dart';
import 'package:koutonou/models/product_model.dart';
import 'package:koutonou/models/category_model.dart';
import 'package:koutonou/models/cart_model.dart';
import 'package:koutonou/models/order_model.dart';
import 'package:koutonou/models/vendor_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/prestashop/proxy.php';
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'passwd': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> signup(CustomerModel customer, String password) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: {
          'customer': {
            'firstname': customer.firstName,
            'lastname': customer.lastName,
            'email': customer.email,
            'passwd': password,
            'active': 1,
          },
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Products
  Future<List<ProductModel>> getProducts({
    int limit = 20,
    int offset = 0,
    String? category,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'limit': '$offset,$limit',
        'display': 'full',
      };

      if (category != null && category.isNotEmpty) {
        params['filter[id_category_default]'] = category;
      }

      if (search != null && search.isNotEmpty) {
        params['filter[name]'] = '[$search]%';
      }

      final response = await _dio.get('/products', queryParameters: params);

      if (response.data != null && response.data['products'] != null) {
        return (response.data['products'] as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ProductModel> getProduct(String id) async {
    try {
      final response = await _dio.get('/products/$id', queryParameters: {
        'display': 'full',
      });

      if (response.data != null && response.data['product'] != null) {
        return ProductModel.fromJson(response.data['product']);
      } else {
        throw 'Produit introuvable';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/categories', queryParameters: {
        'display': 'full',
      });

      if (response.data != null && response.data['categories'] != null) {
        return (response.data['categories'] as List)
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Cart
  Future<CartModel> getCart(String customerId) async {
    try {
      final response = await _dio.get('/carts', queryParameters: {
        'filter[id_customer]': customerId,
        'display': 'full',
      });

      if (response.data != null && response.data['carts'] != null && response.data['carts'].isNotEmpty) {
        return CartModel.fromJson(response.data['carts'][0]);
      }

      return CartModel(
        id: '',
        customerId: customerId,
        items: [],
        dateAdd: DateTime.now(),
        dateUpd: DateTime.now(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CartModel> addToCart(String customerId, String productId, int quantity) async {
    try {
      final response = await _dio.post('/carts', data: {
        'cart': {
          'id_customer': customerId,
          'id_product': productId,
          'quantity': quantity,
        },
      });
      return CartModel.fromJson(response.data['cart']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Orders
  Future<List<OrderModel>> getOrders(String customerId) async {
    try {
      final response = await _dio.get('/orders', queryParameters: {
        'filter[id_customer]': customerId,
        'display': 'full',
      });

      if (response.data != null && response.data['orders'] != null) {
        return (response.data['orders'] as List)
            .map((json) => OrderModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<OrderModel> createOrder(CartModel cart) async {
    try {
      final response = await _dio.post('/orders', data: {
        'order': {
          'id_customer': cart.customerId,
          'total_paid': cart.total,
          'items': cart.items.map((item) => item.toJson()).toList(),
        },
      });
      return OrderModel.fromJson(response.data['order']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Vendors
  Future<List<VendorModel>> getVendors() async {
    try {
      final response = await _dio.get('/kbsellers', queryParameters: {
        'display': 'full',
        'filter[active]': '1',
      });

      if (response.data != null && response.data['kbsellers'] != null) {
        return (response.data['kbsellers'] as List)
            .map((json) => VendorModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<VendorModel> getVendor(String id) async {
    try {
      final response = await _dio.get('/kbsellers/$id', queryParameters: {
        'display': 'full',
      });

      if (response.data != null && response.data['kbseller'] != null) {
        return VendorModel.fromJson(response.data['kbseller']);
      } else {
        throw 'Vendeur introuvable';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ProductModel>> getVendorProducts(String vendorId) async {
    try {
      final response = await _dio.get('/kbsellerproducts', queryParameters: {
        'filter[id_seller]': vendorId,
        'display': 'full',
      });

      if (response.data != null && response.data['kbsellerproducts'] != null) {
        return (response.data['kbsellerproducts'] as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.badResponse:
        if (e.response?.data != null && e.response?.data['error'] != null) {
          return e.response!.data['error'];
        }
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
