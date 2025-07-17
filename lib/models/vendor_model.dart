class VendorModel {
  final String id;
  final String name;
  final String description;
  final String email;
  final String? phone;
  final String? address;
  final String? logo;
  final bool active;
  final double rating;
  final int reviewCount;
  final DateTime? dateAdd;
  final DateTime? dateUpd;

  VendorModel({
    required this.id,
    required this.name,
    required this.description,
    required this.email,
    this.phone,
    this.address,
    this.logo,
    this.active = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.dateAdd,
    this.dateUpd,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['shop_name'] ?? '',
      description: json['description'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      logo: json['logo'],
      active: json['active'] == '1' || json['active'] == true,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
      dateAdd: json['date_add'] != null ? DateTime.tryParse(json['date_add']) : null,
      dateUpd: json['date_upd'] != null ? DateTime.tryParse(json['date_upd']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'email': email,
      'phone': phone,
      'address': address,
      'logo': logo,
      'active': active ? '1' : '0',
      'rating': rating.toString(),
      'review_count': reviewCount.toString(),
      'date_add': dateAdd?.toIso8601String(),
      'date_upd': dateUpd?.toIso8601String(),
    };
  }

  String get ratingDisplay => rating.toStringAsFixed(1);
}