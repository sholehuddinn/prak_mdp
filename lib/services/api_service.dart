import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  /// Base URL API Express.js
  static String get baseUrl {
    // Ambil URL dari file .env
    String url =
        dotenv.env['API_URL'] ?? 'http://localhost:3000/api';

    // Jika berjalan di Android Emulator,
    // localhost harus diganti menjadi 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) {
      url = url
          .replaceAll('localhost', '10.0.2.2')
          .replaceAll('127.0.0.1', '10.0.2.2');
    }

    return url;
  }

  /// Header default untuk semua request
  static Map<String, String> _defaultHeaders({
    Map<String, String>? headers,
  }) {
    return {
      'Content-Type': 'application/json',
      ...?headers,
    };
  }

  /// Logging request HTTP
  static void _logRequest(
      String method,
      Uri url,
      Map<String, String> headers,
      String? body,
      ) {
    if (!kDebugMode) return;

    print('========================================================');
    print('HTTP $method REQUEST');
    print('URL     : $url');
    print('HEADERS : $headers');

    if (body != null && body.isNotEmpty) {
      print('BODY    : $body');
    }

    print('========================================================');
  }

  /// Logging response HTTP
  static void _logResponse(
      Uri url,
      http.Response response,
      ) {
    if (!kDebugMode) return;

    print('========================================================');
    print('HTTP RESPONSE');
    print('URL    : $url');
    print('STATUS : ${response.statusCode}');
    print('BODY   : ${response.body}');
    print('========================================================');
  }

  /// HTTP GET
  static Future<http.Response> get(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = _defaultHeaders(headers: headers);

    _logRequest('GET', url, requestHeaders, null);

    final response = await http.get(
      url,
      headers: requestHeaders,
    );

    _logResponse(url, response);

    return response;
  }

  /// HTTP POST
  static Future<http.Response> post(
      String endpoint,
      Map<String, dynamic> body, {
        Map<String, String>? headers,
      }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final requestHeaders = _defaultHeaders(headers: headers);
    final requestBody = jsonEncode(body);

    _logRequest(
      'POST',
      url,
      requestHeaders,
      requestBody,
    );

    final response = await http.post(
      url,
      headers: requestHeaders,
      body: requestBody,
    );

    _logResponse(url, response);

    return response;
  }
}