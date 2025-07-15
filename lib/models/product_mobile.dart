class ProductMobile {
  String? id;
  String? deviceType;
  String? brand;
  String? modelDevice;
  String? capacity;
  String? color;
  int? batteryHealth;
  int? price;
  List<ProductPicture>? productPictures;
  List<dynamic>? favoriteProduct;
  bool? isFeatured;
  CreatedBy? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? description;

  ProductMobile({
    this.id,
    this.deviceType,
    this.brand,
    this.modelDevice,
    this.capacity,
    this.color,
    this.batteryHealth,
    this.price,
    this.productPictures,
    this.favoriteProduct,
    this.isFeatured,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.description,
  });

  factory ProductMobile.fromJson(Map<String, dynamic> json) {
    var createdByValue = json['createdBy'];
    CreatedBy? createdBy;
    if (createdByValue is Map<String, dynamic>) {
      createdBy = CreatedBy.fromJson(createdByValue);
    } else if (createdByValue is String) {
      createdBy = CreatedBy(id: createdByValue, createdById: createdByValue);
    }

    return ProductMobile(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      deviceType: json['deviceType']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      modelDevice: json['modelDevice']?.toString() ?? '',
      capacity: json['capacity']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      batteryHealth: double.tryParse(json['batteryHealth']?.toString() ?? '0')?.toInt() ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0')?.toInt() ?? 0,
      productPictures: json['productPictures'] != null
          ? List<ProductPicture>.from(json['productPictures'].map((x) => ProductPicture.fromJson(x)))
          : [],
      favoriteProduct: json['favoriteProduct'] != null
          ? List<dynamic>.from(json['favoriteProduct'])
          : [],
      isFeatured: json['isFeatured'] == true ||
          json['isFeatured'] == 1 ||
          json['isFeatured']?.toString().toLowerCase() == 'true',

      createdBy: createdBy,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'deviceType': deviceType,
        'brand': brand,
        'modelDevice': modelDevice,
        'capacity': capacity,
        'color': color,
        'batteryHealth': batteryHealth,
        'price': price,
        'productPictures': productPictures?.map((x) => x.toJson()).toList() ?? [],
        'favoriteProduct': favoriteProduct ?? [],
        'isFeatured': isFeatured,
        'createdBy': createdBy?.toJson(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'description': description,
      };
}

class CreatedBy {
  String? id;
  String? name;
  String? email;
  String? createdById;

  CreatedBy({
    this.id,
    this.name,
    this.email,
    this.createdById,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json['_id']?.toString() ?? json['id']?.toString(),
        name: json['name']?.toString(),
        email: json['email']?.toString(),
        createdById: json['createdById']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'createdById': createdById,
      };
}

class ProductPicture {
  Img? img;
  String? id;
  String? productPictureId;

  ProductPicture({
    this.img,
    this.id,
    this.productPictureId,
  });

  factory ProductPicture.fromJson(Map<String, dynamic> json) => ProductPicture(
        img: json['img'] != null ? Img.fromJson(json['img']) : null,
        id: json['_id']?.toString() ?? json['id']?.toString(),
        productPictureId: json['productPictureId']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'img': img?.toJson(),
        '_id': id,
        'productPictureId': productPictureId,
      };
}

class Img {
  String? url;
  String? publicId;

  Img({
    this.url,
    this.publicId,
  });

  factory Img.fromJson(Map<String, dynamic> json) => Img(
        url: json['url']?.toString(),
        publicId: json['publicId']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'publicId': publicId,
      };
}