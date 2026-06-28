import 'package:http/http.dart' as http;

class AppHttpClient {
  final http.Client _client;
  AppHttpClient([http.Client? client]) : _client = client ?? http.Client();

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    return _client.get(uri, headers: headers);
  }

  Future<http.Response> getUrl(String url, {Map<String, String>? headers}) {
    return get(Uri.parse(url), headers: headers);
  }

  void close() => _client.close();
}
