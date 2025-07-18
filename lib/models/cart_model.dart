import 'package:koutonou/models/product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  int quantity;
  final double price;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'price': price,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      product: ProductModel.fromJson(json['product']),
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class CartModel {
  final String id;
  final String customerId;
  final List<CartItemModel> items;
  final DateTime dateAdd;
  final DateTime dateUpd;

  CartModel({
    required this.id,
    required this.customerId,
    required this.items,
    required this.dateAdd,
    required this.dateUpd,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  
  double get tax => subtotal * 0.1; // 10% tax
  
  double get total => subtotal + tax;
  
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id']?.toString() ?? '',
      customerId: json['id_customer']?.toString() ?? '',
      items: json['items'] != null 
          ? List<CartItemModel>.from(json['items'].map((x) => CartItemModel.fromJson(x)))
          : [],
      dateAdd: json['date_add'] != null ? DateTime.parse(json['date_add']) : DateTime.now(),
      dateUpd: json['date_upd'] != null ? DateTime.parse(json['date_upd']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_customer': customerId,
      'items': items.map((x) => x.toJson()).toList(),
      'date_add': dateAdd.toIso8601String(),
      'date_upd': dateUpd.toIso8601String(),
    };
  }
}