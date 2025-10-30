import 'dart:convert';

import 'package:flutter_application_1/api_services.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/features/catalog/data/models/product_model.dart';
import 'package:http/http.dart' as http;

class WishlistRepository {
  WishlistRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<ProductModel>> fetchWishlist(String userId) async {
    final response = await _apiService.get('/api/wishlist/$userId');
    final decoded = _decode(response);

    if (response.statusCode == 200) {
      return _parseProducts(decoded);
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to fetch wishlist',
      statusCode: response.statusCode,
    );
  }

  Future<WishlistMutationResult> addToWishlist({
    required String userId,
    required String productId,
  }) async {
    final response = await _apiService.post(
      '/api/wishlist',
      headers: _jsonHeaders,
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
      }),
    );
    final decoded = _decode(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return WishlistMutationResult.fromJson(
        decoded as Map<String, dynamic>? ?? const {},
      );
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to add product to wishlist',
      statusCode: response.statusCode,
    );
  }

  Future<WishlistMutationResult> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    final response =
        await _apiService.delete('/api/wishlist/$userId/$productId');
    final decoded = _decode(response);

    if (response.statusCode == 200) {
      return WishlistMutationResult.fromJson(
        decoded as Map<String, dynamic>? ?? const {},
      );
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to remove product from wishlist',
      statusCode: response.statusCode,
    );
  }

  Map<String, String> get _jsonHeaders =>
      const {'Content-Type': 'application/json', 'Accept': 'application/json'};

  List<ProductModel> _parseProducts(dynamic decoded) {
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    }

    if (decoded is Map<String, dynamic>) {
      final wishlist = decoded['wishlist'];
      if (wishlist is List) {
        return wishlist
            .whereType<Map<String, dynamic>>()
            .map(ProductModel.fromJson)
            .toList();
      }
    }

    return const <ProductModel>[];
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

class WishlistMutationResult {
  WishlistMutationResult({
    required this.message,
    required this.products,
  });

  factory WishlistMutationResult.fromJson(Map<String, dynamic> json) {
    final wishlist = json['wishlist'];
    final products = <ProductModel>[];
    if (wishlist is List) {
      products.addAll(
        wishlist
            .whereType<Map<String, dynamic>>()
            .map(ProductModel.fromJson),
      );
    }
    return WishlistMutationResult(
      message: json['message']?.toString() ?? '',
      products: products,
    );
  }

  final String message;
  final List<ProductModel> products;
}
