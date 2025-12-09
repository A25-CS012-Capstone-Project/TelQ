import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client client;
  final String baseUrl;
  ApiClient({required this.client, required this.baseUrl});

  Future<http.Response> get(String path, {Map<String, String>? headers}) {
    final uri = Uri.parse('$baseUrl$path');
    return client.get(uri, headers: headers);
  }

  Future<http.Response> post(String path, {Map<String, String>? headers, Object? body}) {
    final uri = Uri.parse('$baseUrl$path');
    return client.post(uri, headers: headers, body: body);
  }
}
