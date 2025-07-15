import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../repository/services/auth_service.dart';
import '../utils/constants.dart'; // Importer constants.dart pour le débogage

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthViewModel() {
    authLoadUser();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    Constants.checkDebug('Erreur définie : $message'); // Utiliser checkDebug
    notifyListeners();
  }

  Future<void> saveUser(UserModel user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString('user_data', userJson);
    Constants.checkDebug('Utilisateur sauvegardé : $userJson');
  }

  Future<void> authLoadUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user_data');
    if (userJson != null) {
      try {
        Map<String, dynamic> userMap = jsonDecode(userJson);
        // Assurer que token est traité comme String?
        if (userMap['token'] != null && userMap['token'] is! String) {
          userMap['token'] = userMap['token'].toString();
        }
        _user = UserModel.fromJson(userMap);
        setErrorMessage(null);
        Constants.checkDebug('Utilisateur chargé : ${userMap['email']}');
      } catch (e) {
        setErrorMessage('Erreur lors du chargement de l\'utilisateur');
        Constants.checkDebug('Erreur lors du chargement de l\'utilisateur : $e');
      }
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    try {
      final user = await _authService.login(email, password);
      _user = user;
      await saveUser(user);
      setErrorMessage(null);
      setLoading(false);
      notifyListeners();
      Constants.checkDebug('Connexion réussie pour : $email');
      return true;
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('Mot de passe incorrect')) {
        errorMessage = 'Mot de passe incorrect';
      } else if (e.toString().contains('Utilisateur non trouvé')) {
        errorMessage = 'Aucun compte associé à cet email';
      } else if (e.toString().contains('Erreur HTTP')) {
        errorMessage = 'Erreur de connexion au serveur';
      } else {
        errorMessage = 'Une erreur est survenue lors de la connexion';
      }
      setErrorMessage(errorMessage);
      setLoading(false);
      notifyListeners();
      Constants.checkDebug('Erreur de connexion : $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    setLoading(true);
    try {
      final user = await _authService.register(name, email, password);
      _user = user;
      await saveUser(user);
      setErrorMessage(null);
      setLoading(false);
      notifyListeners();
      Constants.checkDebug('Inscription réussie pour : $email');
      return true;
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('Erreur HTTP')) {
        if (e.toString().contains('400')) {
          errorMessage = 'Données invalides. Vérifiez vos informations';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Erreur serveur lors de l\'inscription';
        } else {
          errorMessage = 'Erreur de connexion au serveur';
        }
      } else {
        errorMessage = 'Une erreur est survenue lors de l\'inscription';
      }
      setErrorMessage(errorMessage);
      setLoading(false);
      notifyListeners();
      Constants.checkDebug('Erreur d\'inscription : $e');
      return false;
    }
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    _user = null;
    setErrorMessage(null);
    notifyListeners();
    Constants.checkDebug('Déconnexion effectuée');
  }
}