import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:first_store_nodejs_flutter/models/product_mobile.dart';
import 'package:first_store_nodejs_flutter/repository/product_repo.dart';
import 'package:first_store_nodejs_flutter/utils/constants.dart';

class ApiProducts extends ProductRepo {
  // Récupérer tous les produits
  @override
  Future<List<ProductMobile>> getAllProducts() async {
    try {
      final uri = Uri.parse(
        '${Constants.urlProducts}?ws_key=${Constants.wsKey}&output_format=JSON&display=[id,name,price,description,manufacturer_name,cache_default_attribute,condition,featured,id_customer]',
      );
      Constants.checkDebug('Récupération des produits : $uri');
      final response = await http.get(uri);
      Constants.checkDebug('Réponse getAllProducts : ${response.statusCode} - ${response.body}');

      if (response.statusCode == Constants.SUCCESS_CODE) {
        final data = jsonDecode(response.body);
        if (data['products'] != null) {
          return (data['products'] as List).map((p) => _mapToProductMobile(p)).toList();
        }
        return [];
      }
      throw Exception('Erreur HTTP lors de la récupération des produits : ${response.statusCode}');
    } catch (e) {
      Constants.checkDebug('Erreur lors de la récupération des produits : $e');
      throw Exception('Erreur lors de la récupération des produits : $e');
    }
  }

  // Récupérer les produits par catégorie (ex. téléphones)
  @override
  Future<List<ProductMobile>> getProductsCategoryPhones() async {
    try {
      final uri = Uri.parse(
        '${Constants.urlProductsCategoryPhones}?ws_key=${Constants.wsKey}&output_format=JSON&display=[id,name,price,description,manufacturer_name,cache_default_attribute,condition,featured,id_customer]',
      );
      Constants.checkDebug('Récupération des téléphones : $uri');
      final response = await http.get(uri);
      Constants.checkDebug('Réponse getProductsCategoryPhones : ${response.statusCode} - ${response.body}');

      if (response.statusCode == Constants.SUCCESS_CODE) {
        final data = jsonDecode(response.body);
        if (data['products'] != null) {
          return (data['products'] as List).map((p) => _mapToProductMobile(p)).toList();
        }
        return [];
      }
      throw Exception('Erreur HTTP lors de la récupération des téléphones : ${response.statusCode}');
    } catch (e) {
      Constants.checkDebug('Erreur lors de la récupération des téléphones : $e');
      throw Exception('Erreur lors de la récupération des téléphones : $e');
    }
  }

  // Récupérer les produits par catégorie (ex. tablettes)
  @override
  Future<List<ProductMobile>> getProductsCategoryTablets() async {
    try {
      final uri = Uri.parse(
        '${Constants.urlProductsCategoryTablets}?ws_key=${Constants.wsKey}&output_format=JSON&display=[id,name,price,description,manufacturer_name,cache_default_attribute,condition,featured,id_customer]',
      );
      Constants.checkDebug('Récupération des tablettes : $uri');
      final response = await http.get(uri);
      Constants.checkDebug('Réponse getProductsCategoryTablets : ${response.statusCode} - ${response.body}');

      if (response.statusCode == Constants.SUCCESS_CODE) {
        final data = jsonDecode(response.body);
        if (data['products'] != null) {
          return (data['products'] as List).map((p) => _mapToProductMobile(p)).toList();
        }
        return [];
      }
      throw Exception('Erreur HTTP lors de la récupération des tablettes : ${response.statusCode}');
    } catch (e) {
      Constants.checkDebug('Erreur lors de la récupération des tablettes : $e');
      throw Exception('Erreur lors de la récupération des tablettes : $e');
    }
  }

  // Récupérer les produits par catégorie (ex. ordinateurs portables)
  @override
  Future<List<ProductMobile>> getProductsCategoryLaptops() async {
    try {
      final uri = Uri.parse(
        '${Constants.urlProductsCategoryLaptops}?ws_key=${Constants.wsKey}&output_format=JSON&display=[id,name,price,description,manufacturer_name,cache_default_attribute,condition,featured,id_customer]',
      );
      Constants.checkDebug('Récupération des ordinateurs portables : $uri');
      final response = await http.get(uri);
      Constants.checkDebug('Réponse getProductsCategoryLaptops : ${response.statusCode} - ${response.body}');

      if (response.statusCode == Constants.SUCCESS_CODE) {
        final data = jsonDecode(response.body);
        if (data['products'] != null) {
          return (data['products'] as List).map((p) => _mapToProductMobile(p)).toList();
        }
        return [];
      }
      throw Exception('Erreur HTTP lors de la récupération des ordinateurs portables : ${response.statusCode}');
    } catch (e) {
      Constants.checkDebug('Erreur lors de la récupération des ordinateurs portables : $e');
      throw Exception('Erreur lors de la récupération des ordinateurs portables : $e');
    }
  }

