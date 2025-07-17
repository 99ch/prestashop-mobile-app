class CustomerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? company;
  final bool active;
  final DateTime? dateAdd;
  final DateTime? dateUpd;

  CustomerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.company,
    this.active = true,
    this.dateAdd,
    this.dateUpd,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstname'] ?? '',
      lastName: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      company: json['company'],
      active: json['active'] == '1' || json['active'] == true,
      dateAdd: json['date_add'] != null ? DateTime.tryParse(json['date_add']) : null,
      dateUpd: json['date_upd'] != null ? DateTime.tryParse(json['date_upd']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'phone': phone,
      'company': company,
      'active': active ? '1' : '0',
      'date_add': dateAdd?.toIso8601String(),
      'date_upd': dateUpd?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}