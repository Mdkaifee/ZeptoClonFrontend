import 'dart:convert';

import 'package:flutter_application_1/api_services.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/features/cart/data/models/cart_item_model.dart';
import 'package:http/http.dart' as http;

class CartRepository {
  CartRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Future<List<CartItemModel>> fetchCart(String userId) async {
    final response = await _apiService.get('/api/cart/user/$userId');
    final decoded = _decode(response);

    if (response.statusCode == 200) {
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(CartItemModel.fromJson)
            .toList();
      }
      return const <CartItemModel>[];
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to fetch cart',
      statusCode: response.statusCode,
    );
  }

  Future<CartMutationResult> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    final response = await _apiService.post(
      '/api/cart/add',
      headers: _jsonHeaders,
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
      }),
    );

    final decoded = _decode(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CartMutationResult.fromJson(decoded as Map<String, dynamic>);
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to add item to cart',
      statusCode: response.statusCode,
    );
  }

  Future<CartMutationResult> updateQuantity({
    required String cartItemId,
    required int quantityChange,
  }) async {
    final response = await _apiService.put(
      '/api/cart/update',
      headers: _jsonHeaders,
      body: jsonEncode({
        'cartItemId': cartItemId,
        'quantityChange': quantityChange,
      }),
    );
    final decoded = _decode(response);

    if (response.statusCode == 200) {
      return CartMutationResult.fromJson(decoded as Map<String, dynamic>);
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to update cart item',
      statusCode: response.statusCode,
    );
  }

  Future<void> clearCart(String userId) async {
    final response = await _apiService.delete('/api/cart/clear/$userId');
    if (response.statusCode == 200) {
      return;
    }
    final decoded = _decode(response);
    throw AppException(
      _extractMessage(decoded) ?? 'Failed to clear cart',
      statusCode: response.statusCode,
    );
  }

  Map<String, String> get _jsonHeaders =>
      const {'Content-Type': 'application/json', 'Accept': 'application/json'};

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

class CartMutationResult {
  CartMutationResult({
    required this.message,
    this.cartItemId,
  });

  factory CartMutationResult.fromJson(Map<String, dynamic> json) {
    return CartMutationResult(
      message: json['message']?.toString() ?? '',
      cartItemId: json['cartItemId']?.toString(),
    );
  }

  final String message;
  final String? cartItemId;

  bool get isRemoval =>
      message.toLowerCase().contains('removed') || message.contains('deleted');
}
