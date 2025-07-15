import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:first_store_nodejs_flutter/models/user_model.dart';
import 'package:first_store_nodejs_flutter/utils/constants.dart';

class AuthService {
  Future<UserModel> login(String email, String password) async {
    try {
      final uri = Uri.parse(
        '${Constants.urlCustomers}?ws_key=${Constants.wsKey}&output_format=JSON&filter[email]=$email&display=[id,firstname,lastname,email,passwd,active,id_default_group,date_add,date_upd]',
      );
      Constants.checkDebug('Login URL: $uri');
      final response = await http.get(uri);
      Constants.checkDebug('Login response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == Constants.SUCCESS_CODE) {
        final data = jsonDecode(response.body);
        if (data['customers'] != null && (data['customers'] as List).isNotEmpty) {
          final customer = data['customers'][0];
          // Convertir explicitement en Map<String, dynamic>
          final customerMap = customer is Map ? customer.map((k, v) => MapEntry(k.toString(), v)) : customer;
          final storedHash = customerMap['passwd']?.toString();
          if (storedHash != null && await FlutterBcrypt.verify(password: password, hash: storedHash)) {
            return UserModel.fromJson({
              'id': customerMap['id']?.toString(),
              'name': '${customerMap['firstname'] ?? 'Unknown'} ${customerMap['lastname'] ?? ''}'.trim().isEmpty
                  ? 'Unknown User'
                  : '${customerMap['firstname'] ?? 'Unknown'} ${customerMap['lastname'] ?? ''}'.trim(),
              'email': customerMap['email']?.toString() ?? '',
              'active': customerMap['active'],
              'id_default_group': customerMap['id_default_group'],
              'date_add': customerMap['date_add'],
              'date_upd': customerMap['date_upd'],
              'profilePicture': {},
              'bio': '',
              'trustedUser': false,
              'products': [],
              'token': '',
            });
          } else {
            throw Exception('Mot de passe incorrect');
          }
        }
        throw Exception('Utilisateur non trouvé');
      }
      throw Exception('Erreur HTTP lors de la connexion : ${response.statusCode} - ${response.body}');
    } catch (e) {
      Constants.checkDebug('Erreur lors de la connexion : $e');
      throw Exception('Erreur lors de la connexion : $e');
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    try {
      final hash = password; // Laisser PrestaShop gérer le hash côté serveur
      final names = name.trim().split(' ');
      final firstname = names.isNotEmpty ? names[0] : 'Unknown';
      final lastname = names.length > 1 ? names.sublist(1).join(' ') : '';

      final builder = XmlBuilder();
      builder.element('prestashop', nest: () {
        builder.element('customer', nest: () {
          builder.element('firstname', nest: firstname);
          builder.element('lastname', nest: lastname);
          builder.element('email', nest: email);
          builder.element('passwd', nest: hash);
          builder.element('id_default_group', nest: '3');
          builder.element('active', nest: '1');
        });
      });
      final xmlString = builder.buildDocument().toXmlString(pretty: true);

      final uri = Uri.parse('${Constants.urlCustomers}?ws_key=${Constants.wsKey}');
      Constants.checkDebug('Register URL: $uri\nDonnées : $xmlString');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/xml'},
        body: xmlString,
      );
      Constants.checkDebug('Register response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == Constants.CREATED_CODE) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson({
          'id': data['customer']?['id']?.toString(),
          'name': name,
          'email': email,
          'active': data['customer']?['active'],
          'id_default_group': data['customer']?['id_default_group'],
          'date_add': data['customer']?['date_add'],
          'date_upd': data['customer']?['date_upd'],
          'profilePicture': {},
          'bio': '',
          'trustedUser': false,
          'products': [],
          'token': '',
        });
      }
      throw Exception('Erreur HTTP lors de l\'inscription : ${response.statusCode} - ${response.body}');
    } catch (e) {
      Constants.checkDebug('Erreur lors de l\'inscription : $e');
      throw Exception('Erreur lors de l\'inscription : $e');
    }
  }
}