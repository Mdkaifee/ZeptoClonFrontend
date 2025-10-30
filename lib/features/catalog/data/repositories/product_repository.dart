import 'dart:convert';

import 'package:flutter_application_1/api_services.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  ProductRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<ProductModel>> fetchProducts() async {
    final response = await _apiService.get('/api/products');
    final decoded = _decode(response);

    if (response.statusCode == 200) {
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(ProductModel.fromJson)
            .toList();
      }
      throw AppException('Unexpected response format for products');
    }

    throw AppException(
      (decoded is Map && decoded['message'] != null)
          ? decoded['message'].toString()
          : 'Failed to fetch products',
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
}
