class ProductModel {
  final String id;
  final String name;
  final String description;
  final String price;
  final String reference;
  final String? categoryId;
  final String? manufacturerName;
  final String? supplierId;
  final int quantity;
  final bool active;
  final String? imageUrl;
  final int? idDefaultImage;
  final List<int> imageIds;
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
    this.manufacturerName,
    this.supplierId,
    this.quantity = 0,
    this.active = true,
    this.imageUrl,
    this.idDefaultImage,
    this.imageIds = const [],
    this.rating,
    this.reviewCount = 0,
    this.dateAdd,
    this.dateUpd,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final idImage = json['id_default_image'];
    final idImageInt = idImage != null ? int.tryParse(idImage.toString()) : null;

    // Parsing des images supplémentaires
    final imagesJson = json['associations']?['images'] as List<dynamic>? ?? [];
    final List<int> imageIds = imagesJson
        .map((img) => int.tryParse(img['id'].toString()))
        .whereType<int>()
        .toList();

    return ProductModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      reference: json['reference'] ?? '',
      categoryId: json['id_category_default']?.toString(),
      manufacturerName: json['manufacturer_name'],
      supplierId: json['id_supplier']?.toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      active: json['active'] == '1' || json['active'] == true,
      idDefaultImage: idImageInt,
      imageUrl: idImageInt != null ? buildImageUrl(idImageInt) : null,
      imageIds: imageIds,
      rating: null,
      reviewCount: 0,
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
      'manufacturer_name': manufacturerName,
      'id_supplier': supplierId,
      'quantity': quantity.toString(),
      'active': active ? '1' : '0',
      'image_url': imageUrl,
      'id_default_image': idDefaultImage,
      'image_ids': imageIds,
      'rating': rating?.toString(),
      'review_count': reviewCount.toString(),
      'date_add': dateAdd?.toIso8601String(),
      'date_upd': dateUpd?.toIso8601String(),
    };
  }

  double get priceAsDouble => double.tryParse(price) ?? 0.0;

  bool get isInStock => quantity > 0;

  String get priceFormatted => '${priceAsDouble.toStringAsFixed(0)} FCFA';

  /// Image principale
  String get mainImageUrl =>
      idDefaultImage != null ? buildImageUrl(idDefaultImage!) : '';

  /// Galerie d’images
  List<String> get galleryImageUrls =>
      imageIds.map((id) => buildImageUrl(id)).toList();

  /// Méthode utilitaire pour construire le chemin d'image PrestaShop
  static String buildImageUrl(int imageId) {
    final idPath = imageId.toString().split('').join('/');
    return 'http://localhost:8080/prestashop/img/p/$idPath/$imageId.jpg';
  }
}
