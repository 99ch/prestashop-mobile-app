// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/foundation.dart';

class Constants {
  // URL de base de l'API PrestaShop, adaptée pour Android et autres plateformes
  static String get apiBaseUrl => Platform.isAndroid
      ? 'http://10.0.2.2:8080/prestashop/api'
      : 'http://localhost:8080/prestashop/api';

  // Clé WebService pour l'API PrestaShop
  static const String wsKey = '96NWL1S42NR9IHSEVI9Q3APGY8ASS2FL';

  // URLs spécifiques pour les ressources PrestaShop
  static String get urlCustomers => '$apiBaseUrl/customers';
  static String get urlProducts => '$apiBaseUrl/products';

  // URLs filtrées par catégorie de produits (si applicable)
  // Note : Adaptez ces URLs si votre API PrestaShop utilise des filtres spécifiques pour les catégories
  static String get urlProductsCategoryPhones => '$urlProducts?filter[category]=mobile';
  static String get urlProductsCategoryLaptops => '$urlProducts?filter[category]=laptop';
  static String get urlProductsCategoryTablets => '$urlProducts?filter[category]=tablet';

  // Codes de statut HTTP
  static const int SUCCESS_CODE = 200;
  static const int CREATED_CODE = 201;
  static const int UPDATED_CODE = 204;
  static const int DELETED_CODE = 204;
  static const int BAD_REQUEST_CODE = 400;
  static const int UNAUTHORIZED_CODE = 401;
  static const int FORBIDDEN_CODE = 403;
  static const int NOT_FOUND_CODE = 404;

  // Fonction de débogage
  static void checkDebug(dynamic data) {
    if (kDebugMode) {
      print(data);
    }
  }
}