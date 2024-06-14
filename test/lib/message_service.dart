import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MessageService {
  static String baseUrl =
      'http://${dotenv.env['FLASK_APP_IP']}:${dotenv.env['FLASK_APP_PORT']}';

  static Future<http.Response> getMessage() async {
    print('Fetching message from $baseUrl/get_message');
    final response = await http.get(Uri.parse('$baseUrl/get_message'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response;
  }

  static Future<http.Response> setMessage(String message) async {
    print('Sending message to $baseUrl/set_message');
    final response = await http.post(
      Uri.parse('$baseUrl/set_message'),
      headers: {'Content-Type': 'application/json'},
      body: '{"message": "$message"}',
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response;
  }
}
