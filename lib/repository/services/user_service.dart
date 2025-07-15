import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:first_store_nodejs_flutter/models/user_model.dart';
import 'package:first_store_nodejs_flutter/utils/constants.dart';

class UserService {
  // Remplacez par vos identifiants Cloudinary réels
  static const String _cloudinaryUrl = 'https://api.cloudinary.com/v1_1/your_cloud_name/image/upload';
  static const String _cloudinaryPreset = 'your_upload_preset'; // À configurer

  // Récupérer le profil utilisateur
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final uri = Uri.parse(
        '${Constants.urlCustomers}/$userId?ws_key=${Constants.wsKey}&output_format=JSON&display=[id,firstname,lastname,email,active,id_default_group,date_add,date_upd]',
      );
      Constants.checkDebug('Récupération du profil utilisateur : $uri');
      final response = await http.get(uri);
      Constants.checkDebug('Réponse getUserProfile : ${response.statusCode} - ${response.body}');

      if (response.statusCode == Constants.SUCCESS_CODE) {
        final data = jsonDecode(response.body);
        if (data['customer'] != null) {
          final customer = data['customer'] is Map ? data['customer'].map((k, v) => MapEntry(k.toString(), v)) : data['customer'];
          return UserModel.fromJson({
            'id': customer['id']?.toString(),
            'name': '${customer['firstname'] ?? 'Unknown'} ${customer['lastname'] ?? ''}'.trim().isEmpty
                ? 'Unknown User'
                : '${customer['firstname'] ?? 'Unknown'} ${customer['lastname'] ?? ''}'.trim(),
            'email': customer['email']?.toString() ?? '',
            'active': customer['active'],
            'id_default_group': customer['id_default_group'],
            'date_add': customer['date_add'],
            'date_upd': customer['date_upd'],
            'profilePicture': {},
            'bio': '',
            'trustedUser': false,
            'products': [],
            'token': '',
          });
        }
        throw Exception('Utilisateur non trouvé');
      }
      throw Exception('Erreur HTTP lors de la récupération du profil : ${response.statusCode} - ${response.body}');
    } catch (e) {
      Constants.checkDebug('Erreur lors de la récupération du profil : $e');
      throw Exception('Erreur lors de la récupération du profil : $e');
    }
  }

  // Mettre à jour le profil utilisateur
  Future<UserModel> updateUserProfile(String userId, Map<String, dynamic> userData) async {
    try {
      final names = (userData['name']?.toString() ?? '').split(' ');
      final firstname = names.isNotEmpty ? names[0] : 'Unknown';
      final lastname = names.length > 1 ? names.sublist(1).join(' ') : '';

      final builder = XmlBuilder();
      builder.element('prestashop', nest: () {
        builder.element('customer', nest: () {
          builder.element('id', nest: userId);
          builder.element('firstname', nest: firstname);
          builder.element('lastname', nest: lastname);
          builder.element('email', nest: userData['email']?.toString() ?? '');
          builder.element('active', nest: userData['active']?.toString() ?? '1');
          builder.element('id_default_group', nest: userData['id_default_group']?.toString() ?? '3');
          builder.element('date_upd', nest: DateTime.now().toIso8601String());
        });
      });
      final xmlString = builder.buildDocument().toXmlString(pretty: true);

      final uri = Uri.parse('${Constants.urlCustomers}/$userId?ws_key=${Constants.wsKey}');
      Constants.checkDebug('Mise à jour du profil utilisateur $userId : $uri\nDonnées : $xmlString');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/xml'},
        body: xmlString,
      );
      Constants.checkDebug('Réponse updateUserProfile : ${response.statusCode} - ${response.body}');

      if (response.statusCode == Constants.SUCCESS_CODE || response.statusCode == Constants.CREATED_CODE) {
        final data = jsonDecode(response.body);
        final customer = data['customer'] is Map ? data['customer'].map((k, v) => MapEntry(k.toString(), v)) : data['customer'];
        return UserModel.fromJson({
          'id': customer['id']?.toString() ?? userId,
          'name': userData['name']?.toString() ?? '',
          'email': userData['email']?.toString() ?? '',
          'active': customer['active'] ?? userData['active']?.toString(),
          'id_default_group': customer['id_default_group'] ?? userData['id_default_group']?.toString(),
          'date_add': customer['date_add'],
          'date_upd': customer['date_upd'] ?? DateTime.now().toIso8601String(),
          'profilePicture': userData['profilePicture'] ?? {},
          'bio': userData['bio'] ?? '',
          'trustedUser': userData['trustedUser'] ?? false,
          'products': userData['products'] ?? [],
          'token': '',
        });
      }
      throw Exception('Erreur HTTP lors de la mise à jour du profil : ${response.statusCode} - ${response.body}');
    } catch (e) {
      Constants.checkDebug('Erreur lors de la mise à jour du profil : $e');
      throw Exception('Erreur lors de la mise à jour du profil : $e');
    }
  }

  // Télécharger la photo de profil
  Future<UserModel> uploadProfilePicture(String userId, File image) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_cloudinaryUrl));
      request.fields['upload_preset'] = _cloudinaryPreset;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      Constants.checkDebug('Téléchargement de la photo de profil vers Cloudinary');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      Constants.checkDebug('Réponse uploadProfilePicture : ${response.statusCode} - $responseBody');

      if (response.statusCode == Constants.SUCCESS_CODE) {
        final responseData = jsonDecode(responseBody);
        final imageUrl = responseData['secure_url'];
        return await updateUserProfile(userId, {'profilePicture': {'url': imageUrl, 'publicId': responseData['public_id']}});
      }
      throw Exception('Erreur HTTP lors du téléchargement de la photo : ${response.statusCode} - $responseBody');
    } catch (e) {
      Constants.checkDebug('Erreur lors du téléchargement de la photo de profil : $e');
      throw Exception('Erreur lors du téléchargement de la photo de profil : $e');
    }
  }

  // Récupérer le profil vendeur (pour multi-vendeurs)
  Future<UserModel> getSellerProfile(String sellerId) async {
    try {
      final uri = Uri.parse(
        '${Constants.apiBaseUrl}/kbsellers?ws_key=${Constants.wsKey}&output_format=JSON&filter[id_seller]=$sellerId&display=[id_seller,firstname,lastname,email,bio,trusted]',
      );
      Constants.checkDebug('Récupération du profil vendeur : $uri');
      final response = await http.get(uri);
      Constants.checkDebug('Réponse getSellerProfile : ${response.statusCode} - ${response.body}');

      if (response.statusCode == Constants.SUCCESS_CODE) {
        final data = jsonDecode(response.body);
        if (data['kbsellers'] != null && data['kbsellers'].isNotEmpty) {
          final seller = data['kbsellers'][0] is Map ? data['kbsellers'][0].map((k, v) => MapEntry(k.toString(), v)) : data['kbsellers'][0];
          return UserModel.fromJson({
            'id': seller['id_seller']?.toString(),
            'name': '${seller['firstname'] ?? 'Unknown'} ${seller['lastname'] ?? ''}'.trim().isEmpty
                ? 'Unknown User'
                : '${seller['firstname'] ?? 'Unknown'} ${seller['lastname'] ?? ''}'.trim(),
            'email': seller['email']?.toString() ?? '',
            'profilePicture': {},
            'bio': seller['bio'] ?? '',
            'trustedUser': seller['trusted'] == '1' || seller['trusted'] == true,
            'products': [],
            'token': '',
          });
        }
        throw Exception('Vendeur non trouvé');
      }
      throw Exception('Erreur HTTP lors de la récupération du profil vendeur : ${response.statusCode} - ${response.body}');
    } catch (e) {
      Constants.checkDebug('Erreur lors de la récupération du profil vendeur : $e');
      throw Exception('Erreur lors de la récupération du profil vendeur : $e');
    }
  }
}