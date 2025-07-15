import '../utils/constants.dart';

class ProfilePicture {
  final String? url;
  final String? publicId;

  ProfilePicture({this.url, this.publicId});

  factory ProfilePicture.fromJson(Map<String, dynamic> json) {
    Constants.checkDebug('Parsing ProfilePicture from JSON: $json');
    return ProfilePicture(
      url: json['url'],
      publicId: json['publicId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publicId': publicId,
    };
  }
}

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? bio;
  final bool? isAdmin;
  final bool? isVerified;
  final ProfilePicture? profilePicture;
  final bool? trustedUser;
  final List<dynamic>? products;
  final String? token;
  final String? idDefaultGroup;
  final String? dateAdd;
  final String? dateUpd;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.bio,
    this.isAdmin,
    this.isVerified,
    this.profilePicture,
    this.trustedUser,
    this.products,
    this.token,
    this.idDefaultGroup,
    this.dateAdd,
    this.dateUpd,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Constants.checkDebug('Parsing UserModel from JSON: $json');
    return UserModel(
      id: json['id']?.toString() ?? json['_id'],
      name: json['name'] ?? '${json['firstname'] ?? ''} ${json['lastname'] ?? ''}'.trim(),
      email: json['email'] ?? '',
      bio: json['bio'],
      isAdmin: json['is_admin'] ?? (json['id_default_group'] == '1'),
      isVerified: json['is_verified'] ?? (json['active'] == '1'),
      profilePicture: json['profilePicture'] != null
          ? ProfilePicture.fromJson(json['profilePicture'])
          : null,
      trustedUser: json['trustedUser'] ?? false,
      products: json['products'],
      token: json['token']?.toString(),
      idDefaultGroup: json['id_default_group']?.toString(),
      dateAdd: json['date_add'],
      dateUpd: json['date_upd'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'is_admin': isAdmin,
      'is_verified': isVerified,
      'profilePicture': profilePicture?.toJson(),
      'trustedUser': trustedUser,
      'products': products,
      'token': token,
      'id_default_group': idDefaultGroup,
      'date_add': dateAdd,
      'date_upd': dateUpd,
    };
  }
}