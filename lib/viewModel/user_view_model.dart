import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/user_model.dart';
import '../viewModel/auth_view_model.dart';

class UserViewModel with ChangeNotifier {
  final AuthViewModel _authViewModel;
  UserModel? _user;
  String? _errorMessage;

  UserModel? get user => _user ?? _authViewModel.user;
  String? get errorMessage => _errorMessage;

  UserViewModel({required AuthViewModel authViewModel}) : _authViewModel = authViewModel;

  Future<void> getUserProfile(String userId) async {
    try {
      final baseUrl = 'http://localhost:8080/prestashop/api';
      final apiKey = '96NWL1S42NR9IHSEVI9Q3APGY8ASS2FL';
      final uri = Uri.parse(
        '$baseUrl/customers/$userId?ws_key=$apiKey&output_format=JSON&display=[id,firstname,lastname,email,active,id_default_group,date_add,date_upd]',
      );

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['customer'] != null) {
          final products = await _fetchUserProducts(userId);
          _user = UserModel.fromJson({
            ...data['customer'],
            'bio': _user?.bio ?? '',
            'token': _authViewModel.user?.token ?? '',
            'profilePicture': _user?.profilePicture?.toJson() ?? {},
            'trustedUser': _user?.trustedUser ?? false,
            'products': products,
          });
          _errorMessage = null;
          notifyListeners();
        } else {
          _errorMessage = 'Utilisateur non trouvé';
          notifyListeners();
        }
      } else {
        _errorMessage = 'Erreur HTTP : ${response.statusCode}';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération du profil : $e';
      notifyListeners();
    }
  }

  Future<List<dynamic>> _fetchUserProducts(String userId) async {
    try {
      final baseUrl = 'http://localhost:8080/prestashop/api';
      final apiKey = '96NWL1S42NR9IHSEVI9Q3APGY8ASS2FL';
      final uri = Uri.parse('$baseUrl/kbsellers/$userId/products?ws_key=$apiKey&output_format=JSON');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des produits : $e');
      return [];
    }
  }

  Future<bool> updateUserProfile(String userId, Map<String, dynamic> userData, String? token) async {
    try {
      if (token == null) {
        _errorMessage = 'Token manquant pour la mise à jour du profil';
        notifyListeners();
        return false;
      }

      final baseUrl = 'http://localhost:8080/prestashop/api';
      final apiKey = '96NWL1S42NR9IHSEVI9Q3APGY8ASS2FL';
      final uri = Uri.parse('$baseUrl/customers/$userId?ws_key=$apiKey&output_format=JSON');

      final names = userData['name']?.toString().split(' ') ?? ['Unknown'];
      final firstname = names.isNotEmpty ? names[0] : 'Unknown';
      final lastname = names.length > 1 ? names.sublist(1).join(' ') : '';

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customer': {
            'id': userId,
            'firstname': firstname,
            'lastname': lastname,
            'bio': userData['bio']?.toString() ?? '',
            'date_upd': DateTime.now().toIso8601String(),
          },
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['customer'] != null) {
          _user = UserModel.fromJson({
            ...data['customer'],
            'bio': userData['bio']?.toString() ?? '',
            'token': token ?? '',
            'profilePicture': _user?.profilePicture?.toJson() ?? {'url': null, 'publicId': null},
            'trustedUser': _user?.trustedUser ?? false,
            'products': _user?.products ?? [],
          });
          _errorMessage = null;
          notifyListeners();
          return true;
        }
      }
      _errorMessage = 'Erreur HTTP : ${response.statusCode}';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du profil : $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadProfilePicture(String userId, File image, String? token) async {
    try {
      if (token == null) {
        _errorMessage = 'Token manquant pour le téléchargement de l\'image';
        notifyListeners();
        return false;
      }

      final cloudinaryUrl = 'https://api.cloudinary.com/v1_1/your_cloud_name/image/upload';
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = 'your_upload_preset';
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        final imageUrl = data['secure_url'];

        final updateSuccess = await updateUserProfile(
          userId,
          {'profilePicture': {'url': imageUrl, 'publicId': data['public_id']}},
          token,
        );

        if (updateSuccess) {
          _errorMessage = null;
          notifyListeners();
          return true;
        }
      }
      _errorMessage = 'Erreur lors du téléchargement de l\'image';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erreur lors du téléchargement de l\'image : $e';
      notifyListeners();
      return false;
    }
  }
}