  // Ajouter un produit
  @override
  Future<bool> postProduct(ProductMobile productMobile) async {
    try {
      final builder = XmlBuilder();
      builder.element('prestashop', nest: () {
        builder.element('product', nest: () {
          builder.element('id_manufacturer', nest: productMobile.brand);
          builder.element('name', nest: productMobile.modelDevice);
          builder.element('description', nest: productMobile.description);
          builder.element('price', nest: productMobile.price?.toString() ?? '0');
          builder.element('id_category_default', nest: _getCategoryId(productMobile.deviceType));
          builder.element('active', nest: '1');
          builder.element('condition', nest: productMobile.batteryHealth?.toString() ?? '0');
          builder.element('show_price', nest: '1');
          builder.element('id_customer', nest: productMobile.createdBy?.id ?? '');
        });
      });
      final xmlString = builder.buildDocument().toXmlString(pretty: true);

      final uri = Uri.parse('${Constants.urlProducts}?ws_key=${Constants.wsKey}');
      Constants.checkDebug('Ajout du produit : $uri\nDonnées : $xmlString');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/xml'},
        body: xmlString,
      );
      Constants.checkDebug('Réponse postProduct : ${response.statusCode} - ${response.body}');

      if (response.statusCode == Constants.CREATED_CODE) {
        return true;
      }
      throw Exception('Erreur HTTP lors de l\'ajout du produit : ${response.statusCode} - ${response.body}');
    } catch (e) {
      Constants.checkDebug('Erreur lors de l\'ajout du produit : $e');
      throw Exception('Erreur lors de l\'ajout du produit : $e');
    }
  }

  // Mettre à jour un produit
  @override
  Future<void> updateProduct(String id, ProductMobile productMobile) async {
    try {
      final builder = XmlBuilder();
      builder.element('prestashop', nest: () {
        builder.element('product', nest: () {
          builder.element('id', nest: id);
          builder.element('name', nest: productMobile.modelDevice);
          builder.element('description', nest: productMobile.description);
          builder.element('price', nest: productMobile.price?.toString() ?? '0');
          builder.element('id_category_default', nest: _getCategoryId(productMobile.deviceType));
          builder.element('condition', nest: productMobile.batteryHealth?.toString() ?? '0');
          builder.element('id_customer', nest: productMobile.createdBy?.id ?? '');
        });
      });
      final xmlString = builder.buildDocument().toXmlString(pretty: true);

      final uri = Uri.parse('${Constants.urlProducts}/$id?ws_key=${Constants.wsKey}');
      Constants.checkDebug('Mise à jour du produit $id : $uri\nDonnées : $xmlString');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/xml'},
        body: xmlString,
      );
      Constants.checkDebug('Réponse updateProduct : ${response.statusCode} - ${response.body}');

      if (response.statusCode != Constants.SUCCESS_CODE && response.statusCode != Constants.CREATED_CODE) {
        throw Exception('Erreur HTTP lors de la mise à jour du produit $id : ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      Constants.checkDebug('Erreur lors de la mise à jour du produit $id : $e');
      throw Exception('Erreur lors de la mise à jour du produit $id : $e');
    }
  }

  // Supprimer un produit
  @override
  Future<void> deleteProduct(String id, String? token) async {
    try {
      final uri = Uri.parse('${Constants.urlProducts}/$id?ws_key=${Constants.wsKey}');
      Constants.checkDebug('Suppression du produit $id : $uri');
      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/xml'}, // XML pour cohérence, bien que DELETE peut ne pas nécessiter de corps
      );
      Constants.checkDebug('Réponse deleteProduct : ${response.statusCode} - ${response.body}');

      if (response.statusCode == Constants.SUCCESS_CODE) {
        return;
      }
      throw Exception('Erreur HTTP lors de la suppression du produit $id : ${response.statusCode} - ${response.body}');
    } catch (e) {
      Constants.checkDebug('Erreur lors de la suppression du produit $id : $e');
      throw Exception('Erreur lors de la suppression du produit $id : $e');
    }
  }

  // Helper: Convertir un produit PrestaShop en ProductMobile
  ProductMobile _mapToProductMobile(dynamic prestashopProduct) {
    Constants.checkDebug('Mapping produit PrestaShop : $prestashopProduct');
    // Gérer condition comme un double potentiel et convertir en int
    final conditionValue = prestashopProduct['condition']?.toString() ?? '0';
    final batteryHealth = double.tryParse(conditionValue)?.toInt() ?? 0;

    // Gérer price comme un double potentiel et convertir en int
    final priceValue = prestashopProduct['price']?.toString() ?? '0';
    final price = double.tryParse(priceValue)?.toInt() ?? 0;

    return ProductMobile(
      id: prestashopProduct['id']?.toString() ?? '',
      deviceType: prestashopProduct['type'] ?? '',
      brand: prestashopProduct['manufacturer_name'] ?? '',
      modelDevice: prestashopProduct['name'] ?? '',
      description: prestashopProduct['description'] ?? '',
      price: price,
      capacity: prestashopProduct['cache_default_attribute']?.toString() ?? '',
      color: prestashopProduct['attributes']?['color'] ?? '',
      batteryHealth: batteryHealth,
      isFeatured: prestashopProduct['featured'] == '1' || prestashopProduct['featured'] == true,
      createdBy: CreatedBy(id: prestashopProduct['id_customer']?.toString() ?? ''),
      productPictures: [], // Gérer les images si nécessaire
      favoriteProduct: [],
      createdAt: DateTime.tryParse(prestashopProduct['date_add'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(prestashopProduct['date_upd'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper: Déterminer l'ID de catégorie à partir du type de dispositif
  String _getCategoryId(String? deviceType) {
    switch (deviceType?.toLowerCase()) {
      case 'mobile':
        return '3';
      case 'tablet':
        return '4';
      case 'laptop':
        return '5';
      default:
        return '3'; // Catégorie par défaut (à ajuster si nécessaire)
    }
  }
}