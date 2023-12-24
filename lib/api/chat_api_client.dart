import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ChatApiClient {
  ChatApiClient({
    http.Client? httpClient,
  }) : this._(
          baseUrl: 'https://chat-api-url.com',
          httpClient: httpClient,
        );

  ChatApiClient._({
    required String baseUrl,
    http.Client? httpClient,
  })  : _baseUrl = baseUrl,
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _httpClient;

  Future<List<dynamic>> getChats() async {
    final uri = Uri.parse('$_baseUrl/chats');
    return _handleRequest((headers) => _httpClient.get(uri, headers: headers));
  }

  Future<Map<String, dynamic>> postChat(Map<String, dynamic> chatData) async {
    final uri = Uri.parse('$_baseUrl/chats');
    return _handleRequest((headers) => _httpClient.post(uri, headers: headers, body: jsonEncode(chatData)));
  }

  Future<Map<String, dynamic>> getChatById(String id) async {
    final uri = Uri.parse('$_baseUrl/chats/$id');
    return _handleRequest((headers) => _httpClient.get(uri, headers: headers));
  }

  Future<List<dynamic>> getUsers() async {
    final uri = Uri.parse('$_baseUrl/users');
    return _handleRequest((headers) => _httpClient.get(uri, headers: headers));
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    final uri = Uri.parse('$_baseUrl/users/$id');
    return _handleRequest((headers) => _httpClient.get(uri, headers: headers));
  }

  Future<Map<String, dynamic>> _handleRequest(Future<http.Response> Function(Map<String, String>) request) async {
    try {
      final headers = await _getRequestHeaders();
      final response = await request(headers);
      final body = jsonDecode(response.body);

      if (response.statusCode != HttpStatus.ok) {
        throw Exception('${response.statusCode}, error: ${body['message']}');
      }

      return body;
    } on TimeoutException {
      throw Exception('Request timeout. Please try again');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, String>> _getRequestHeaders() async {
    // TODO: Get token from secure storage;
    return <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.value,
      HttpHeaders.acceptHeader: ContentType.json.value,
      // If there is a token, add it to the headers
      // if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }
}
