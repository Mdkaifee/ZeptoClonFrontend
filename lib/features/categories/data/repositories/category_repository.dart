import 'dart:convert';

import 'package:flutter_application_1/api_services.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/features/categories/data/models/category_model.dart';
import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';
import 'package:http/http.dart' as http;

class CategoryRepository {
  CategoryRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _apiService.get('/api/categories');
    final decoded = _decode(response);

    if (response.statusCode == 200 && decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to fetch categories',
      statusCode: response.statusCode,
    );
  }

  Future<List<ProductModel>> fetchProductsByCategory(String category) async {
    final response = await _apiService.get(
      '/api/categories/products',
      queryParameters: {'category': category},
    );
    final decoded = _decode(response);

    if (response.statusCode == 200 && decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to fetch products for $category',
      statusCode: response.statusCode,
    );
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map && decoded['message'] != null) {
      return decoded['message'].toString();
    }
    return null;
  }
}
