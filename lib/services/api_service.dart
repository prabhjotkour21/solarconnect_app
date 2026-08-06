import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/app_constants.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$path');
    if (queryParams == null || queryParams.isEmpty) {
      return uri;
    }

    return uri.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParams, String? token}) async {
    final response = await _client.get(
      _uri(path, queryParams),
      headers: _headers(token),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    final response = await _client.post(
      _uri(path, queryParams),
      headers: _headers(token),
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    final response = await _client.put(
      _uri(path, queryParams),
      headers: _headers(token),
      body: body == null ? null : jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    final response = await _client.delete(
      _uri(path, queryParams),
      headers: _headers(token),
    );

    return _handleResponse(response);
  }

  Map<String, String> _headers([String? token]) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final decoded = response.body.isEmpty ? {} : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: decoded is Map<String, dynamic>
          ? (decoded['message']?.toString() ?? 'Request failed')
          : 'Request failed',
      body: decoded,
    );
  }
}

class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message, this.body});

  final int statusCode;
  final String message;
  final Object? body;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
