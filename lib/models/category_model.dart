class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String? parentId;
  final bool active;
  final String? imageUrl;
  final int position;
  final int level;
  final DateTime? dateAdd;
  final DateTime? dateUpd;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.parentId,
    this.active = true,
    this.imageUrl,
    this.position = 0,
    this.level = 0,
    this.dateAdd,
    this.dateUpd,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      parentId: json['id_parent']?.toString(),
      active: json['active'] == '1' || json['active'] == true,
      imageUrl: json['image_url'],
      position: int.tryParse(json['position']?.toString() ?? '0') ?? 0,
      level: int.tryParse(json['level_depth']?.toString() ?? '0') ?? 0,
      dateAdd: json['date_add'] != null ? DateTime.tryParse(json['date_add']) : null,
      dateUpd: json['date_upd'] != null ? DateTime.tryParse(json['date_upd']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'id_parent': parentId,
      'active': active ? '1' : '0',
      'image_url': imageUrl,
      'position': position.toString(),
      'level_depth': level.toString(),
      'date_add': dateAdd?.toIso8601String(),
      'date_upd': dateUpd?.toIso8601String(),
    };
  }

  bool get isRootCategory => parentId == null || parentId == '0';
}