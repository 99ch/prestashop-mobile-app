class ProductModel {
  final String id;
  final String name;
  final String description;
  final String price;
  final String reference;
  final String? categoryId;
  final String? manufacturerId;
  final String? supplierId;
  final int quantity;
  final bool active;
  final String? imageUrl;
  final List<String> images;
  final double? rating;
  final int reviewCount;
  final DateTime? dateAdd;
  final DateTime? dateUpd;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.reference,
    this.categoryId,
    this.manufacturerId,
    this.supplierId,
    this.quantity = 0,
    this.active = true,
    this.imageUrl,
    this.images = const [],
    this.rating,
    this.reviewCount = 0,
    this.dateAdd,
    this.dateUpd,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      reference: json['reference'] ?? '',
      categoryId: json['id_category_default']?.toString(),
      manufacturerId: json['id_manufacturer']?.toString(),
      supplierId: json['id_supplier']?.toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      active: json['active'] == '1' || json['active'] == true,
      imageUrl: json['image_url'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
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
      'price': price,
      'reference': reference,
      'id_category_default': categoryId,
      'id_manufacturer': manufacturerId,
      'id_supplier': supplierId,
      'quantity': quantity.toString(),
      'active': active ? '1' : '0',
      'image_url': imageUrl,
      'images': images,
      'rating': rating?.toString(),
      'review_count': reviewCount.toString(),
      'date_add': dateAdd?.toIso8601String(),
      'date_upd': dateUpd?.toIso8601String(),
    };
  }

  double get priceAsDouble => double.tryParse(price) ?? 0.0;
  
  bool get isInStock => quantity > 0;
  
  String get priceFormatted => '\$${priceAsDouble.toStringAsFixed(2)}';
}