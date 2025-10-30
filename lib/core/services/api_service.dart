import 'dart:convert';

import 'package:http/http.dart' as http;

/// Centralized HTTP client with a shared base URL for all API requests.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://fe69e0b5c34c.ngrok-free.app';

  final http.Client _client;

  Uri buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParameters.map((key, value) => MapEntry(key, '$value')),
    });
  }

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _client.get(
      buildUri(path, queryParameters: queryParameters),
      headers: headers,
    );
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _client.post(
      buildUri(path, queryParameters: queryParameters),
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _client.put(
      buildUri(path, queryParameters: queryParameters),
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  Future<http.Response> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _client.patch(
      buildUri(path, queryParameters: queryParameters),
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  Future<http.Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _client.delete(
      buildUri(path, queryParameters: queryParameters),
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  void close() {
    _client.close();
  }
}
