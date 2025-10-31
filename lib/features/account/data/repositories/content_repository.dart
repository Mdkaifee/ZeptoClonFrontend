import 'dart:convert';

import 'package:flutter_application_1/api_services.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/features/account/data/models/content_page_model.dart';
import 'package:http/http.dart' as http;

class ContentRepository {
  ContentRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<ContentPageModel> fetchPrivacyPolicy() async {
    return _fetchContent('/api/content/privacy-policy');
  }

  Future<ContentPageModel> fetchTermsAndConditions() async {
    return _fetchContent('/api/content/terms-and-conditions');
  }

  Future<ContentPageModel> _fetchContent(String path) async {
    final response = await _apiService.get(path);
    final decoded = _decode(response);

    if (response.statusCode == 200) {
      if (decoded is Map<String, dynamic>) {
        return ContentPageModel.fromJson(decoded);
      }
      throw AppException(
        'Unexpected response format',
        statusCode: response.statusCode,
      );
    }

    throw AppException(
      _extractMessage(decoded) ?? 'Failed to load content',
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
