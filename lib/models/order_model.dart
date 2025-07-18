import 'package:koutonou/models/cart_model.dart';
import 'package:koutonou/models/customer_model.dart';

class OrderModel {
  final String id;
  final String customerId;
  final CustomerModel? customer;
  final List<CartItemModel> items;
  final double totalPaid;
  final String currentState;
  final String paymentMethod;
  final DateTime dateAdd;
  final DateTime? dateUpd;

  OrderModel({
    required this.id,
    required this.customerId,
    this.customer,
    required this.items,
    required this.totalPaid,
    required this.currentState,
    required this.paymentMethod,
    required this.dateAdd,
    this.dateUpd,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerId: json['id_customer']?.toString() ?? '',
      customer: json['customer'] != null ? CustomerModel.fromJson(json['customer']) : null,
      items: json['items'] != null 
          ? List<CartItemModel>.from(json['items'].map((x) => CartItemModel.fromJson(x)))
          : [],
      totalPaid: double.tryParse(json['total_paid']?.toString() ?? '0') ?? 0.0,
      currentState: json['current_state']?.toString() ?? '',
      paymentMethod: json['payment_method'] ?? '',
      dateAdd: json['date_add'] != null ? DateTime.parse(json['date_add']) : DateTime.now(),
      dateUpd: json['date_upd'] != null ? DateTime.tryParse(json['date_upd']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_customer': customerId,
      'customer': customer?.toJson(),
      'items': items.map((x) => x.toJson()).toList(),
      'total_paid': totalPaid.toString(),
      'current_state': currentState,
      'payment_method': paymentMethod,
      'date_add': dateAdd.toIso8601String(),
      'date_upd': dateUpd?.toIso8601String(),
    };
  }

  String get formattedTotal => '\$${totalPaid.toStringAsFixed(2)}';
  
  String get statusDisplay {
    switch (currentState) {
      case '1':
        return 'Pending';
      case '2':
        return 'Payment Accepted';
      case '3':
        return 'Preparing';
      case '4':
        return 'Shipped';
      case '5':
        return 'Delivered';
      case '6':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}