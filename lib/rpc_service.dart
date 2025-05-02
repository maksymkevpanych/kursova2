import 'dart:convert';
import 'package:http/http.dart' as http;

class RpcService {
  final String url;

  RpcService({required this.url});

  Future<Map<String, dynamic>?> sendRequest({
    required String method,
    required Map<String, dynamic> params,
    String sessionKey = 'default',
    int id = 1,
  }) async {
    final requestBody = {
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'session_key': sessionKey,
      'id': id,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('RPC error: $e');
    }

    return null;
  }
}
