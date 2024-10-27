import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> sendEventToFlask(
    String eventType, String userId, String status) async {
  final String? flaskAppIp = dotenv.env['FLASK_IP'];
  final String? flaskAppPort = dotenv.env['FLASK_PORT'];
  final String flaskUrl = 'http://$flaskAppIp:$flaskAppPort/receive_event';

  try {
    final response = await http.post(
      Uri.parse(flaskUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'event_type': eventType,
        'status': status, // 상태 값 추가
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      print('Event sent to Flask successfully');
    } else {
      print('Failed to send event to Flask: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending event to Flask: $e');
  }
}
